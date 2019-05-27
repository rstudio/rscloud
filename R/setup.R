BASE_URL <- config:::get("BASE_URL")
API_URL <- paste0("https://", config::get("API_URL"))

rscloud_app <- httr::oauth_app("rscloud", key = config::get("CLIENT_ID"), secret = config::get("CLIENT_SECRET"))

rscloud_endpoint <- httr::oauth_endpoint(NULL, NULL, "token", base_url = paste0("https://login.", BASE_URL, "/oauth"))

rscloud_token <- httr::oauth2.0_token(endpoint = rscloud_endpoint, app = rscloud_app, client_credentials = T)

#' Convenience function to refresh the rscloud token since the refresh flow isn't implemented yet today.
#' As of May 28, 2019, the initial token that is granted is good for an hour.  If you receieve a 401 error,
#' try running the refresh command once again, and then try your original command again.
#'
refresh_rscloud_token <- function() {
    rscloud_token <<- httr::oauth2.0_token(endpoint = rscloud_endpoint, app = rscloud_app, client_credentials = T)
}
