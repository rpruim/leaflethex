#' Hexbin Layers for Leaflet Plots
#'
#' Create hexbin layers for leaflet plots.
#'
#' @import dplyr
#' @export
#'

add_hexbin <-
  function(map) {
    hexbinJS <- readr::read_file(system.file("js", "hexbin.js", package = "leaflethex"))
    hexbinPlugin <-
      createPlugin("Hexbin", "1.0.0",
                   src= system.file("js", "", package = "leaflethex"),
                   script = "deps.js",
                   stylesheet = "hexbin.css")
    map <- map %>%
    registerPlugin(hexbinPlugin) %>%
      # Add your custom JS logic here. The `this` keyword
      # refers to the Leaflet (JS) map object.
      onRender(hexbinJS)

    map  # show the map
  }

#' LeafletWidget
#'
#' Creates a generic widget for now
#'
#' @import htmlwidgets
#'
#' @export
leaflethexWidget <- function(message, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    message = message
  )

  # create widget
  htmlwidgets::prependContent(htmlwidgets::createWidget(
    name = 'leaflethex',
    x,
    width = width,
    height = height,
    package = 'leaflethex',
    elementId = elementId
  ), htmltools::HTML('<div id="map" style="width: 600px; height: 400px; border: 1px solid #ccc"></div><button onclick="generateData()">Generate Data</button>'))
}

#' Shiny bindings for leaflethex
#'
#' Output and render functions for using leaflethex within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a leaflethex
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name leaflethex-shiny
#'
#' @export
leaflethexOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'leaflethex', width, height, package = 'leaflethex')
}

#' @rdname leaflethex-shiny
#' @export
renderLeaflethex <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, leaflethexOutput, env, quoted = TRUE)
}
