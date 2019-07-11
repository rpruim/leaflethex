function(el, x, data = null) {

  // Utility function for saving defaults for data parameters
  var param = function(name, defaultValue) { return { name: name, defaultValue : defaultValue}  };

  // Built-in Summary Functions

  var summaryFunctions = {
    count: function(d) {
      return d.length;
    },
    sum: function(d) {
        var result = 0;
        d.forEach(bin => {
          result += bin.o[2];
        });
        return result;
    },
    max: function(d) {
        var result = Number.MIN_VALUE;
        d.forEach(bin => {
          result = result > bin.o[2] ? result : bin.o[2] ;
        });
        return result;
    },
    min: function(d) {
        var result = Number.MAX_VALUE;
        d.forEach(bin => {
          result = result < bin.o[2] ? result : bin.o[2] ;
        });
        return result;
    },
    mean: function(d) {
      var result = 0;
      d.forEach(bin => {
        result += bin.o[2];
      });
      result /= d.length;
      return result;
    },
  };
  var custom = true;
  Object.keys(summaryFunctions).forEach(key => {
    if(key == options.summaryFunction) {
      custom = false;
    }
  });
  if(custom) {
    summaryFunctions.custom = Function('"use strict";return (' + options.summaryFunction + ')');
    options.summaryFunction = "custom";
  }


  // Create a list of accepted parameters to this script
  var parameters = [
    param("radius", 12),
    param("opacity", 0.5),
    param("duration", 500),
    param("lowEndColor", 'white'),
    param("highEndColor", 'blue'),
    param("uniformSize", false),
    param("uniformColor", 'blue'),
    param("summaryFunction", "count"),
    param("variable", undefined)
  ];

  var buildOptions = function() {

    // Initialize the object that will be filled and returned
    var result = {};

    // Create options object with given values or default values if none are provided
    parameters.forEach(entry => {
      var parameterValue = data[entry.name];
      if(parameterValue !== undefined && parameterValue !== null) {
        result[entry.name] = parameterValue;
      } else {
        result[entry.name] = entry.defaultValue;
      }
    });

    // Return options chosen by the user plus defaults for unchosen fields
    return result;
  };

  // Set Options based on parameters given by the data parameters
  var options = buildOptions();
  console.log(options);
  console.log(data.mapData);

  // Add Options to hexlayer
  var hexLayer = L.hexbinLayer(options).addTo(this);

  // Add ColorScale
  var colorScale = [options.lowEndColor, options.highEndColor];
  if(data.uniformColor !== null && data.uniformColor !== undefined) {
    colorScale = [data.uniformColor, data.uniformColor];
  }
  hexLayer.colorScale().range(colorScale);

  // Set Radius range based on radius given through data parameter
  var largestRadius = options.radius - 1 / options.radius; // 1/radius is a small buffer between hexagons
  var smallestRadius = options.radius / 2;
  if(options.uniformSize) smallestRadius = largestRadius;
  var radRange = [ smallestRadius, largestRadius ];

  // Load in Desired Summary Function


  // Create Hex Layer
  hexLayer
  .radiusRange(radRange)
  .lat(function(d) { return d[0]; })
  .lng(function(d) { return d[1]; })
  .colorValue(summaryFunctions[options.summaryFunction])
  .radiusValue(summaryFunctions[options.summaryFunction]); // Choose summary function based off of parameter inside the data object

  // Add Data to the Hex Layer
  var hexData = [];
  var auxData = [];
  Object.keys(data.mapData).forEach(key => {
    if(key == "lat" || key == "lng") return;
    var entry = data.mapData[key];
    if(Array.isArray(entry) && entry.length == data.mapData.lat.length) {
      auxData.push(entry);
    }
  });
  for(i=0; i< data.mapData.lat.length; i++){
    var tuple = [data.mapData.lat[i], data.mapData.lng[i]];
    hexData.push(tuple);
  }
  if(auxData !== undefined) {
    for(i=0; i < hexData.length; i++) {
      auxData.forEach(aux => {
        hexData[i].push(aux[i]);
      });
    }
  }
  hexLayer.data(hexData);

  // Zoom in to fit the data in the screen
  this.fitBounds(hexData);

}