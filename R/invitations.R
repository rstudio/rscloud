#' Retrieves the list of all outstanding invitations for the given space
#'
#' @param space_id id of the space we are interested in getting the invites for
#'
#' @export
invitations_for_space <- function(space_id) {

  check_auth()

  json_list <- rscloud_GET("invitations",
                             query = list("filter" = paste0("space_id:", space_id)),
                             task = paste0("Error retrieving invitations for: ", space_id))


  if(length(json_list$invitations) == 0)
    stop(paste0("No invitations found for space: ", space_id), call. = FALSE)

  n_pages <- ceiling(json_list$total / json_list$count)

  batch_size <- json_list$count

  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {
    if (i == 1) {
      pages[[1]] <- json_list$invitations
    } else {
      pages[[i]] <- rsconnect_GET("invitations",
                    query = list("filter" = paste0("space_id:", space_id),
                                 "offset" = (i-1)*batch_size),
                    task = paste0("Error retrieving invitations for: ", space_id)
                    )$invitations
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
  check_auth()

  req <- rscloud_POST(path = c("invitations", invitation_id, "send"),
                      task = paste0("Error resending invitation: ", invitation_id))

  r <- httr::content(req)

  tidyr::spread(tibble::enframe(r), name, value)
}

#' Cancels an existing invitation.
#'
#' @param invitation_id is the id of an invitation that was previously created in the system.
#'
#' @export
rescind_invitation <- function(invitation_id) {

  check_auth()

  req <- rscloud_DELETE(path = c("invitations", invitation_id),
                        task = paste0("Failed to remove invitation_id: ", invitation_id))
}

