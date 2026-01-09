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
  expect_error(rscloud_space(999999999), "No space found")
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

# test rscloud_space_create input validation
test_that("rscloud_space_create validates inputs", {
  expect_error(
    rscloud_space_create(name = 123, account_id = 1),
    "`name` must be a single character string"
  )

  expect_error(
    rscloud_space_create(name = c("a", "b"), account_id = 1),
    "`name` must be a single character string"
  )

  expect_error(
    rscloud_space_create(name = "test", account_id = "not a number"),
    "`account_id` must be a single integer"

  )

  expect_error(
    rscloud_space_create(name = "test", account_id = c(1, 2)),
    "`account_id` must be a single integer"
  )

  expect_error(
    rscloud_space_create(name = "test", account_id = 1, copy = "not a number"),
    "`copy` must be a single integer"
  )

  expect_error(
    rscloud_space_create(name = "test", account_id = 1, access = "invalid"),
    "'arg' should be one of"
  )
})

# test space lifecycle: create, archive, restore, delete
test_that("space lifecycle works", {
  # Get account_id from existing test space

  spaces <- rscloud_space_list()
  account_id <- spaces$account_id[1]


  # Create a new space
  space_name <- paste0("test-lifecycle-", format(Sys.time(), "%Y%m%d%H%M%S"))
  space <- rscloud_space_create(
    name = space_name,
    account_id = account_id,
    description = "Temporary test space for lifecycle tests"
  )

  expect_identical(class(space), c("RSCloudSpace", "R6"))

  # Verify space was created
  info <- space_info(space)
  expect_identical(info$name, space_name)
  expect_identical(info$state, "active")

  # Archive the space
  result <- rscloud_space_archive(space)
  expect_identical(class(result), c("RSCloudSpace", "R6"))

  # Verify space is archived

  info <- space_info(space)
  expect_identical(info$state, "archived")

  # Restore the space
  result <- rscloud_space_restore(space)
  expect_identical(class(result), c("RSCloudSpace", "R6"))

  # Verify space is active again
  info <- space_info(space)
  expect_identical(info$state, "active")

  # Delete the space (skip confirmation)
  result <- rscloud_space_delete(space, ask = FALSE)
  expect_null(result)

  # Verify space is deleted (should get 404)
  expect_error(space_info(space), "No space found")
})
