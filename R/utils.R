`%||%` <- function(x, y) if (is.null(x)) y else x

check_auth <- function() {

  if (!exists("last_refresh", .globals))
    stop("The `initialize_token()` command has not been run yet.  Please run it first and try this function again. ",
         call. = FALSE)

  if (as.numeric(difftime(as.POSIXct(Sys.time()), .globals$last_refresh,
                          units = "mins")) > 59) {
    initialize_token()
  }

}

rscloud_GET <- function(path, ..., task = NULL, version = "v1") {
  url <- httr::modify_url(url = .globals$API_URL, path = c(version, path))

  req <- httr::GET(url, ..., httr::config(token = .globals$rscloud_token))

  # HW something like this
  ## TODO: Something about this isn't quite right.  Need to look at it. Commenting for now.
  # if (httr::http_status(req) == 401) {
  #   stop("You do not have permission to perform this operation.",
  #        call. = FALSE)
  # }

  httr::stop_for_status(req, task = task)
  httr::content(req)
}

rscloud_DELETE <- function(path, ..., task = NULL, version = "v1") {
  url <- httr::modify_url(url = .globals$API_URL, path = c(version, path))

  req <- httr::DELETE(url, ... ,  httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, task = task)
}

rscloud_POST <- function(path, ... , task = NULL, version = "v1") {
  url <- httr::modify_url(url = .globals$API_URL,
                          path = c(version, path))

  req <- httr::POST(url, ..., encode = "json",
                    httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, task = task)
  req
}

#' Convenience function to convert to a Posixct object
parse_times <- function(df) {
  dplyr::mutate(
    df,
    created_time = as.POSIXct(strptime(created_time, "%Y-%m-%dT%H:%M:%S")),
    updated_time = as.POSIXct(strptime(updated_time, "%Y-%m-%dT%H:%M:%S"))
  )
}
