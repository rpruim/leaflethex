#' Hexbin Layers for Leaflet Plots
#'
#' Create hexbin layers for leaflet plots.
#'
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
           highEndColor = "blue") {
    # Build MapData from given data or mapData if none provided
    mapData <- if(!is.null(data)) data else leaflet::getMapData(map)
    # Add parameters to be passed to the JS plugin
    mapData <- list(mapData = mapData,
         radius = radius,
         opacity = opacity,
         duration = duration,
         lowEndColor = lowEndColor,
         highEndColor = highEndColor
         )
    # Ensure the data passed to the JS script is a JSON object
    class(mapData) <- "options"
    # Read JS function plugin
    hexbinJS <- readr::read_file(system.file("js", "hexbin.js", package = "leaflethex"))
    # Load JS plugin
    hexbinPlugin <- createPlugin(
      "Hexbin",
      "1.0.0",
      src= system.file("js", "", package = "leaflethex"),
      script = "deps.js", stylesheet = "hexbin.css")
    # Pipe the the plugin into the given map and show the map
    map %>% registerPlugin(hexbinPlugin) %>% onRender(hexbinJS, data=mapData)
  }