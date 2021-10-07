#' @importFrom rlang %||%
rlang::`%||%`

#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

#' Configuring RStudio Cloud Host and API URL
#'
#' These functions configure the host and API URL settings for
#'   authentication and requests. See details for setting preferences.
#'
#' @details The rscloud package reads host and API URL settings
#'   in this order:
#' \enumerate{
#'   \item The value set by the user using `rscloud_api_url_set()` or `rscloud_host_set()`
#'   \item The environment variables `RSCLOUD_API_URL` and `RSCLOUD_HOST`
#'   \item The defaults `https://api.rstudio.cloud` and `rstudio.cloud`
#' }
#'
#' @param url The URL for the RStudio Cloud API.
#' @export
rscloud_api_url_set <- function(url) {
  .globals$api_url <- url
  invisible(NULL)
}

#' @rdname rscloud_api_url_set
#' @export
rscloud_api_url_get <- function() {
  .globals$api_url %||%
    Sys.getenv("RSCLOUD_API_URL", unset = "https://api.rstudio.cloud")
}

#' @rdname rscloud_api_url_set
#' @param host The hostname of the RStudio Cloud service.
#' @export
rscloud_host_set <- function(host) {
  .globals$rscloud_host <- host
  invisible(NULL)
}

#' @rdname rscloud_api_url_set
#' @export
rscloud_host_get <- function() {
  .globals$rscloud_host %||%
    Sys.getenv("RSCLOUD_HOST", unset = "rstudio.cloud")
}

collect_paginated <- function(response, path, collection = path, query = NULL) {
  if (response$count == response$total) {
    return(response[[collection]])
  }

  l <- vector("list", response$total)
  l[1:response$count] <- response[[collection]]

  pb <- progress::progress_bar$new(
    format = glue::glue(" Retrieving :what {collection} [:bar] :percent"),
    total = response$total, clear = FALSE, width = 60, show_after = 0
  )

  pb$tick(response$count, tokens = list(what = response$total))

  get_items <- function(l, offset, count) {
    if (offset >= length(l)) {
      l
    } else {
      pb$tick(count, tokens = list(what = response$total))
      response <- rscloud_rest(path, query = c(list(offset = offset, count = count), query))
      l[(offset + 1):(offset + response$count)] <- response[[collection]]

      get_items(l, offset + count, count)
    }
  }

  get_items(l, response$count, response$count)
}

convert_na <- function(x) {
  types <- purrr::map_chr(x, typeof)
  target_type <- setdiff(types, "NULL") %>% unique()
  na <- if (length(target_type) && !identical(target_type, "list")) {
    switch(target_type,
      character = NA_character_,
      integer = NA_integer_,
      double = NA_real_,
      NA
    )
  } else {
    NA
  }
  purrr::map(x, ~ .x %||% na) %>%
    purrr::simplify()
}

tidy_list <- function(l) {
  l %>%
    purrr::transpose() %>%
    purrr::map(convert_na) %>%
    tibble::as_tibble()
}

verify_response_length <- function(response, collection, filters) {
  if (length(response[[collection]]) == 0) {
    if (is.null(filters)) {
      stop(glue::glue("No {collection} found."), call. = FALSE)
    } else {
      stop(glue::glue("No {collection} with criteria \"{paste(filters, collapse = ',')}\" found"),
        call. = FALSE
      )
    }
  }
}

is_valid_email <- function(x) {
  any(grepl("(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])",
    x,
    perl = TRUE
  ))
}

are_you_sure <- function(x) {
  cat(paste0("Are you sure you want to ", x, "?"))
  utils::menu(c("yes", "no")) == 1
}
