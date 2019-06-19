var center = [39.4, -78];
var latFn = d3.randomNormal(center[0], 1);
var longFn = d3.randomNormal(center[1], 1);
var osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      osmAttrib = '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      osm = L.tileLayer(osmUrl, {maxZoom: 18, attribution: osmAttrib});
var generateData = function() {};

HTMLWidgets.widget({

  name: 'leaflethex',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
        console.log("Loading Map...");
        var map = new L.Map('map', {layers: [osm], center: new L.LatLng(center[0], center[1]), zoom: 7});

        var options = {
            radius : 12,
            opacity: 0.5,
            duration: 500
        };

        var hexLayer = L.hexbinLayer(options).addTo(map);
        hexLayer.colorScale().range(['white', 'blue']);

        hexLayer
          .radiusRange([6, 11])
        	.lng(function(d) { return d[0]; })
          .lat(function(d) { return d[1]; })
          .colorValue(function(d) { return d.length; })
          .radiusValue(function(d) { return d.length; });

        generateData = function(){
          var data = [];
          for(i=0; i<1000; i++){
              data.push([longFn(),  latFn()]);
          }
          hexLayer.data(data);
          };
          generateData();
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});



