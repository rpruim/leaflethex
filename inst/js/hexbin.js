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
    param("uniformColor", 'blue')
  ];

  var buildOptions = function() {
    var result = {};
    // Give the user a message if they don't set the radius to show what they can do
    if(data.radius === undefined) {
      console.log("The radius was not specified. Default is 8");
      console.log("Parameters include: radius, radiusvariance, opacity, duration");
    }

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

  // Add Options to hexlayer
  var hexLayer = L.hexbinLayer(options).addTo(this);

  // Add ColorScale
  var colorScale = [options.lowEndColor, options.highEndColor];
  if(data.uniformColor !== null) colorScale = [data.uniformColor, data.uniformColor];
  hexLayer.colorScale().range(colorScale);

  // Set Radius range based on radius given through data parameter
  var largestRadius = options.radius - 1 / options.radius;
  var smallestRadius = options.radius / 2;
  if(options.uniformSize) smallestRadius = largestRadius;
  var radRange = [ smallestRadius, largestRadius ];
  hexLayer
  .radiusRange(radRange)
  .lat(function(d) { return d[0]; })
  .lng(function(d) { return d[1]; })
  .colorValue(function(d) { return d.length; })
  .radiusValue(function(d) { return d.length; });

  // Add Data to the Hex Layer
  var hexData = [];
  for(i=0; i< data.mapData.lat.length; i++){
    var tuple = [data.mapData.lat[i], data.mapData.lng[i]];
    hexData.push(tuple);
  }
  hexLayer.data(hexData);

  // Zoom in to fit the data in the screen
  this.fitBounds(hexData);

}