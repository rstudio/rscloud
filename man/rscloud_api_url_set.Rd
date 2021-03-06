% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{rscloud_api_url_set}
\alias{rscloud_api_url_set}
\alias{rscloud_api_url_get}
\alias{rscloud_host_set}
\alias{rscloud_host_get}
\title{Configuring RStudio Cloud Host and API URL}
\usage{
rscloud_api_url_set(url)

rscloud_api_url_get()

rscloud_host_set(host)

rscloud_host_get()
}
\arguments{
\item{url}{The URL for the RStudio Cloud API.}

\item{host}{The hostname of the RStudio Cloud service.}
}
\description{
These functions configure the host and API URL settings for
  authentication and requests. See details for setting preferences.
}
\details{
The rscloud package reads host and API URL settings
  in this order:
\enumerate{
  \item The value set by the user using `rscloud_api_url_set()` or `rscloud_host_set()`
  \item The environment variables `RSCLOUD_API_URL` and `RSCLOUD_HOST`
  \item The defaults `https://api.rstudio.cloud` and `rstudio.cloud`
}
}
