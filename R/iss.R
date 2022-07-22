#' Submit a REST Query to ISS
#'
#' See <http://iss.moex.com/iss/reference/> for the reference.
#'
#' @param rest_path A REST path concatenated to `iss_base_url`.
#' @param params A HTTP GET query parameters string passed as a `list`.
#' @param iss_base_url The base ISS URL.
#' @param debug_output Print REST URLs as they are queried.
#' @param follow_cursor If `TRUE`, iterative queries will be issued to fetch all
#'   section pages as indicated by `<section>.cursor`; the cursor section
#'   itself will be removed from the response.
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
#'     debug_output = TRUE
#' )
#' }
query_iss <- function(
        rest_path,
        params = list(),
        iss_base_url = getOption('moexer.iss.base_url'),
        debug_output = getOption('moexer.debug'),
        follow_cursor = TRUE
    ) {
    iss_query_url <- glue('{iss_base_url}/{rest_path}.json')
    iss_param_str <-
        params |>
        compact() |>
        imap_chr(function(val, name) {
            glue('{name}={val}')
        }) |>
        paste0(collapse = '&')
    if (str_length(iss_param_str) > 0) {
        iss_query_url <- glue('{iss_query_url}?{iss_param_str}')
    }
    if (debug_output) {
        inform(iss_query_url)
    }
    resp_parsed <-
        httr::GET(iss_query_url) |>
        parse_iss_json_reponse()
    if (follow_cursor) {
        for (section_name in names(resp_parsed)) {
            if (str_detect(section_name, '.*\\.cursor')) {
                cursor_section <- resp_parsed[[section_name]]
                source_section_name <- str_remove(section_name, '\\.cursor')
                source_section <- resp_parsed[[source_section_name]]
                n_pages <- ceiling(cursor_section$TOTAL / cursor_section$PAGESIZE) - 1
                remaining_section_pages <-
                    seq_len(n_pages) |>
                    map_dfr(function(page_n) {
                        query_iss(
                            rest_path,
                            params = c(
                                params,
                                list(
                                    iss.only = source_section_name,
                                    start = page_n * cursor_section$PAGESIZE
                                )
                            ),
                            iss_base_url = iss_base_url,
                            debug_output = debug_output,
                            follow_cursor = FALSE
                        )[[1]]
                    })
                resp_parsed[[source_section_name]] <- bind_rows(
                    source_section,
                    remaining_section_pages
                )
                resp_parsed[[section_name]] <- NULL
            }
        }
    }

    return(resp_parsed)
}


parse_iss_json_reponse <- function(iss_json_response) {
    parsed_list <-
        iss_json_response |>
        httr::content('text') |>
        jsonlite::fromJSON(simplifyVector = TRUE, simplifyMatrix = FALSE) |>
        map(~ parse_iss_response_section(.x))

    return(parsed_list)
}


parse_iss_response_section <- function(iss_response_section) {
    parse_type <- function(col, col_name) {
        if (!is.character(col)) {
            return(col)
        }
        data_type <- iss_response_section$metadata[[col_name]]$type
        parse_fn <-
            switch(
                data_type,
                string = readr::parse_character,
                int32 = readr::parse_double,
                int64 = readr::parse_double,
                # int32 = function(x) x,
                # int64 = function(x) x,
                date = readr::parse_date,
                datetime = readr::parse_datetime,
                double = readr::parse_double,
                time = readr::parse_time,
                undefined = {
                    cli_alert_warning(glue(
                        '"{col_name}": Undefined type (parsed as character)'
                    ))
                    readr::parse_character
                },
                abort(glue('"{col_name}": Unknown type "{data_type}"'))
            )
        return(parse_fn(col))
    }

    parsed_section <-
        iss_response_section$data |>
        transpose(.names = iss_response_section$columns) |>
        imap(function(list_column, column_name) {
            list_column |>
                unlist() |>
                parse_type(column_name)
        }) |>
        as_tibble()

    return(parsed_section)
}
