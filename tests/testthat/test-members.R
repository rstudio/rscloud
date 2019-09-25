test_that("member adding, invitation rescinding", {

  email <- tolower("kevin.kuo+test201@rstudio.com")

  space <- rscloud_space(name = "test-space-1")
  value <- space %>% space_member_add(email)

  expect_identical(
    class(space),
    c("RSCloudSpace", "R6")
  )

  expect_known_output(
    print(space),
    "output/space-print-2.txt"
  )

  invitations <- space_invitation_list(space)
  expect_identical(
    invitations$email,
    email
  )

  value <- invitation_rescind(invitations$invitation_id)
  expect_null(value)

  expect_known_output(
    print(space),
    "output/space-print-1.txt",
    update = FALSE
  )
})

test_that("batch member adding/invitation rescinding", {
  emails <- c("kevin.kuo+test202@rstudio.com", "kevin.kuo+test203@rstudio.com")
  df <- tibble::tibble(user_email = emails)

  space <- rscloud_space(name = "test-space-1")

  value <- space %>% space_member_add(df)

  expect_identical(
    class(space),
    c("RSCloudSpace", "R6")
  )

  expect_known_output(
    print(space),
    "output/space-print-3.txt"
  )

  invitations <- space_invitation_list(space)
  expect_identical(
    invitations$email,
    emails
  )

  value <- invitations %>% invitation_rescind()
  expect_null(value)

  expect_known_output(
    print(space),
    "output/space-print-1.txt",
    update = FALSE
  )
})
