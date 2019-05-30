#' Returns the list of members for this space.
#' @param space_id is the id of the space that the user has access to
#'
#' @export
members_for_space <- function(space_id) {

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)


  members_for_space_url <- httr::modify_url(url = .globals$API_URL,
                                            path = c("v1", "spaces", space_id, "members"))

  req <- httr::GET(members_for_space_url,
                   httr::config(token = .globals$rscloud_token))
  httr::stop_for_status(req)
  json_list <- httr::content(req)

  n_pages <- ceiling(json_list$total / json_list$count)

  batch_size <- json_list$count

  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {

    if (i == 1) {
      pages[[1]] <- json_list$users
    } else {
      req <- httr::GET(members_for_space_url,
                       httr::config(token = .globals$rscloud_token),
                       query=list("offset"=(i-1)*batch_size))
      httr::stop_for_status(req)
      json_list <- httr::content(req)

      pages[[i]] <- json_list$users

    }
  }

  ff <- tibble::tibble(users = pages)
  df <- ff %>%
    tidyr::unnest_longer(users) %>%
    tidyr::unnest_wider(users)

  df %>% dplyr::rename(user_id = id) %>%
    dplyr::select(user_id, email, display_name, updated_time,
           created_time, login_attempts, dplyr::everything())
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

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  roles <- roles_for_space(space_id)

  if (!space_role %in% roles$role)
    stop(paste0("Role: ", space_role, " isn't a valid role for space: ", space_id))

  user <- list(email = user_email, space_role = space_role)


  if (email_invite) {
    user <- c(user, invite_email = email_invite, invite_email_message = email_message)
  }

  add_member_url <- httr::modify_url(url = .globals$API_URL,
                                     path = c("v1", "spaces", space_id, "members"))

  req <- httr::POST(add_member_url, body = user, encode = "json",
                    httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, paste0("Error adding user: ", user_email))
}

#' Removes the given user_id from the space
#'
#' @param user_id the id of the user to be remoed from the space
#' @param space_id the id for the space to be modified
#'
#' @export
remove_user_from_space <- function(user_id, space_id) {

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  remove_user_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "spaces", space_id, "members", user_id))

  req <- httr::DELETE(remove_user_url,
                      httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, paste0("Failed to remove user_id: ", user_id))

}
