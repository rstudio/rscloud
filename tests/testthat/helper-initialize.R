library(rscloud)

clean_up <- function() {
  space <- rscloud_space(name = "test-space-1")

  members <- space %>%
    space_member_list() %>%
    dplyr::filter(email != "rscloud.test.01@gmail.com")
  space %>%
    purrr::safely(space_member_remove)(members, content_action = 'leave_in_space', ask = FALSE)

  space %>%
    purrr::possibly(space_invitation_list, otherwise = NULL)() %>%
    purrr::safely(invitation_rescind)()
  invisible(NULL)
}

clean_up()
