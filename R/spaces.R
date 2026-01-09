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
#' @details Exactly one of `space_id` or `name` must be specified. This function
#' is used to create an object that points to an existing space on RStudio Cloud,
#' it does not create a new space.
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

#' Create a Space
#'
#' Creates a new space on RStudio Cloud.
#'
#' @param name The name of the space.
#' @param account_id The ID of the account that will own the space.
#' @param description Description of the space.
#' @param access Space access method, either "closed" (default) or "protected".
#' @param copy ID of an existing space to copy public projects from.
#'
#' @return An `rscloud_space` object.
#' @export
rscloud_space_create <- function(name,
                                 account_id,
                                 description = NULL,
                                 access = c("closed", "protected"),
                                 copy = NULL) {
  
  if (!rlang::is_scalar_character(name)) {
    stop("`name` must be a single character string.", call. = FALSE)
  }

  if (!rlang::is_scalar_integerish(account_id)) {
    stop("`account_id` must be a single integer.", call. = FALSE)
  }

  access <- match.arg(access)

  data <- list(
    name = name,
    account_id = account_id
  )

  if (!is.null(description)) {
    data$description <- description
  }

  if (!identical(access, "closed")) {
    data$access <- access
  }

  if (!is.null(copy)) {
    if (!rlang::is_scalar_integerish(copy)) {
      stop("`copy` must be a single integer (space ID).", call. = FALSE)
    }
    data$copy <- copy
  }

  response <- rscloud_rest(
    path = "spaces",
    data = data,
    verb = "POST"
  )

  parse_space_response(response) %>%
    RSCloudSpace$new()
}

#' Archive a Space
#'
#' Archives a space on RStudio Cloud. Archiving a space removes all members,
#' archives all content, and deletes any pending invitations.
#'
#' @inheritParams space_info
#'
#' @return The space object, invisibly.
#' @export
rscloud_space_archive <- function(space) {
  response <- rscloud_rest(
    path = c("spaces", space_id(space)),
    data = list(state = "archived"),
    verb = "PATCH"
  )

  invisible(space)
}

#' Restore a Space
#'
#' Restores an archived space on RStudio Cloud. Restoring a space adds the
#' caller as a space admin and reactivates all archived content.
#'
#' @inheritParams space_info
#'
#' @return The space object, invisibly.
#' @export
rscloud_space_restore <- function(space) {
  response <- rscloud_rest(
    path = c("spaces", space_id(space)),
    data = list(state = "active"),
    verb = "PATCH"
  )

  invisible(space)
}

#' Delete a Space
#'
#' Deletes a space and all of its content from RStudio Cloud. This action
#' cannot be undone.
#'
#' @inheritParams space_info
#' @param ask Whether to prompt for confirmation before deleting. Defaults to `TRUE`.
#'
#' @return `NULL`, invisibly.
#' @export
rscloud_space_delete <- function(space, ask = TRUE) {
  if (ask) {
    really_delete <- are_you_sure(glue::glue(
      "delete space `{space_id(space)}`"
    ))
    if (!really_delete) {
      return(invisible(NULL))
    }
  }

  rscloud_rest(
    path = c("spaces", space_id(space)),
    verb = "DELETE"
  )

  invisible(NULL)
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
