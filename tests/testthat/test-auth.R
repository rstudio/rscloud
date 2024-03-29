test_that("whoami works", {
  expect_output(
    rscloud_whoami(),
    "RStudio Cloud Test 01 <rscloud\\.test\\.01@gmail\\.com>"
  )
})

test_that("informative error on bad auth", {
  expect_condition(
    withr::with_envvar(
      list(RSCLOUD_CLIENT_SECRET = "foo"),
      rscloud_authenticate(force = TRUE)
    ),
    "Unauthorized \\(HTTP 401\\)\\. Failed to get an access token\\. Confirm that the environment variables
    `RSCLOUD_CLIENT_ID` and `RSCLOUD_CLIENT_SECRET` are set correctly\\.",
    class = "http_401"
  )
})
