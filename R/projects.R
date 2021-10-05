#' List Projects
#'
#' Returns the projects in a given space.
#'
#' @inheritParams space_info
#' @inheritParams rscloud_space_list
#'
#' @export
space_project_list <- function(space, filters = NULL) {
  space_id <- space_id(space)
  query_list <- filters %>%
    purrr::map(~ list("filter" = .x)) %>%
    append(list("filter" = paste0("space_id:", space_id))) %>%
    purrr::flatten()

  response <- rscloud_rest("projects",
    query = query_list
  )

  verify_response_length(response, "projects", filters)

  projects <- collect_paginated(response, path = "projects", query = query_list)

  projects %>%
    tidy_list() %>%
    tidyr::hoist(.data$author, display_name = "display_name") %>%
    parse_times() %>%
    dplyr::select(
      .data$id, .data$name, .data$display_name, .data$author_id,
      .data$status,
      .data$updated_time,
      .data$visibility,
      .data$created_time, dplyr::everything()
    )
}
