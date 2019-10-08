test_that("default host", {
  expect_identical(
    rscloud_host_get(),
    "rstudio.cloud"
  )
})

test_that("respect env var `RSCLOUD_HOST`", {
  host <- "envvar.my.host"
  expect_identical(
    withr::with_envvar(
      list(RSCLOUD_HOST = host),
      rscloud_host_get()
    ),
    host
  )
})

test_that("`rscloud_host_set()` works", {
  host <- "my.host"
  rscloud_host_set(host)
  expect_identical(
    withr::with_envvar(
      list(RSCLOUD_HOST = "envvar.my.host"),
      rscloud_host_get()
    ),
    host
  )
  rscloud_host_set(NULL)
})

test_that("default api url", {
  expect_identical(
    rscloud_api_url_get(),
    "https://api.rstudio.cloud"
  )
})

test_that("respect env var `RSCLOUD_API_URL`", {
  api_url <- "https://envvar.my.api.url"
  expect_identical(
    withr::with_envvar(
      list(RSCLOUD_API_URL = api_url),
      rscloud_api_url_get()
    ),
    api_url
  )
})

test_that("`rscloud_api_url_set()` works", {
  api_url <- "https://my.api.url"
  rscloud_api_url_set(api_url)
  expect_identical(
    withr::with_envvar(
      list(RSCLOUD_HOST = "https://envvar.my.api.url"),
      rscloud_api_url_get()
    ),
    api_url
  )
  rscloud_api_url_set(NULL)
})
