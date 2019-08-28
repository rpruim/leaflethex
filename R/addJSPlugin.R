#' Create plugin functions to implement Leaflet pure-JS libraries in R
#'
#' @description `pluginFactory()` takes in a couple js files (code and dependencies)
#' and creates a plugin function that applies this plugin to a given map. The new
#' function also returns the map so it can be piped with the %>% operator like other
#' leaflet functions
#'
#' @import leaflet htmltools htmlwidgets tibble
#' @param name A name for your plugin
#' @param location The parent folder of your js file, dependency file, and css stylesheet
#' @param jsfilename A .js filename relative to the parent folder at `location` that holds the source code for modifying the map object
#' @param dependencies A .js filename(s) of all other js libraries the source code depends on
#' @param stylesheet A .css stylesheet for adding styles to the entire page
#' @return A function with arguments map, data, and ... to be used as a plugin to leaflet just like the leaflet::addCircles() function
#' @seealso Some code is used from [this github gist by Joe Chang](https://gist.github.com/jcheng5/c084a59717f18e947a17955007dc5f92)
#' @examples
#'
#' df <- data.frame(
#'   lat =  42.9634 + stats::rnorm(100),
#'   lng = -85.6681 + stats::rnorm(100),
#'   size = runif(100, 5, 20),
#'   color = sample(colors(), 100)
#' )
#' addJS <-
#'   pluginFactory(
#'     "Some JS Plugin",
#'     system.file("js", "", package = "leaflethex"), "hexbin.js", "deps.js", stylesheet="hexbin.css")
#'
#' leaflet(df, width = 600, height = 300) %>%
#'   addTiles() %>%
#'   addJS(radius = 20, highEndColor = "yellow")
#'
#' @export
pluginFactory <-
  function(
    name = "JSPlugin",
    location,
    jsfilename,
    dependencies,
    stylesheet = NULL) {

  # Create a HtmlDependency with the given files
  plugin <- createPlugin(name,
                         "1.0.0",
                         src=location,
                         script=dependencies,
                         stylesheet = stylesheet)
  # Create a function for the user to use as a map pipe
  function(map, data=NULL, ...){

    # Collect extra arguments
    dots <- list(...)

    # Get Default data if necessary
    mapData <- if(is.null(data)) leaflet::getMapData(map) else data

    # Attach mapData to the the parameters to be passed to the javascript
    dots$mapData = mapData

    # Ensure that the dots list and data is passed to the JS script is a JSON object
    class(dots) <- "options"

    # Read in JS Code
    jscode <- readJSFileToString(location, jsfilename)

    # Load Dependencies and render JS Code with the data and extra parameters
    registerPlugin(map, plugin) %>% htmlwidgets::onRender(jscode, data=dots)
  }
}

# functional wrapper for htmlDependency constructor
createPlugin <- function(name, version, src, script, stylesheet = NULL) {
  htmltools::htmlDependency(name, version, src = src, script = script, stylesheet = stylesheet)
}

# A function that takes a plugin htmlDependency object and adds
# it to the map. This ensures that however or whenever the map
# gets rendered, the plugin will be loaded into the browser.
registerPlugin <- function(map, plugin) {
  map$dependencies <- c(map$dependencies, list(plugin))
  map
}

# Extra utility function to convert .js files to strings
readJSFileToString <- function(location, jsfilename) {
  readr::read_file(paste(location, jsfilename, sep="/"))
}
