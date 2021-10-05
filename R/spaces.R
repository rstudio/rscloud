#' List Spaces
#'
#' This will typically be the first call that a user makes to help determine
#'   which spaces they have access to and to retrieve the space IDs that are
#'   needed in many of the later calls for managing space memberships and
#'   invitations.
#'
#' @param filters A vector of filters to be AND'ed and applied to the request.
#' @return A data frame of space attributes.
#' @export
rscloud_space_list <- function(filters = NULL) {
  filters <- c(filters, "visibility:private")
  query_list <- filters %>%
    purrr::map(~ list("filter" = .x)) %>%
    purrr::flatten()

  response <- rscloud_rest("spaces", query = query_list)

  verify_response_length(response, "spaces", filters)

  spaces <- collect_paginated(response,
    path = "spaces", collection = "spaces",
    query = query_list
  )

  spaces %>%
    tidy_list() %>%
    dplyr::select(space_id = .data$id, .data$name, .data$description, dplyr::everything()) %>%
    parse_times()
}

#' Get Space Information
#'
#' Obtain information on a space.
#'
#' @param space A space object created using `rscloud_space()`.
#' @export
space_info <- function(space) {
  rscloud_space_info(space_id(space))
}

rscloud_space_info <- function(space_id) {
  response <- rscloud_rest(c("spaces", space_id))
  parse_space_response(response)
}

parse_space_response <- function(response) {
  response %>%
    list() %>%
    tidy_list() %>%
    dplyr::rename(space_id = .data$id)
}

#' Construct a Space Object
#'
#' Returns a space object given the space ID or the space name.
#'
#' @param space_id The space ID.
#' @param name The space name.
#'
#' @details Exactly one of `space_id` or `name` must be specified.
#'
#' @return An `rscloud_space` object.
#' @export
rscloud_space <- function(space_id = NULL, name = NULL) {
  if (!is.null(space_id) && !is.null(name)) {
    stop(
      "One of `space_id` or `name` must be specified.",
      call. = FALSE
    )
  }

  if (is.null(space_id) && is.null(name)) {
    stop(
      "At least one of `space_id` or `name` must be specified.",
      call. = FALSE
    )
  }

  if (!is.null(space_id)) {
    rscloud_space_info(space_id) %>%
      RSCloudSpace$new()
  } else {
    df <- rscloud_space_list(filters = glue::glue("name:{name}"))
    if (nrow(df) > 1) {
      stop(
        glue::glue("Multiple spaces with name '{name}' found.", call. = FALSE)
      )
    }

    RSCloudSpace$new(df)
  }
}

#' Valid Roles for Space
#'
#' Returns valid roles for a given space and the permissions associated with each role.
#'
#' @inheritParams space_info
#'
#' @export
space_role_list <- function(space) {
  response <- rscloud_rest(path = c("spaces", space_id(space), "roles"))

  response %>%
    purrr::flatten() %>%
    purrr::transpose() %>%
    purrr::map(purrr::simplify) %>%
    tibble::as_tibble() %>%
    parse_times()
}
