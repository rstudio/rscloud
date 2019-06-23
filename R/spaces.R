#' Return spaces that user has access to
#'
#' This will typically be the first call that a user makes to help determine
#' which spaces they have access to and to retrieve the space IDs that are
#' needed in many of the later calls for managing space memberships and
#' invitations.
#'
#' @export
#'
space_get <- function() {
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


#' Return valid roles for space
#'
#' Returns valid roles for a given space and the permissions associated with each role.
#'
#' @param space_id ID number of the space
#'
#' @export
space_role <- function(space_id) {

  check_auth()

  json_list <- rscloud_GET(path = c("spaces", space_id, "roles"))

  if (length(json_list$roles) == 0) {
    # HW: would be better to return 0-row tibble with correct columns
    # But there's no way to get that from the json when the result is empty
    stop("No roles found for this space", call. = FALSE)
  }

  # It seems like roles isn't paginated today.  Adding some code to handle the day when it does become paginated.
  if (is.null(json_list$total) || is.null(json_list$count)) {
    n_pages <- 1
    batch_size <- 1
  } else {
    n_pages <- ceiling(json_list$total / json_list$count)
    batch_size <- json_list$count
  }

  pages <- vector("list", n_pages)

  for (i in seq_along(pages)) {
    if (i == 1) {
      pages[[1]] <- json_list$roles
    } else {
      offset <- (i - 1) * batch_size
      pages[[i]] <- rscloud_GET(path = c("spaces", space_id, "roles") ,
                                query = list(offset = offset),
                                task = paste("Error retrieving roles for space: ", space_id))$roles
    }
  }

  # Rectangling
  df <- tibble::tibble(roles = pages)
  df %>%
    tidyr::unnest_longer(roles) %>%
    tidyr::unnest_wider(roles) %>%
    parse_times() %>%
    dplyr::select(space_id, role_id = id, role, dplyr::everything())
}


#' Return projects in space
#'
#' Returns the projects in a given space.
#'
#' @param space_id ID number of the space
#' @param filters takes a named list with additional filters to be applied to the query
#'
#' @export
space_project_get <- function(space_id,
                              filters = NULL) {

  check_auth()

  query_list = list("filter" = paste0("space_id:", space_id))


  if (!is.null(filters)) {
    query_list = c(query_list, filters)
  }

  json_list <- rscloud_GET("projects",
                           query = query_list,
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
                                query = c(query_list,
                                          list(offset = offset)),
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

