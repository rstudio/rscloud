#' Returns the list of members for this space.
#' @param space_id is the id of the space that the user has access to
members_for_space <- function(space_id) {
  members_for_space_url <- httr::modify_url(url = .globals$API_URL,
                                            path = c("v1", "spaces", space_id, "members"))

  req <- httr::GET(members_for_space_url,
                   httr::config(token = .globals$rscloud_token))
  httr::stop_for_status(req)
  json_list <- httr::content(req)

  ff <- tibble::tibble(users = json_list$users)
  df <- ff %>% tidyr::unnest_wider(users)
  # TODO: Re-order the headings
  df
}

#' Invite a user by email addrss to the space.
#'
#' @param user_email email address of the user to add
#' @param email_invite indicates whether an email should be sent to the user with the invite
#' @param email_message the message to be sent to the user should the email_invite flag be set to TRUE
#' @param space_role the desired role for the user in the space
#' @param access_code TODO: No idea what this does, need to talk to the team about it :)
add_user_to_space <- function(user_email, space_id,
                              email_message = "You are invited to this space",
                              email_invite = TRUE, space_role = "contributor",
                              access_code = NULL) {

  roles <- roles_for_space(space_id)

  if (!space_role %in% roles$role)
    stop(paste0("Role: ", space_role, " isn't a valid role for space: ", space_id))

  user <- list(email = user_email, space_role = space_role)


  if (email_invite) {
    user <<- c(user, invite_email = email_invite, invite_email_message = email_message)
  }

  if (!is.null(access_code)) {
    user <<- c(user, access_code = access_code)
  }

  add_member_url <- httr::modify_url(url = .globals$API_URL,
                                     path = c("v1", "spaces", space_id, "members"))

  req <- httr::POST(add_member_url, body = user, encode = "json",
                    httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, paste0("Error adding user: ", user_email))
  r <- httr::content(req)
  r
}

#' Removes the given user_id from the space
#'
#' @param user_id the id of the user to be remoed from the space
#' @param space_id the id for the space to be modified
#'
remove_user_from_space <- function(user_id, space_id) {
  remove_user_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "spaces", space_id, "members", user_id))

  req <- httr::DELETE(remove_user_url,
                      httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, paste0("Failed to remove user_id: ", user_id))

}
