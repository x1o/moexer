#' Plot Candles
#'
#' @param candles_df A candles tibble as returned by [get_candles]
#'
#' @return A `ggplot2` object.
#' @export
#'
#' @examples
#' \dontrun{
#' get_candles(secid = 'SBER', from = '2020-01-01') |>
#'     plot_candles()
#' }
plot_candles <- function(candles_df) {
    candles_df |>
        mutate(
            direction = factor(case_when(
                open <= close ~
                    'up',
                TRUE ~
                    'down'
            ))
        ) |>
        ggplot2::ggplot() +
        ggplot2::geom_boxplot(
            ggplot2::aes(
                x = begin,
                lower = pmin(open, close),
                upper = pmax(open, close),
                ymin = low,
                ymax = high,
                middle = low,
                group = begin,
                fill = direction
            ),
            stat = 'identity',
            fatten = 0
        ) +
        ggplot2::facet_grid(cols = vars(secid))
}
