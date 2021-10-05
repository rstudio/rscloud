RSCloudSpace <- R6::R6Class("RSCloudSpace",
  public = list(
    initialize = function(data) {
      private$id <- data$space_id
    },
    print = function(...) {
      # if last known active, poll
      info <- if (identical(private$status, "ACTIVE")) private$get_info()

      msg <- if (identical(private$status, "ACTIVE")) {
        glue::glue(
          "RStudio Cloud Space (ID: {private$id})
        <{info$name}>
          users: {info$user_count} | projects: {info$project_count}
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
      private$id
    }
  ),
  private = list(
    id = NULL,
    status = "ACTIVE",
    get_info = function() {
      res <- purrr::safely(rscloud_space_info)(private$id)

      if (!is.null(res$error)) {
        if (grepl("404", res$error$message)) {
          private$status <- "DELETED"
          NULL
        } else {
          stop(res$error)
        }
      }

      res$result
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
