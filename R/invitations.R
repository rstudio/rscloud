#' Retrieves the list of all outstanding invitations for the given space
#'
#' @param space_id id of the space we are interested in getting the invites for
#'
#' @export
invitations_for_space <- function(space_id) {
    invitations_url <- httr::modify_url(url = .globals$API_URL,
                                  path = c("v1", "invitations"),
                                  query = c(filter = paste0("space_id:", space_id)))

    req <- httr::GET(invitations_url,
                     httr::config(token = .globals$rscloud_token))

    httr::stop_for_status(req, paste0("Error retrieving invitations for: ", space_id))

    r <- httr::content(req)
    ff <- tibble::tibble(invitations = r$invitations)

    df <- ff %>% unnest_wider(invitations)

    #TODO: Debugging remove me.
    print(paste("There were ", nrow(df), "invitations"))

    df
}


#' Sends or resends the invitation to the recipient
#'
#' @param invitation_id is the id of an invitation that was previously created in the system.
#'
#' @export
send_invitation <- function(invitation_id) {
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

    invitations_url <- httr::modify_url(url = .globals$API_URL,
                                  path = c("v1", "invitations", invitation_id))

    req <- httr::DELETE(invitations_url,
                        httr::config(token = .globals$rscloud_token))

    httr::stop_for_status(req, paste0("Failed to remove invitation_id: ", invitation_id))

}

