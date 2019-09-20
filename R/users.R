#' Get list of members for space
#'
#' Returns the list of members for a given space. You must either be the admin
#' of the space or your role must have permissions to see the members list.
#'
#' @inheritParams space_info
#' @inheritParams rscloud_space_list
#'
#' @export
space_member_list <- function(space, filters = NULL) {

  space_id <- space_id(space)

  query_list <- filters %>%
    purrr::map(~list("filter" = .x)) %>%
    purrr::flatten()

  response <- rscloud_rest(path = c("spaces", space_id, "members"),
                            query = query_list)

  verify_response_length(response, "users", filters)

  users <- collect_paginated(response,
                             path = c("spaces", space_id, "members"),
                             collection = "users",
                             query = query_list)
  users %>%
    tidy_list() %>%
    dplyr::mutate_at(c("first_name", "last_name", "location", "organization"),
                     function(l) purrr::map(l, ~.x %||% NA) %>% purrr::flatten_chr()) %>%
    parse_times() %>%
    dplyr::select(user_id = .data$id, .data$display_name,
                  .data$email,
                  .data$updated_time,
                  .data$created_time, dplyr::everything())
}

#' Invite Users
#'
#' Invites users to a space.
#'
#' @inheritParams space_info
#' @param users Email address of the user to add or a data frame of user information.
#' @param ... Additional arguments.
#'
#' @details The `users` input should be a data frame consisting of the columns "user_email",
#'   "email_invite", "email_message", and "space_role". Each row of the `users` data frame
#'    denotes one user to be added. If any of these properties are specified in `...`, they
#'    will take precendence and a message printed.
#'
#' @export
space_member_add <- function(space, users, ...) {
  UseMethod("space_member_add", users)
}

#' @rdname space_member_add
#' @param email_invite Indicates whether an email should be sent to the user with the invite, `TRUE` by default
#' @param email_message Message to be sent to the user should the `email_invite` flag be set to `TRUE`
#' @param space_role Desired role for the user in the space
#' @export
space_member_add.character <- function(space, users,
                                        email_invite = TRUE,
                                        email_message = NULL,
                                        space_role = "contributor", ...) {
  if (!rlang::is_scalar_character(users)) stop(
    "`users` must be a single email address. For adding multiple users please pass a data frame.",
    call. = FALSE
  )

  # TODO: don't check multiple times for the same role
  roles <- space_role_list(space)
  space_id <- space_id(space)

  if (!space_role %in% roles$role)
    stop(paste0("Role: ", space_role, " isn't a valid role for space: ", space_id))

  user <- list(email = users, space_role = space_role)

  if (email_invite) {
    user <- c(user, invite_email = email_invite, invite_email_message = email_message)
  }

  req <- rscloud_rest(path = c("spaces", space_id, "members"),
                      data = user,
                      verb = "POST")

  invisible(space)
}

#' @rdname space_member_add
#' @export
space_member_add.data.frame <- function(space, users, ...) {

  dots <- rlang::dots_list(...)

  user_email <- users[["user_email"]] %||% stop("`users` must contain a 'user_email' column.",
                                                call. = FALSE)

  # TODO: refactor via function
  overrides <- character()

  users[["email_invite"]] <- if (!is.null(dots$email_invite)) {
    overrides <- append(overrides, "email_invite")
    dots$email_invite
  } else {
    users[["email_invite"]]
  }

  users[["email_message"]] <- if (!is.null(dots$email_message)) {
    overrides <- append(overrides, "email_message")
    dots$email_message
  } else {
    users[["email_message"]]
  }

  users[["space_role"]] <- if (!is.null(dots$space_role)) {
    overrides <- append(overrides, "space_role")
    dots$space_role
  } else {
    users[["space_role"]]
  }

  if (length(overrides)) {
    message(glue::glue("
         Using the following overrides:
           {paste(overrides, purrr::map_chr(overrides, ~ dots[[.x]]), sep = ': ')}"
    ))
  }

  suppressWarnings({
    users %>%
      dplyr::select(dplyr::one_of(
        c("user_email", "email_invite", "email_message","space_role"))
      )
  }) %>%
    dplyr::rename(users = .data$user_email) %>%
    purrr::transpose() %>%
    purrr::walk(~ rlang::exec(space_member_add.character, !!!.x, space = space))

  invisible(space)
}

#' Remove Members
#'
#' Removes members.
#'
#' @inheritParams space_info
#' @param users ID number or email of the user to be removed, or a data frame
#'   with either a `user_id` or `email` column.
#' @param warn Whether to ask user for confirmation of deletion.
#'
#' @export
space_member_remove <- function(space, users, warn = TRUE) {
  UseMethod("space_member_remove", users)
}

#' @rdname space_member_remove
#' @export
space_member_remove.numeric <- function(space, users, warn = TRUE) {
  if (!rlang::is_scalar_integerish(users)) stop(
    "`users` must be a single user ID or email. For removing multiple users please pass a data frame.",
    call. = FALSE
  )

  if (warn) {
    really_remove <- are_you_sure(glue::glue(
      "remove member `{users}`"
    ))
    if (!really_remove) return(invisible(space))
  }

  space_id <- space_id(space)
  req <- rscloud_rest(path = c("spaces", space_id, "members", users),
                      verb = "DELETE")

  invisible(space)
}

#' @rdname space_member_remove
#' @export
space_member_remove.character <- function(space, users, warn = TRUE) {

  if (!is_valid_email(users)) stop(
    "`users` must be a single user ID or email. For removing multiple users please pass a data frame.",
    call = FALSE
  )

  id_to_remove <- space %>%
    space_member_list(filters = glue::glue("email:{tolower(users)}")) %>%
    dplyr::pull(.data$user_id)

  if (warn) {
    really_remove <- are_you_sure(glue::glue(
      "remove member <{tolower(users)}>"
    ))
    if (!really_remove) return(invisible(space))
  }

  space %>%
    space_member_remove.numeric(id_to_remove)
}

#' @rdname space_member_remove
#' @export
space_member_remove.data.frame <- function(space, users, warn = TRUE) {

  users <- if (!is.null(user_id <- users[["user_id"]])) {
    message("Using `user_id` column.")
    user_id
  } else if (!is.null(email <- users[["email"]])) {
    message("Using `email` column.")
    email
  } else {
    stop("`users` must contain a `user_id` or `email` column.",
         call. = FALSE)
  }

  if (warn) {
    really_remove <- are_you_sure(glue::glue(
      "remove {length(users)} members"
    ))
    if (!really_remove) return(invisible(space))
  }

  purrr::walk(users, ~ space_member_remove(space, .x, warn = FALSE))
  invisible(space)
}
