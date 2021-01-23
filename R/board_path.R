# determine_engine_market <- function(sec_info, secid) {
#     engine_market <-
#         sec_info$description %>%
#         filter(name == 'GROUP') %>%
#         pull(value) %>%
#         str_split('_') %>%
#         unlist()
#
#     return(list(engine = engine_market[1], market = engine_market[2]))
# }


determine_primary_board_path <- function(secid, ...) {
    sec_info <- get_security_info(secid = secid, ...)
    if (nrow(sec_info$description) == 0) {
        return(NULL)
    }
    if (!'is_primary' %in% names(sec_info$boards)) {
        abort(glue('Cannot determine primary board for secid = {secid}: no is_primary column exists.'))
    }
    primary_boards <-
        sec_info$boards %>%
        filter(is_primary == 1)
    if (nrow(primary_boards) != 1) {
        abort(glue('Cannot determine primary board for secid = {secid}: more than one primary board exist.'))
    }

    primary_board_path <- list(
        engine = primary_boards$engine,
        market = primary_boards$market,
        boardid = primary_boards$boardid
    )

    return(primary_board_path)
}