#' Retrieve list of outstanding invitations
#'
#' Retrieves the list of all outstanding invitations for the given space.
#'
#' @inheritParams space_info
#' @inheritParams rscloud_space_list
#'
#' @export
space_invitation_list <- function(space, filters = NULL) {
  space_id <- space_id(space)

  query_list <- filters %>%
    purrr::map(~list("filter" = .x)) %>%
    append(list("filter" = paste0("space_id:", space_id))) %>%
    purrr::flatten()

  response <- rscloud_rest(
    "invitations",
    query = query_list
  )

  verify_response_length(response, "invitations", filters)

  invitations <- collect_paginated(
    response = response,
    path = "invitations",
    query = query_list
  )

  invitations %>%
    tidy_list() %>%
    parse_times() %>%
    dplyr::rename(invitation_id = .data$id) %>%
    dplyr::select(.data$invitation_id, .data$space_id, .data$email,
                  .data$type,
                  .data$accepted, .data$expired, dplyr::everything()) %>%
    new_tbl_invitation()
}


#' Send or Resend Invitations
#'
#' Sends or resends invitation with a given invitation ID that was previously
#' created in RStudio Cloud. Invitation IDs are unique across all spaces, hence
#' this function does not also depend on a space ID.
#'
#' @param invitations An invitation ID number or a data frame
#'   of invitations returned by `space_invitation_list()`.
#'
#' @export
invitation_send <- function(invitations) {
  UseMethod("invitation_send")
}

#' @rdname invitation_send
#' @export
invitation_send.numeric <- function(invitations) {
  response <- rscloud_rest(
    path = c("invitations", invitations, "send"),
    verb = "POST"
  )

  invitation <- response %>%
    purrr::map_if(is.null, ~ NA) %>%
    purrr::map_if(is.list, ~list(.x)) %>%
    tibble::as_tibble() %>%
    new_tbl_invitation()

  invisible(invitation)
}

#' @rdname invitation_send
#' @export
invitation_send.tbl_invitation <- function(invitations) {
  invitations %>%
    dplyr::pull("invitation_id") %>%
    purrr::walk(~ invitation_send.numeric(.x))

  invisible(invitations)
}


#' Cancel Invitations
#'
#' Cancels existing invitations.
#'
#' @inheritParams invitation_send
#'
#' @export
invitation_rescind <- function(invitations) {
  UseMethod("invitation_rescind")
}

#' @rdname invitation_rescind
#' @export
invitation_rescind.numeric <- function(invitations) {
  req <- rscloud_rest(path = c("invitations", invitations), verb = "DELETE")
  invisible(NULL)
}

#' @rdname invitation_rescind
#' @export
invitation_rescind.tbl_invitation <- function(invitations) {
  invitations %>%
    dplyr::pull("invitation_id") %>%
    purrr::walk(~ invitation_rescind.numeric(.x))

  invisible(NULL)
}
