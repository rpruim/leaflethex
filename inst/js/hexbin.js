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

  var buildLayerOptions = function() {
    var radius = defaultRadius;
    var opacity = defaultOpacity;
    var duration = defaultDuration;
    // Give the user a message if they don't set the radius to show what they can do
    if(data.radius === undefined) {
      console.log("The radius was not specified. Default is 8");
      console.log("Parameters include: radius, radiusvariance, opacity, duration");
    } else {
      radius = data.radius[0];
    }
    // Replace defaults as needed
    if(data.opacity !== undefined) opacity = data.opacity[0];
    if(data.duration !== undefined) duration = data.duration[0];

    // Return options chosen by the user plus defaults for unchosen fields
    return {
      radius: radius,
      opacity : opacity,
      duration : duration
    };
  };

  var buildStyleOptions = function() {
    var lowEndColor = defaultLowEndColor;
    var highEndColor = defaultHighEndColor;
    if(data.lowEndColor !== undefined) lowEndColor = data.lowEndColor[0];
    if(data.highEndColor !== undefined) highEndColor = data.highEndColor[0];

    return {
      lowEndColor : lowEndColor,
      highEndColor : highEndColor
    };
  };
  // Set Options based on parameters given by the data parameters
  var layerOptions = buildLayerOptions();
  var styleOptions = buildStyleOptions();

  var hexLayer = L.hexbinLayer(layerOptions).addTo(this);
  hexLayer.colorScale().range([styleOptions.lowEndColor, styleOptions.highEndColor]);

  hexLayer
  .radiusRange(
    [
      layerOptions.radius / 2,
      layerOptions.radius - 1 / layerOptions.radius
    ] // Set Radius range based on radius given through data parameter
  )
  .lng(function(d) { return d[0]; })
  .lat(function(d) { return d[1]; })
  .colorValue(function(d) { return d.length; })
  .radiusValue(function(d) { return d.length; });

  var hexData = [];
  for(i=0; i< data.lat.length; i++){
    console.log([data.lat[i], data.lng[i]]);
    console.log(hexData);
    hexData.push([data.lat[i],  data.lng[i]]);
  }
  hexLayer.data(hexData);


}