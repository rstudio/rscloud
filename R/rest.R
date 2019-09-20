try_parse_response_as_text <- function(response) {
  raw_content <- httr::content(response, type = "raw")
  tryCatch({
    rawToChar(raw_content)
  }, error = function(e) {
    do.call(paste, as.list(raw_content))
  })
}

rscloud_rest <- function(path, query = NULL, data = NULL, task = NULL,
                         verb = "GET", version = "v1") {

  rscloud_authenticate()

  api_url <- httr::modify_url(
    url = rscloud_api_url_get(),
    scheme = "https",
    path = c(version, path)
  )

  auth_header <- httr::add_headers(
    Authorization = glue::glue("Bearer {get_rscloud_token()}")
  )

  get_response <- switch(
    verb,
    GET = function() {
      httr::GET(api_url, query = query,
                auth_header)
    },
    POST = function() {
      httr::POST(api_url,
                 body = data,
                 encode = "json",
                 auth_header
      )
    },
    DELETE = function() {
      httr::DELETE(
        api_url,
        auth_header
      )
    },
    PATCH = function() {
      httr::PATCH(
        api_url,
        body = data,
        encode = "json",
        auth_header
      )
    },
    stop("Verb `", verb, "`` is unsupported.", call. = FALSE)
  )

  response <- get_response()

  if (response$status_code == 401) {
    # perhaps the access token expired, get a new one and try again
    request_token()
    response <- get_response()
  }

  if (!response$status_code %in% c(200, 201, 204)) {
    message_body <- tryCatch(
      paste(httr::content(response, "parsed", type = "application/json"), collapse = "; "),
      error = function(e) {
        try_parse_response_as_text(response)
      }
    )

    msg <- glue::glue("
    Request to endpoint `{paste0(path, collapse = '/')}` failed with
      Status: {response$status_code}
      Response: {message_body}
    ")
    stop(msg, call. = FALSE)
  }

  text <- httr::content(response, "text", encoding = "UTF-8")
  purrr::possibly(jsonlite::fromJSON, otherwise = NULL)(text, simplifyVector = FALSE)
}

#' @importFrom dplyr .data
parse_times <- function(df) {
  dplyr::mutate(
    df,
    created_time = as.POSIXct(strptime(.data$created_time, "%Y-%m-%dT%H:%M:%S")),
    updated_time = as.POSIXct(strptime(.data$updated_time, "%Y-%m-%dT%H:%M:%S"))
  )
}

# Convenience functions for ui_* messages
succeeded <- function(x) {
  !httr::http_error(x$result)
}

failed <- function(x) {
  httr::http_error(x$result)
}


