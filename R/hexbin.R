#' Hexbin Layers for Leaflet Plots
#'
#' Create hexbin layers for leaflet plots.
#' @importFrom dplyr %>%
#' @import leaflet
#' @param map The leaflet map object to apply the hexbin layer to.
#'   Makes this function compatible with the `%>%` operator
#' @param data data frame or tibble - alternate data to use for this hexbin
#'   instead of default map data
#' @param radius choose the base size for the hexagons
#' @param opacity decimal between 0.0 and 1.0 - choose the
#'   percent of opacity for the hexagons
#' @param duration positive integer milliseconds that the animation
#'   takes for drawing the hexagons
#' @param lowEndColor choose the color for the smaller hexagons
#' @param highEndColor choose the color for the larger hexagons
#' @param uniformSize a logical indicating whether all hexagons should be the same size.
#' @param uniformColor a color that overrides lowEndColor and highEndColor to
#'   make the color uniform across the hexagon sizes.
#' @param sizeSummaryFunction a string that specifies which summary function
#'   to use on sizevar to modulate the size of the hexagons.
#'   The options are 'count', 'max', 'min', 'mean', and 'median'.
#' @param sizevar a string that specifies which variable in the user specified
#'   data frame will be used to calculate the size of the hexagons.
#' @param colorSummaryFunction a string that specifies which summary function
#'   to use on colorvar to modulate the color of the hexagons.
#'   The options are 'count', 'max', 'min', 'mean', and 'median'.
#' @param colorvar a string that specifies which variable in the user specified
#'   data frame will be used to calculate the color of the hexagons.
#' @note Do not use uniformColor and uniformSize together as it will not give any
#'   insights to the data
#' @seealso A [JSFiddler Hexbin example](https://jsfiddle.net/reblace/acjnbu8t/?utm_source=website&utm_medium=embed&utm_campaign=acjnbu8t) by Ryan
#' @return map parameter, but with the hexbinLayer attached so that it can be
#'   used with the `%>%` pipe operator
#' @note If colorSummaryFunction and colorvar are not specified,
#'   the color will mirror the sizevar unless uniform color set to `TRUE`.
#' @examples
#' leaflet::leaflet(data.frame(lat =  42.9634 + rnorm(1000),lng = -85.6681 + rnorm(1000))) %>%
#' addTiles() %>% addHexbin()
#'
#' leaflet::leaflet(data.frame(lat =  42.9634 + rnorm(1000),lng = -85.6681 + rnorm(1000))) %>%
#' addTiles() %>% addHexbin(radius=25, lowEndColor='purple', highEndColor='orange')
#' @export
#'
#'
addHexbin <-
  function(map,
           data = NULL,
           radius = 12,
           opacity = 0.5,
           duration = 500,
           lowEndColor = "white",
           highEndColor = "blue",
           uniformSize = FALSE,
           uniformColor = NULL,
           sizeSummaryFunction = c("count", "sum", "max", "min", "mean", "median"),
           sizevar = NULL,
           colorSummaryFunction = c("count", "sum", "max", "min", "mean", "median"),
           colorvar = NULL) {

    sizeSummaryFunction  <- match.arg(sizeSummaryFunction)
    colorSummaryFunction <- match.arg(colorSummaryFunction)
    # Build MapData from given data or mapData if none provided
    mapData <- if(!is.null(data)) data else leaflet::getMapData(map)
    if(uniformSize && !is.null(uniformColor)) {
      warning("Using uniformSize and uniformColor together will not provide any insights into the data")
    }

    # Create the Hexbin Plugin
    addHex <- pluginFactory("Hexbin", system.file("js", "", package = "leaflethex"), "hexbin.js", "deps.js", "hexbin.css")
    supportedFunctions <- list("count", "sum", "max", "min", "mean", "median")
    # Display warning about unsupported functions
    # warnOfCustomFunctions <- function(summaryFunction) {
    #   # Check if the function is supported
    #   if(! (summaryFunction %in% supportedFunctions)) {
    #     warnStart <- "The function provided was not a supported function ("
    #     supportedFunctionsString <- paste(supportedFunctions, collapse="  ")
    #     warnCustomFunctionMessage <- "). Custom functions must be valid JS functions of the form: "
    #     warnFunctionTemplate <- "'function(d) { //Calculate and Return Value }'"
    #     warning(paste(warnStart, supportedFunctionsString, warnCustomFunctionMessage, warnFunctionTemplate, sep=""))
    #   }
    # }

    # # Display for both summary functions
    # warnOfCustomFunctions(sizeSummaryFunction)
    # warnOfCustomFunctions(colorSummaryFunction)

    # Display warning that both variables are unset
    if(is.null(sizevar) && is.null(colorvar) &&
       (sizeSummaryFunction != "count" || colorSummaryFunction != "count")) {
      line1 <- "No variables have been set for sizevar or colorvar."
      line2 <- "The hexbin will calculate a simple count of data points per hex"
      warning(paste(line1, line2))
    }

    # Throw error if the variable chosen is not present in the data frame
    if(!is.null(sizevar) && ! sizevar %in% colnames(mapData)) {
      stop("The specified 'sizevar' being used is not in the given data frame. Perhaps there was a typo. 'sizevar' must be a string of the variable name")
    }
    if(!is.null(colorvar) && ! colorvar %in% colnames(mapData)) {
      stop("The specified 'colorvar' being used is not in the given data frame. Perhaps there was a typo. 'colorvar' must be a string of the variable name")
    }

    # If only one is set make the other one mirror (overridden by uniformColor/uniformSize)
    if(is.null(sizevar) && !is.null(colorvar)) {
      sizeSummaryFunction <- colorSummaryFunction
    }
    if(!is.null(sizevar) && is.null(colorvar)) {
      colorSummaryFunction <- sizeSummaryFunction
    }
    # Ensure the data passed to the JS script is a JSON object
    class(mapData) <- "options"
    # Pipe the Hexbin into the map
    map %>% addHex(data = mapData,
                   radius = radius,
                   opacity = opacity,
                   duration = duration,
                   lowEndColor = lowEndColor,
                   highEndColor = highEndColor,
                   uniformSize = uniformSize,
                   uniformColor = uniformColor,
                   sizeSummaryFunction = sizeSummaryFunction,
                   sizevar = sizevar,
                   colorSummaryFunction = colorSummaryFunction,
                   colorvar = colorvar)
  }