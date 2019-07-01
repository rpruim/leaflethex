#' Hexbin Layers for Leaflet Plots
#'
#' Create hexbin layers for leaflet plots.
#' @importFrom dplyr %>%
#' @import leaflet
#' @param map The leaflet map object to apply the hexbin layer to. Makes this function compatible with the `%>%` operator
#' @param data data frame or tibble - alternate data to use for this hexbin instead of default map data
#' @param radius choose the base size for the hexagons
#' @param opacity decimal between 0.0 and 1.0 - choose the percent of opacity for the hexagons
#' @param duration positive integer milliseconds that the animation takes for drawing the hexagons
#' @param lowEndColor choose the color for the smaller hexagons
#' @param highEndColor choose the color for the larger hexagons
#' @param uniformSize boolean for having uniformly sized hexagons or smaller hexagons for area containing fewer data points
#' @param uniformColor a color that overrides lowEndColor and highEndColor to make the color uniform across the hexagon sizes.
#' @note Do not use uniformColor and uniformSize together as it will not give any insights to the data
#' @seealso A [JSFiddler Hexbin example](https://jsfiddle.net/reblace/acjnbu8t/?utm_source=website&utm_medium=embed&utm_campaign=acjnbu8t) by Ryan
#' @return map parameter, but with the hexbinLayer attached so that it can be used with the `%>%` pipe operator
#'
#' @examples
#' leaflet::leaflet(data.frame(lat =  42.9634 + rnorm(1000),lng = -85.6681 + rnorm(1000))) %>%
#' addTiles() %>% add_hexbin()
#'
#' leaflet::leaflet(data.frame(lat =  42.9634 + rnorm(1000),lng = -85.6681 + rnorm(1000))) %>%
#' addTiles() %>% add_hexbin(radius=25, lowEndColor='purple', highEndColor='orange')
#' @export
#'
#'
add_hexbin <-
  function(map,
           data = NULL,
           radius = 12,
           opacity = 0.5,
           duration = 500,
           lowEndColor = "white",
           highEndColor = "blue",
           uniformSize = FALSE,
           uniformColor = NULL) {

    # Build MapData from given data or mapData if none provided
    mapData <- if(!is.null(data)) data else leaflet::getMapData(map)
    if(uniformSize && is.null(uniformColor)) {
      warning("Using uniformSize and uniformColor together will not provide any insights into the data")
    }
    # Ensure the data passed to the JS script is a JSON object
    class(mapData) <- "options"

    # Create the Hexbin Plugin
    addHex <- pluginFactory("Hexbin", system.file("js", "", package = "leaflethex"), "hexbin.js", "deps.js", "hexbin.css")

    # Pipe the Hexbin into the map
    map %>% addHex(data=mapData,
                   radius = radius,
                   opacity = opacity,
                   duration = duration,
                   lowEndColor = lowEndColor,
                   highEndColor = highEndColor,
                   uniformSize = uniformSize,
                   uniformColor = uniformColor)
  }