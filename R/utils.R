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

rscloud_GET <- function(path, ..., task = NULL, caller_subject = "space", version = "v1") {
  url <- httr::modify_url(url = .globals$API_URL, path = c(version, path))

  req <- httr::GET(url, ..., httr::config(token = .globals$rscloud_token))

  if (req$status_code == 404) {
    stop(paste("Couldn't find the requested", caller_subject),
         call. = FALSE)
  }

  if (req$status_code == 403) {
    stop(paste("You either don't have access, or the",caller_subject,"doesn't exist"),
         call. = FALSE)
  }

  httr::stop_for_status(req, task = task)
  httr::content(req)
}

rscloud_DELETE <- function(path, ..., task = NULL, version = "v1") {
  url <- httr::modify_url(url = .globals$API_URL, path = c(version, path))

  req <- httr::DELETE(url, ... ,  httr::config(token = .globals$rscloud_token))

  #TODO: Check for a variety of fun http status codes and provide a better error message

  httr::stop_for_status(req, task = task)
}

rscloud_POST <- function(path, ... , task = NULL, caller_subject = "space", version = "v1") {
  url <- httr::modify_url(url = .globals$API_URL,
                          path = c(version, path))

  req <- httr::POST(url, ..., encode = "json",
                    httr::config(token = .globals$rscloud_token))

  if (req$status_code == 409) {
    stop(paste("A duplicate request was previously made for", caller_subject),
         call. = FALSE)
  }

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
