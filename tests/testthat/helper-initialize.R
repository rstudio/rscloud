library(rscloud)
# clean up
space <- rscloud_space(name = "test-space-1")

members <- space %>%
  space_member_list() %>%
  dplyr::filter(email != "kevin.kuo+rscloud@rstudio.com")
space %>%
  purrr::safely(space_member_remove)(members, ask = FALSE)

space %>%
  purrr::possibly(space_invitation_list, otherwise =NULL)() %>%
  purrr::safely(invitation_rescind)()
