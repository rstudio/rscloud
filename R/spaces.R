#' Returns the spaces that this user has access to.
#' This will typically be the first call that a user makes to help determine which spaces they have access to and
#' to retrieve the space_ids that aare needed in many of the later calls for managing space memberships and invitations.
#'
#' @export
#'
get_spaces <- function() {

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  list_spaces_url <- httr::modify_url(url = .globals$API_URL,
                                      path = c("v1", "spaces"))

  req <- httr::GET(list_spaces_url,
                   httr::config(token = .globals$rscloud_token))

  httr::stop_for_status(req)
  json_list <- httr::content(req)

  if (length(json_list$spaces) == 0)
    stop("No spaces available for this user.", call. = FALSE)

  n_pages <- ceiling(json_list$total / json_list$count)

  batch_size <- json_list$count

  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {

    if (i == 1) {
      pages[[1]] <- json_list$spaces
    } else {
      req <- httr::GET(list_spaces_url,
                       httr::config(token = .globals$rscloud_token),
                       query=list("offset"=(i-1)*batch_size))
      httr::stop_for_status(req)
      json_list <- httr::content(req)

      pages[[i]] <- json_list$spaces
    }
  }

  ff <- tibble::tibble(spaces = pages)
  df <- ff %>%
    tidyr::unnest_longer(spaces) %>%
    tidyr::unnest_wider(spaces)

  df %>% dplyr::rename(space_id = id) %>%
    dplyr::select(space_id, name, description, dplyr::everything()) %>%
    dplyr::mutate(created_time = as.POSIXct(strptime(created_time, "%Y-%m-%dT%H:%M:%S")),
                  updated_time = as.POSIXct(strptime(updated_time, "%Y-%m-%dT%H:%M:%S")))
}

#' Returns the valid roles available for this space.
#'
#' @param space_id is an id of an existing space that the user has access to.
#'
#' @export
roles_for_space <- function(space_id) {

  if (!exists("API_URL", .globals))
    stop("Please run rscloud::initialize_token() prior calling any other functions",
         call. = FALSE)

  roles_for_space_url <- httr::modify_url(url = .globals$API_URL,
                                          path = c("v1", "spaces", space_id, "roles"))

  req <- httr::GET(roles_for_space_url,
                   httr::config(token = .globals$rscloud_token))

  # TODO: Need to test for a 403 since we can't change a space that we don't have the right permissions for
  httr::stop_for_status(req, "You do not have permission to modify the space membership")
  json_list <- httr::content(req)

  if (length(json_list$roles) == 0)
    stop("No roles found for this space", call. = FALSE)

  ff <- tibble::tibble(roles = json_list$roles)
  df <- ff %>% tidyr::unnest_wider(roles)
  df %>% dplyr::rename(role_id = id) %>%
    dplyr::select(space_id, role_id, role, dplyr::everything()) %>%
    dplyr::mutate(created_time = as.POSIXct(strptime(created_time, "%Y-%m-%dT%H:%M:%S")),
                  updated_time = as.POSIXct(strptime(updated_time, "%Y-%m-%dT%H:%M:%S")))
}

