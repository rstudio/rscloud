#' Returns the list of members for this space.
#' @param space_id is the id of the space that the user has access to
#'
#' @export
members_for_space <- function(space_id) {

  check_auth()

  json_list <- rscloud_GET(path = c("spaces", space_id, "members"),
                           task = paste("Error retrieving members for space: ", space_id)
                           )

  if (length(json_list$users) == 0)
    stop(paste0("No users found for space: ", space_id),
         call. = FALSE)

  n_pages <- ceiling(json_list$total / json_list$count)

  batch_size <- json_list$count

  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {

    if (i == 1) {
      pages[[1]] <- json_list$users
    } else {
      offset <- (i - 1) * batch_size
      pages[[i]] <- rscloud_GET(path = c("spaces", space_id, "members"),
                                query = list(offset = offset),
                                task = paste("Error retrieving members for space: ", space_id)
                                )$users
    }
  }

  # Rectangling
  ff <- tibble::tibble(users = pages)
  df <- ff %>%
    tidyr::unnest_longer(users) %>%
    tidyr::unnest_wider(users)

  df %>%
    dplyr::select(user_id = id, email, display_name, updated_time,
           created_time, login_attempts, dplyr::everything()) %>%
    parse_times()
}

#' Invite a user by email addrss to the space.
#'
#' @param user_email email address of the user to add
#' @param email_invite indicates whether an email should be sent to the user with the invite
#' @param email_message the message to be sent to the user should the email_invite flag be set to TRUE
#' @param space_role the desired role for the user in the space
#'
#' @export
add_user_to_space <- function(user_email, space_id,
                              email_message = "You are invited to this space",
                              email_invite = TRUE, space_role = "contributor") {

  check_auth()

  roles <- roles_for_space(space_id)

  if (!space_role %in% roles$role)
    stop(paste0("Role: ", space_role, " isn't a valid role for space: ", space_id))

  user <- list(email = user_email, space_role = space_role)


  if (email_invite) {
    user <- c(user, invite_email = email_invite, invite_email_message = email_message)
  }

  req <- rscloud_POST(path = c("spaces", space_id, "members"),
                      body = user)
}

#' Removes the given user_id from the space
#'
#' @param user_id the id of the user to be remoed from the space
#' @param space_id the id for the space to be modified
#'
#' @export
remove_user_from_space <- function(user_id, space_id) {

  check_auth()

  rscloud_DELETE(path = c("spaces", space_id, "members", user_id),
                 task = paste0("Failed to remove user_id: ", user_id))
}
