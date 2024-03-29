% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/members.R
\name{space_member_add}
\alias{space_member_add}
\alias{space_member_add.character}
\alias{space_member_add.data.frame}
\title{Invite Users}
\usage{
space_member_add(space, users, ...)

\method{space_member_add}{character}(
  space,
  users,
  email_invite = TRUE,
  email_message = NULL,
  space_role = "contributor",
  ...
)

\method{space_member_add}{data.frame}(space, users, ...)
}
\arguments{
\item{space}{A space object created using \code{rscloud_space()}.}

\item{users}{Email address of the user to add or a data frame of user information.}

\item{...}{Additional arguments.}

\item{email_invite}{Indicates whether an email should be sent to the user with the invite, \code{TRUE} by default}

\item{email_message}{Message to be sent to the user should the \code{email_invite} flag be set to \code{TRUE}}

\item{space_role}{Desired role for the user in the space}
}
\description{
Invites users to a space.
}
\details{
The \code{users} input should be a data frame consisting of the columns "user_email",
"email_invite", "email_message", and "space_role". Each row of the \code{users} data frame
denotes one user to be added. If any of these properties are specified in \code{...}, they
will take precendence and a message printed.
}
