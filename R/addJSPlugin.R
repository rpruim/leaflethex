# This tells htmlwidgets about our plugin name, version, and
# where to find the script. (There's also a stylesheet argument
# if the plugin comes with CSS files.)
esriPlugin <- htmlDependency("leaflet.esri", "1.0.3",
                             src = c(href = "https://cdn.jsdelivr.net/leaflet.esri/1.0.3/"),
                             script = "esri-leaflet.js"
)

# functional wrapper for htmlDependency constructor
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

#' generic plugin Factory for pure JS leaflet libraries
#'
#' Create plugin functions to implement pure JS
#'
#' @export
pluginFactory <- function(name = "JSPlugin", location, jsfilename, dependencies, stylesheet = NULL) {
  plugin <- createPlugin(name,
                         "1.0.0",
                         src=location,
                         script=dependencies,
                         stylesheet = stylesheet)
  # Create a function for the user to use as a map pipe
  function(map, data=NULL, ...){
    jscode <- readr::read_file(paste(location, jsfilename, sep="/"))
    # Get Default data if necessary
    if(is.null(data)) {
      mapData <- leaflet::getMapData(map)
    } else {
      mapData <- data
    }
    params <- list(mapData = mapData, params = "More Parameters")
    # Load Dependencies and render JS Code with the data
    registerPlugin(map, plugin) %>% onRender(jscode, params)
  }


}
