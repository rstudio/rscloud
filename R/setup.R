.globals <- new.env(parent = emptyenv())

initialize_token <- function() {
  .globals$BASE_URL <- config::get("BASE_URL")
  .globals$API_URL <- paste0("https://", config::get("API_URL"))

  .globals$rscloud_app <- httr::oauth_app("rscloud",
                                          key = config::get("CLIENT_ID"),
                                          secret = config::get("CLIENT_SECRET"))

  .globals$rscloud_endpoint <- httr::oauth_endpoint(NULL, NULL, "token",
                                                    base_url = paste0("https://login.", .globals$BASE_URL, "/oauth"))

  .globals$rscloud_token <- httr::oauth2.0_token(endpoint = .globals$rscloud_endpoint,
                                                 app = .globals$rscloud_app,
                                                 client_credentials = T)
}

#' Convenience function to refresh the rscloud token since the refresh flow isn't implemented yet today.
#' As of May 28, 2019, the initial token that is granted is good for an hour.  If you receieve a 401 error,
#' try running the refresh command once again, and then try your original command again.
#'
refresh_token <- function() {
    .globals$rscloud_token <- httr::oauth2.0_token(endpoint = .globals$rscloud_endpoint,
                                                    app = .globals$rscloud_app,
                                                    client_credentials = T)
}
