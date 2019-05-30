#' Retrieves the list of all outstanding invitations for the given space
#'
#' @param space_id id of the space we are interested in getting the invites for
#'
#' @export
invitations_for_space <- function(space_id) {

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  invitations_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "invitations"))

  req <- httr::GET(invitations_url,
                   httr::config(token = .globals$rscloud_token),
                   query = list("filter" = paste0("space_id:", space_id)))

  httr::stop_for_status(req, paste0("Error retrieving invitations for: ", space_id))

  json_list <- httr::content(req)

  n_pages <- ceiling(json_list$total / json_list$count)

  batch_size <- json_list$count

  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {
    if (i == 1) {
      pages[[1]] <- json_list$invitations
    } else {
      req <- httr::GET(invitations_url,
                       httr::config(token = .globals$rscloud_token),
                       query=list("filter" = paste0("space_id:", space_id),
                                  "offset" = (i-1)*batch_size))

      httr::stop_for_status(req, paste0("Error retrieving invitations for: ", space_id))

      json_list <- httr::content(req)
      pages[[i]] <- json_list$invitations
    }
  }

  ff <- tibble::tibble(invitations = pages)

  if (nrow(ff) == 0)
    stop("There are no invitations for this space", call. = FALSE)

  df <- ff %>%
    tidyr::unnest_longer(invitations) %>%
    tidyr::unnest_wider(invitations)

  df %>% dplyr::rename(invitation_id = id) %>%
    dplyr::select(invitation_id, space_id, email, type,
                  accepted, expired, dplyr::everything())
}


#' Sends or resends the invitation to the recipient
#'
#' @param invitation_id is the id of an invitation that was previously created in the system.
#'
#' @export
send_invitation <- function(invitation_id) {
  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  invitations_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "invitations", invitation_id, "send"))

  req <- httr::POST(invitations_url,
                    httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, paste0("Error resending invitation: ", invitation_id))
  r <- httr::content(req)

  tidyr::spread(tidyr::enframe(r), name, value)
}

#' Cancels an existing invitation.
#'
#' @param invitation_id is the id of an invitation that was previously created in the system.
#'
#' @export
rescind_invitation <- function(invitation_id) {

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  invitations_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "invitations", invitation_id))

  req <- httr::DELETE(invitations_url,
                      httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req, paste0("Failed to remove invitation_id: ", invitation_id))

}

