#' Get Candles for a Set of Securities
#'
#' REST path:
#' `/engines/[engine]/markets/[market]/boards/[board]/securities/[security]/candles`
#' (see <http://iss.moex.com/iss/reference/46>).
#'
#' To get the `engine-market-board` path a separate [get_security_info] query is
#' made and the board with `is_primary = 1` is selected.
#'
#' @param secid A vector of security ID's.
#' @param from A [lubridate::date] object or a character that can be coerced to
#'   it.
#' @param till A [lubridate::date] object or a character that can be coerced to
#'   it.
#' @param interval A character value specifying the candle duration (see
#'   `moexer.candle.intervals` option.)
#' @param ... Further arguments to [query_iss].
#'
#' @return A tibble as with candles in HLOCV format, plus a column with the
#'   corresponding security ID.
#' @export
#'
#' @examples
#' \dontrun{
#' get_candles(
#'     secid = c('XXXX', 'SBER', 'FXGD'),
#'     from = '2020-01-01',
#'     debug = TRUE
#' )
#' }
get_candles <- function(secid, from, till = NULL, interval = 'monthly', ...) {
    if (!is.date(from)) {
        from <- lubridate::as_date(from)
        assert_that(!is.na(from))
    }
    if (!is.null(till) && !is.date(till)) {
        till <- lubridate::as_date(till)
        assert_that(!is.na(till))
    }

    interval_names <- names(getOption('moexer.candle.intervals'))
    if (!interval %in% interval_names) {
        abort(glue('Possible interval values: {paste0(interval_names, collapse = ", ")}'))
    }
    interval_num <- getOption('moexer.candle.intervals')[[interval]]

    get_secid_candles <- function(secid) {
        bp <- determine_primary_board_path(secid = secid, ...)
        if (is.null(bp)) {
            cli_alert_warning('Skipping secid = {secid}: cannot determine the primary board path.')
            return(NULL)
        }
        iss_response <- query_iss(
            rest_path = glue(
                'engines/{bp$engine}/markets/{bp$market}',
                '/boards/{bp$boardid}/securities/{secid}/candles'
            ),
            params = list(from = from, till = till, interval = interval_num),
            ...
        )
        secid_candles_df <-
            iss_response$candles %>%
            add_column(secid = secid, .before = 1)
        return(secid_candles_df)
    }

    candles_df <- secid %>% map_dfr(function(secid) get_secid_candles(secid))

    return(candles_df)
}


#' Get Possible Candle `from-till` Values for a Security
#'
#' REST path:
#' `/engines/[engine]/markets/[market]/boards/[board]/securities/[security]/candleborders`
#' (see <http://iss.moex.com/iss/reference/48>).
#'
#' To get the `engine-market-board` path a separate [get_security_info] query is
#' made and the board with `is_primary = 1` is selected.
#'
#' @param secid A vector of security ID's.
#' @param ... Further arguments to [query_iss].
#'
#' @return A tibble with possible `from-till` values for each interval;
#'   additionally the intervals-durations mapping tibble is joined.
#' @export
#'
#' @examples
#' \dontrun{
#' get_candle_borders(secid = c('SBER', 'FXGD'))
#' }
get_candle_borders <- function(secid, ...) {
    get_secid_candle_borders <- function(secid) {
        bp <- determine_primary_board_path(secid = secid, ...)
        if (is.null(bp)) {
            cli_alert_warning('Skipping secid = {secid}: cannot determine the primary board path.')
            return(NULL)
        }
        iss_response <- query_iss(
            rest_path = glue(
                'engines/{bp$engine}/markets/{bp$market}/boards/{bp$board}',
                '/securities/{secid}/candleborders'
            ),
            ...
        )
        secid_candle_borders_df <-
            iss_response$borders %>%
            left_join(iss_response$durations, by = 'interval') %>%
            add_column(secid = secid, .before = 1)
        return(secid_candle_borders_df)
    }

    candleborders_df <- secid %>% map_dfr(function(secid) get_secid_candle_borders(secid))

    return(candleborders_df)
}



#' Get Candle Durations-Intervals Mapping
#'
#' REST path: `/index?iss.only=durations` (see http://iss.moex.com/iss/reference/28)
#'
#' @param ... Further arguments to [query_iss].
#'
#' @return A tibble with the durations-intervals mapping.
#' @export
#'
#' @examples
#' \dontrun{
#' get_candle_durations()
#' }
get_candle_durations <- function(...) {
    iss_response <- query_iss(
        rest_path = 'index',
        params = list(iss.only = 'durations'),
        ...
    )

    return(iss_response$durations)
}