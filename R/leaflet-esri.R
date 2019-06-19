library(leaflet)
library(htmltools)
library(htmlwidgets)

# This tells htmlwidgets about our plugin name, version, and
# where to find the script. (There's also a stylesheet argument
# if the plugin comes with CSS files.)
esriPlugin <- htmlDependency("leaflet.esri", "1.0.3",
                             src = c(href = "https://cdn.jsdelivr.net/leaflet.esri/1.0.3/"),
                             script = "esri-leaflet.js"
)

createPlugin <- function(name, version, src, script, stylesheet = NULL) {
  htmlDependency(name, version, src = src, script = script, stylesheet = stylesheet)
}

# A function that takes a plugin htmlDependency object and adds
# it to the map. This ensures that however or whenever the map
# gets rendered, the plugin will be loaded into the browser.
registerPlugin <- function(map, plugin) {
  map$dependencies <- c(map$dependencies, list(plugin))
  map
}


leaflet() %>% setView(-122.23, 37.75, zoom = 10) %>%
  # Register ESRI plugin on this map instance
  registerPlugin(esriPlugin) %>%
  # Add your custom JS logic here. The `this` keyword
  # refers to the Leaflet (JS) map object.
  onRender("function(el, x) {
           L.esri.basemapLayer('Topographic').addTo(this);
           }")
