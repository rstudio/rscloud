% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/members.R
\name{space_member_list}
\alias{space_member_list}
\title{Get list of members for space}
\usage{
space_member_list(space, filters = NULL)
}
\arguments{
\item{space}{A space object created using \code{rscloud_space()}.}

\item{filters}{A vector of filters to be AND'ed and applied to the request.}
}
\description{
Returns the list of members for a given space. You must either be the admin
of the space or your role must have permissions to see the members list.
}
