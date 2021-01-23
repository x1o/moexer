#' Submit a REST Query to ISS
#'
#' See <http://iss.moex.com/iss/reference/> for the reference.
#'
#' @param rest_path A REST path concatenated to `iss_base_url`.
#' @param params A HTTP GET query parameters string passed as a `list`.
#' @param iss_base_url The base ISS URL.
#' @param debug_output Print REST URLs as they are queried.
#'
#' @return A list where every element is section as returned by ISS.  The
#'   section content is parsed as a `tibble`.
#' @export
#'
#' @examples
#' \dontrun{
#' query_iss(
#'     rest_path = 'securities/SBER',
#'     params = list(iss.only = 'description'),
#'     debug = TRUE
#' )
#' }
query_iss <- function(
        rest_path,
        params = list(),
        iss_base_url = getOption('moexer.iss.base_url'),
        debug_output = getOption('moexer.debug')
    ) {
    iss_param_str <-
        params %>%
        compact %>%
        imap_chr(function(val, name) {
            glue('{name}={val}')
        }) %>%
        paste0(collapse = '&')
    iss_query_url <- glue('{iss_base_url}/{rest_path}.json')
    if (str_length(iss_param_str) > 0) {
        iss_query_url <- glue('{iss_query_url}?{iss_param_str}')
    }
    if (debug_output) {
        inform(iss_query_url)
    }
    resp_parsed <-
        httr::GET(iss_query_url) %>%
        parse_iss_json_reponse()

    return(resp_parsed)
}


parse_iss_json_reponse <- function(iss_json_response) {
    parsed_list <-
        iss_json_response %>%
        httr::content('text') %>%
        jsonlite::fromJSON(simplifyVector = TRUE, simplifyMatrix = FALSE) %>%
        map(function(iss_response_section) {
            parse_iss_response_section(iss_response_section)
        })

    return(parsed_list)
}


parse_iss_response_section <- function(iss_response_section) {
    parse_type <- function(col, col_name) {
        parse_fn <-
            switch(
                iss_response_section$metadata[[col_name]]$type,
                string = readr::parse_character,
                int32 = readr::parse_double,
                int64 = readr::parse_double,
                date = readr::parse_date,
                datetime = readr::parse_datetime,
                double = readr::parse_double
            )
        return(parse_fn(col))
    }

    parsed_section <-
        iss_response_section$data %>%
        transpose(.names = iss_response_section$columns) %>%
        imap(function(list_column, column_name) {
            list_column %>%
                unlist() %>%
                parse_type(column_name)
        }) %>%
        as_tibble()

    return(parsed_section)
}
