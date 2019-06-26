

.globals <- new.env(parent = emptyenv())

#'
#' This is called automatically on package load; you should only need to call yourself
#' if you've changed the setting in `config.yml`
#'
#' @export
#' @keywords internal
setup_token <- function() {
  if(!file.exists("config.yml")) {
    stop("No config.yml file available.  Please add it and re-run the `setup_token()` function", call. = FALSE)
  }

  ## Check to make sure that the CLIENT_ID and Secrets are defined in the config.yml
  key <- config::get("CLIENT_ID")

  if (is.null(key))
    stop("CLIENT_ID is not defined in the config.yml file.  See the README for an example.",
         call. = FALSE)

  secret <- config::get("CLIENT_SECRET")

  if (is.null(secret))
    stop("CLIENT_SECRET is not defined in the config.yml file. See the README for an example.",
         call. = FALSE)

  f <- config::get("BASE_URL")

  .globals$BASE_URL <- config::get("BASE_URL") %||% "rstudio.cloud"
  .globals$API_URL <- paste0("https://",
                             config::get("API_URL") %||% "api.rstudio.cloud")

  # HW: restyle with styler package
  .globals$rscloud_app <- httr::oauth_app(
    "rscloud",
    key = key,
    secret = secret
  )

  .globals$rscloud_endpoint <- httr::oauth_endpoint(NULL, NULL, "token",
                                                    base_url = paste0("https://login.", .globals$BASE_URL, "/oauth"))

}

#' Initializes the token that will be used in all future requests.
#' As of June 2019, the initial token that is granted is good for an hour.  If you receieve a 401 error,
#' try running the `initialize_token` command once again, and then try your original command again.
#'
#' @export
initialize_token <- function() {
  if (!exists("setup_run", .globals)) {
    setup_token()
    .globals$setup_run <- TRUE
  }

  #Cache is set to FALSE because I don't know if we can get the refresh flow to work properly.  Implementing the poor man's refresh using a time based model.
  .globals$rscloud_token <- httr::oauth2.0_token(
    endpoint = .globals$rscloud_endpoint,
    app = .globals$rscloud_app,
    client_credentials = TRUE,
    cache = FALSE
  )
  .globals$last_refresh <- as.POSIXct(Sys.time())
}


## Some useful references if you are new to creating packages or using httr
## https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
## Best practices for API design: https://httr.r-lib.org/articles/api-packages.html
## To get the more verbose version of the request, just as the user to run with_verbose() around the call they are making

