get_client_credentials_from_env <- function() list(
  client_id = get_env_var("RSCLOUD_CLIENT_ID"),
  client_secret = get_env_var("RSCLOUD_CLIENT_SECRET")
)

get_env_var <- function(var) {
  value <- Sys.getenv(var)
  if (identical(value, "")) stop(glue::glue("`{var}` must be set."), call. = FALSE)
  value
}

request_token <- function() {
  req_params <- purrr::compact(list(
    client_id = get_env_var("RSCLOUD_CLIENT_ID"),
    redirect_uri = NULL,
    grant_type ="client_credentials",
    code = NULL
  ))

  client_credential_endpoint <- paste0(
    "https://login.",
    rscloud_host_get(),
    "/oauth/token"
  )

  req <- httr::POST(client_credential_endpoint,
                    encode = "form",
                    body = req_params,
                    httr::authenticate(
                      get_env_var("RSCLOUD_CLIENT_ID"),
                      get_env_var("RSCLOUD_CLIENT_SECRET"),
                      type = "basic"
                    )

  )

  httr::stop_for_status(
    req,
    task = "get an access token. Confirm that the environment variables
    `RSCLOUD_CLIENT_ID` and `RSCLOUD_CLIENT_SECRET` are set correctly"
  )
  rscloud_token <- httr::content(req, type = NULL)
  set_rscloud_token(rscloud_token)
}

get_rscloud_token <- function() .globals$rscloud_token$access_token
set_rscloud_token <- function(token) {
  .globals$rscloud_token <- token
  .globals$rscloud_token_set_time <- Sys.time()
}

#' RStudio Cloud API Authentication
#'
#' Authenticate to use the RStudio Cloud API. This function should normally not be called
#'   by the user, as rscloud functions authenticate as needed automatically.
#'
#' @details The authentication function looks for credentials in the environment
#'   variables `RSCLOUD_CLIENT_ID` and `RSCLOUD_CLIENT_SECRET`. These can be requested
#'   from the RStudio Cloud team.
#'
#' @param force Whether to autheticate regardless of an existing access token;
#'   useful if one needs to change accounts during a session. Defaults to `FALSE`.
#' @export
rscloud_authenticate <- function(force = FALSE) {
  if (force) {
    request_token()
  } else {
    if (is.null(.globals$rscloud_token)) request_token()
  }

  invisible(NULL)
}

#' Who Am I?
#'
#' Displays the current API user, authenticating if needed.
#'
#' @export
rscloud_whoami <- function() {
  response <- rscloud_rest("/users/me")
  cat(glue::glue("{response$display_name} <{response$email}>"))
  invisible(response$email)
}
