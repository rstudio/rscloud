# test space_member_add
test_that("member adding, invitation rescinding", {
  email <- tolower("mine+test201@rstudio.com")

  space <- rscloud_space(name = "test-space-1")
  value <- space %>% space_member_add(email)

  expect_identical(
    class(space),
    c("RSCloudSpace", "R6")
  )

  expect_snapshot_output(print(space))

  invitations <- space_invitation_list(space)
  expect_identical(
    invitations$email,
    email
  )

  value <- invitation_rescind(invitations$invitation_id)
  expect_null(value)

  expect_snapshot_output(print(space))
})

test_that("batch member adding/invitation rescinding", {
  emails <- c("mine+test202@rstudio.com", "mine+test203@rstudio.com")
  df <- tibble::tibble(user_email = emails)

  space <- rscloud_space(name = "test-space-1")

  value <- space %>% space_member_add(df)

  expect_identical(
    class(space),
    c("RSCloudSpace", "R6")
  )

  expect_snapshot_output(print(space))

  invitations <- space_invitation_list(space)
  expect_identical(
    invitations$email,
    emails
  )

  value <- invitations %>% invitation_rescind()
  expect_null(value)

  expect_snapshot_output(print(space))
})

# test space_member_usage
test_that("member usage for 90 days, returns tibble with 13 columns", {

  space <- rscloud_space(name = "test-space-1")

  usages <- space_member_usage(space, filters = list(groupby = "user_id", from = "90d"))

  expect_identical(
    class(usages),
    c("tbl_df", "tbl", "data.frame")
  )

  expect_identical(
    ncol(usages),
    13L
  )

  expect_equal(
    purrr::map_chr(vctrs::vec_ptype(usages), typeof),
    purrr::map_chr(vctrs::vec_ptype(rscloud_ptypes_90$usages), typeof)
  )

})

test_that("member usage for 30 days, returns tibble with 14 columns", {

  space <- rscloud_space(name = "test-space-1")

  usages <- space_member_usage(space, filters = list(groupby = "user_id", from = "30d"))

  expect_identical(
    class(usages),
    c("tbl_df", "tbl", "data.frame")
  )

  expect_identical(
    ncol(usages),
    14L
  )

  expect_equal(
    purrr::map_chr(vctrs::vec_ptype(usages), typeof),
    purrr::map_chr(vctrs::vec_ptype(rscloud_ptypes_30$usages), typeof)
  )

})
