#' Returns the spaces that this user has access to.
#' This will typically be the first call that a user makes to help determine which spaces they have access to and
#' to retrieve the space_ids that aare needed in many of the later calls for managing space memberships and invitations.
#'
#' @export
#'
get_spaces <- function() {
    list_spaces_url <- httr::modify_url(url = .globals$API_URL,
                                  path = c("v1", "spaces"))

    req <- httr::GET(list_spaces_url,
                     httr::config(token = .globals$rscloud_token))

    httr::stop_for_status(req)
    json_list <- httr::content(req)

    ## TODO: Will need to paginate on those calls, but for now, let us grab the first one.
    ff <- tibble::tibble(spaces = json_list$spaces)
    df <- ff %>% tidyr::unnest_wider(spaces)

    df %>% dplyr::rename(space_id = id) %>%
      dplyr::select(space_id, name, description, dplyr::everything())
}

#' Returns the valid roles available for this space.
#'
#' @param space_id is an id of an existing space that the user has access to.
#'
#' @export
roles_for_space <- function(space_id) {
    roles_for_space_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "spaces", space_id, "roles"))

    req <- httr::GET(roles_for_space_url,
                     httr::config(token = .globals$rscloud_token))

    # TODO: Need to test for a 403 since we can't change a space that we don't have the right permissions for
    httr::stop_for_status(req, "You do not have permission to modify the space membership")
    json_list <- httr::content(req)

    ff <- tibble::tibble(roles = json_list$roles)
    df <- ff %>% tidyr::unnest_wider(roles)
    df %>% dplyr::rename(role_id = id) %>%
      dplyr::select(space_id, role_id, role, dplyr::everything())
}

