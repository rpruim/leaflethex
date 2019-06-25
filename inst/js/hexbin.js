function(el, x, data = null) {
  // Set Defaults
  var defaultRadius = 12;
  var defaultRadiusVariance = 2.5;
  var defaultOpacity = 0.5;
  var defaultDuration = 500;
  var defaultLowEndColor = 'white';
  var defaultHighEndColor = 'blue';
  console.log(el);
  console.log(x);
  console.log(data);

  var buildOptions = function() {
    var radius = defaultRadius;
    var opacity = defaultOpacity;
    var duration = defaultDuration;

    var lowEndColor = defaultLowEndColor;
    var highEndColor = defaultHighEndColor;
    // Give the user a message if they don't set the radius to show what they can do
    if(data.radius === undefined) {
      console.log("The radius was not specified. Default is 8");
      console.log("Parameters include: radius, radiusvariance, opacity, duration");
    } else {
      radius = data.radius;
    }
    // Replace defaults as needed
    if(data.opacity !== undefined) opacity = data.opacity;
    if(data.duration !== undefined) duration = data.duration;
    if(data.lowEndColor !== undefined) lowEndColor = data.lowEndColor;
    if(data.highEndColor !== undefined) highEndColor = data.highEndColor;

    // Return options chosen by the user plus defaults for unchosen fields
    return {
      radius: radius,
      opacity : opacity,
      duration : duration,
      lowEndColor : lowEndColor,
      highEndColor : highEndColor
    };
  };
  // Set Options based on parameters given by the data parameters
  var options = buildOptions();

  var hexLayer = L.hexbinLayer(options).addTo(this);
  hexLayer.colorScale().range([options.lowEndColor, options.highEndColor]);

  hexLayer
  .radiusRange(
    [
      options.radius / 2,
      options.radius - 1 / options.radius
    ] // Set Radius range based on radius given through data parameter
  )
  .lat(function(d) { return d[0]; })
  .lng(function(d) { return d[1]; })
  .colorValue(function(d) { return d.length; })
  .radiusValue(function(d) { return d.length; });

  var hexData = [];
  for(i=0; i< data.mapData.lat.length; i++){
    var tuple = [data.mapData.lat[i], data.mapData.lng[i]];
    hexData.push(tuple);
  }
  hexLayer.data(hexData);


}