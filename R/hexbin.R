#' Hexbin Layers for Leaflet Plots
#'
#' Create hexbin layers for leaflet plots.
#'
#' @import dplyr
#' @export
#'
#'
add_hexbin <-
  function(map,
           data = NULL,
           radius = 8.5,
           opacity = 0.5,
           duration = 500,
           lowEndColor = "white",
           highEndColor = "blue",
           stroke = TRUE) {
    # Build MapData from given data or mapData if none provided
    mapData <- if(!is.null(data)) data else leaflet::getMapData(map)
    # Add parameters to be passed to the JS plugin
    mapData$radius <- radius
    mapData$opacity <- opacity
    mapData$duration <- duration
    mapData$lowEndColor <- lowEndColor
    mapData$highEndColor <- highEndColor
    # Read JS function plugin
    hexbinJS <- readr::read_file(system.file("js", "hexbin.js", package = "leaflethex"))
    # Load JS plugin
    hexbinPlugin <-
      createPlugin("Hexbin", "1.0.0",
                   src= system.file("js", "", package = "leaflethex"),
                   script = "deps.js",
                   stylesheet = if(stroke) "hexbin.css" else "")
    # Pipe the the plugin into the given map
    map <- map %>%
    registerPlugin(hexbinPlugin) %>%
      # Add your custom JS logic here. The `this` keyword
      # refers to the Leaflet (JS) map object.
      onRender(hexbinJS, data=mapData)

    map  # show the map
  }