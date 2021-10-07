# test space_project_list
test_that("project listing works", {
  space <- rscloud_space(name = "test-space-1")

  projs <- space %>%
    space_project_list() %>%
    dplyr::pull(name)

  expect_identical(projs, c("test-project-1", "test-project-2"))
})

test_that("no projects error", {
  space <- rscloud_space(name = "test-space-2")
  expect_error(
    space %>% space_project_list(),
    "No projects found\\."
  )
})
