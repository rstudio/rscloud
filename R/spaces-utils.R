RSCloudSpace <- R6::R6Class("RSCloudSpace",
  public = list(
    initialize = function(data) {
      private$data <- data
    },
    print = function(...) {
      # if last known active, poll
      if (identical(private$status, "ACTIVE")) private$update()

      msg <- if (identical(private$status, "ACTIVE")) {
        glue::glue(
        "RStudio Cloud Space (ID: {private$data$space_id})
        <{private$data$name}>
          users: {private$data$user_count} | projects: {private$data$project_count}
        "
        )
      } else {
        glue::glue("RStudio Cloud Space (DELETED)")
      }
      cat(msg)
    }
  ),
  active = list(
    space_id = function() {
      private$data$space_id
    }
  ),
  private = list(
    data = NULL,
    status = "ACTIVE",
    update = function() {
      res <- purrr::safely(rscloud_space_info)(private$data$space_id)
      private$data <- res$result
      if (!is.null(res$error)) {
        if (grepl("404", res$error$message)) {
          private$status <- "DELETED"
        } else {
          stop(res$error)
        }
      }

      invisible(NULL)
    }
  )
)

#' Space ID
#'
#' Get the ID of a space.
#'
#' @inheritParams space_info
#' @export
space_id <- function(space) space$space_id
