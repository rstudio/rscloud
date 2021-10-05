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
