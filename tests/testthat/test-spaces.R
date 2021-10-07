# test rscloud_space_list
test_that("space listing works", {
  library(dplyr)
  df <- rscloud_space_list() %>%
    filter(name == "test-space-1")

  expect_identical(
    df$description,
    "Test space for the rscloud package"
  )
})

# test rscloud_space
test_that("space consutructor works", {
  expect_error(test_space_id <- space_id(rscloud_space(name = "test-space-1")), NA)
  expect_error(rscloud_space(test_space_id), NA)
})

test_that("space constructor gives informative errors", {
  # 404
  expect_error(rscloud_space(999999999), "Not Found")

  # 403
  expect_error(rscloud_space(1), "Forbidden")
})

test_that("space print method", {
  space <- rscloud_space(name = "test-space-1")
  expect_snapshot_output(print(space))
})

test_that("space_role_list() works", {
  space <- rscloud_space(name = "test-space-1")
  roles <- space %>%
    space_role_list()

  expect_identical(
    roles$role,
    c("contributor", "viewer", "admin", "moderator")
  )
})
