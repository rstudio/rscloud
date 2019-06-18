



#' Returns the spaces that this user has access to.
#' This will typically be the first call that a user makes to help determine which spaces they have access to and
#' to retrieve the space_ids that aare needed in many of the later calls for managing space memberships and invitations.
#'
#' @export
#'
get_spaces <- function() {
  check_auth()

  # TODO:: Consider pulling out in rscloud_GET_paged
  # contents = "spaces"
  # json_list[[contents]] so you don't have to do metaprogramming
  json_list <- rscloud_GET("spaces", task = "Error retrieving spaces")

  if (length(json_list$spaces) == 0)
    stop("No spaces available for this user.", call. = FALSE)

  n_pages <- ceiling(json_list$total / json_list$count)
  batch_size <- json_list$count
  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {
    if (i == 1) {
      pages[[1]] <- json_list$spaces
    } else {
      offset <- (i - 1) * batch_size
      pages[[i]] <- rscloud_GET("spaces", query = list(offset = offset))$spaces
    }
  }

  # Rectangling
  ff <- tibble::tibble(spaces = pages)
  df <- ff %>%
    tidyr::unnest_longer(spaces) %>%
    tidyr::unnest_wider(spaces)

  df %>%
    dplyr::select(space_id = id, name, description, dplyr::everything()) %>%
    parse_times()
}

#' Returns the valid roles available for this space.
#'
#' @param space_id is an id of an existing space that the user has access to.
#'
#' @export
roles_for_space <- function(space_id) {

  check_auth()

  json_list <- rscloud_GET(path = c("spaces", space_id, "roles"))

  if (length(json_list$roles) == 0) {
    # HW: would be better to return 0-row tibble with correct columns
    # But there's no way to get that from the json when the result is empty
    stop("No roles found for this space", call. = FALSE)
  }

  ## TODO: Do we need to paginate on roles as well?

  ff <- tibble::tibble(roles = json_list$roles)
  df <- ff %>% tidyr::unnest_wider(roles)
  df %>%
    dplyr::select(space_id, role_id = id, role, dplyr::everything()) %>%
    parse_times()
}

#' Returns the projecst for this space
#'
#' @param space_id is an id of an existing space that the user has access to.
#'
#' @export
projects_for_space <- function(space_id) {

  check_auth()

  #TODO: Provide the ability to provide additional filters

  json_list <- rscloud_GET("projects",
                           query = list("filter" = paste0("space_id:", space_id)),
                           task = paste("Error retrieving projects for space: ",space_id)
                          )

  if (length(json_list$projects) == 0)
    stop("No projects found for this space", call. = FALSE)

  n_pages <- ceiling(json_list$total / json_list$count)
  batch_size <- json_list$count
  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {
    if (i == 1) {
      pages[[1]] <- json_list$projects
    } else {
      offset <- (i - 1) * batch_size
      pages[[i]] <- rscloud_GET("projects",
                                query = list("filter" = paste0("space_id:", space_id),
                                             offset = offset),
                                task = paste("Error retrieving projects for space: ", space_id))$projects
    }
  }

  # Rectangling
  df <- tibble::tibble(projects = pages)
  df %>%
    tidyr::unnest_longer(projects) %>%
    tidyr::unnest_wider(projects) %>%
    tidyr::hoist(author, display_name = "display_name") %>%
    parse_times() %>%
    dplyr::select(id, name, status, updated_time, display_name, author_id, visibility, created_time)
}
