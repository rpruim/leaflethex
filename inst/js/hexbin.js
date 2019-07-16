function(el, x, data = null) {

  // Utility function for saving defaults for data parameters
  var param = function(name, defaultValue) { return { name: name, defaultValue : defaultValue}  };
  // Create a list of accepted parameters to this script
  var parameters = [
    param("radius", 12),
    param("opacity", 0.5),
    param("duration", 500),
    param("lowEndColor", 'white'),
    param("highEndColor", 'blue'),
    param("uniformSize", false),
    param("uniformColor", 'blue'),
    param("sizeSummaryFunction", "count"),
    param("colorSummaryFunction", "count"),
    param("sizevar", undefined),
    param("colorvar", undefined)
  ];
  // Built-in Summary Functions
  var summaryFunctions = ["count", "sum", "max", "min", "mean", "median", ""];

  // Builds a function to calculate per hexagon from the function name
  // or valid js string and variable name to use
  var buildSumFunction = function(functionToUse, variableToUse) {
    var count = dataPointsPerHex => dataPointsPerHex.length;
    // Default to using count
    if(functionToUse == "count" || variableToUse === undefined) return count;
    if(functionToUse == "sum") {
      return function(dataPointsPerHex) {
        var result = 0;
        // Add up all variables within this hex
        dataPointsPerHex.forEach(point => {
          // point.o refers to the array containing
          // [latituteForThisPoint, longitudeForThisPoint,
          //      {sizevar: AssociatedValueUsedForSize, colorvar: AssociatedValueUsedForColor } ]
          result += point.o[2][variableToUse];
        });
        // Return the total
        return result;
      };
    }
    if(functionToUse == "max") {
      return function(dataPointsPerHex) {
        var result = Number.MIN_VALUE;
        dataPointsPerHex.forEach(point => {
          var value = point.o[2][variableToUse];
          // Return the current result unless the new value is higher
          result = result > value ? result : value ;
        });
        return result;
      };
    }
    if(functionToUse == "min") {
      return function(dataPointsPerHex) {
        var result = Number.MAX_VALUE;
        dataPointsPerHex.forEach(point => {
          var value = point.o[2][variableToUse];
          // Return the current result unless the new value is lower
          result = result < value ? result : value ;
        });
        return result;
      };
    }
    if(functionToUse == "mean") {
      return function(dataPointsPerHex) {
        var result = 0;
        // Add up all variables within this hex
        dataPointsPerHex.forEach(point => {
          result += point.o[2][variableToUse];
        });
        // Return the total divided by the length to get the mean
        return result / dataPointsPerHex.length;
      };
    }
    console.warn("Using Custom Function as no supported functions were matched");
    // User defined function
    return Function('"use strict";return (' + functionToUse + ')');
  };


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
    // if no colorvar is set, then mirror with sizevar
    if (result.colorvar === undefined) {
      result.colorvar = result.sizevar;
    }
    // Return options chosen by the user plus defaults for unchosen fields
    return result;
  };

  // Set Options based on parameters given by the data parameters
  var options = buildOptions();
  console.log("Options");
  console.log(options);
  console.log("MapData");
  console.log(data.mapData);
  console.log("Full Data");
  console.log(data);

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
  .colorValue(buildSumFunction(options.colorSummaryFunction, options.colorvar))
  .radiusValue(buildSumFunction(options.sizeSummaryFunction, options.sizevar)); // Choose summary function based off of parameter inside the data object

  // Add Data to the Hex Layer
  var hexData = [];
  console.log("Keys");
  console.log(Object.keys(data.mapData));

  // Check if variable is an array with the same length as the latitute and longitude arrays
  var variableIsCompatible = entry => Array.isArray(entry) && entry.length == data.mapData.lat.length;

  // Find any variables that may be involved in the hexbin
  var auxData = Object.assign({}, data.mapData);
  Object.keys(auxData).forEach(key => {
    if(key == "lat" || key == "lng") {
      delete auxData[key];
    }
  });
  for(i=0; i< data.mapData.lat.length; i++){
    var tuple = [data.mapData.lat[i], data.mapData.lng[i]];
    hexData.push(tuple);
  }
  if(auxData !== undefined) {
    for(i=0; i < hexData.length; i++) {
      var extraVarContainer = {};
      if(options.sizevar !== undefined) {
        extraVarContainer.sizevar = auxData[options.sizevar][i];
      }
      if(options.sizevar !== undefined) {
        extraVarContainer.colorvar = auxData[options.colorvar][i];
      }
      hexData[i].push(extraVarContainer);
    }
  }
  // hexData is now an Array of arrays (Matrix)
  // 0: [lat0, lng0, somevariable0, anothervariable0]
  // 1: [lat1, lng1, somevariable1, anothervariable1]
  // ...
  hexLayer.data(hexData);

  // Zoom in to fit the data in the screen
  this.fitBounds(hexData);

}