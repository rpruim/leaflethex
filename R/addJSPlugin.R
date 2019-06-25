# Some Code used and adapted from https://gist.github.com/jcheng5/c084a59717f18e947a17955007dc5f92

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

#' Create plugin functions to implement Leaflet pure-JS libraries in R
#'
#' @description pluginFactory takes in a couple js files (code and dependencies)
#' and creates a plugin function that applies this plugin to a given map. The new
#' function also returns the map so it can be piped with the %>% operator like other
#' leaflet functions
#'
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
    dots <- list(...)
    # Get Default data if necessary
    if(is.null(data)) {
      mapData <- leaflet::getMapData(map)
    } else {
      mapData <- data
    }
    # Attach mapData to the the parameters to be passed to the javascript
    dots$mapData = mapData
    # Ensure that the dots list and data is passed to the JS script is a JSON object
    class(dots) <- "options"
    jscode <- readJSFileToString(location, jsfilename)
    # Load Dependencies and render JS Code with the data and extra parameters
    registerPlugin(map, plugin) %>% onRender(jscode, data=dots)
  }
}

# Extra utility function to convert .js files to strings
readJSFileToString <- function(location, jsfilename) {
  readr::read_file(paste(location, jsfilename, sep="/"))
}
