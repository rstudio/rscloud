
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rscloud

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/rstudio/rscloud.svg?branch=master)](https://travis-ci.org/rstudio/rscloud)
[![Codecov test
coverage](https://codecov.io/gh/rstudio/rscloud/branch/master/graph/badge.svg)](https://codecov.io/gh/rstudio/rscloud?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

API wrappers for the rstudio.cloud service. The initial release includes
APIs for managing space memberships, and listing projects within a
space.

## Getting started

To get started, you’ll need to obtain credentials from the RStudio Cloud
team and set the environment variables `RSCLOUD_CLIENT_ID` and
`RSCLOUD_CLIENT_SECRET`. The recommended way to set these is by editing
your `.Renviron` file. This can be easily done by calling the
`usethis::edit_r_environ()` function. Your `.Renviron` file may look
something like the following:

    RSCLOUD_CLIENT_ID=xxxxxxx
    RSCLOUD_CLIENT_SECRET=zzzzzzz

You can install the development version of rscloud as follows:

``` r
install.packages("remotes")
remotes::install_github("rstudio/rscloud")
```

The entry point to most of the functionality is a *space*. To see the
list of spaces you have access to, you can use the
`rscloud_space_list()` function:

``` r
library(rscloud)
rscloud_space_list()
#> # A tibble: 1 × 17
#>   space_id name         description project_count user_count account_id project_max
#>      <int> <chr>        <chr>               <int>      <int>      <int>       <int>
#> 1   178750 test-space-1 Test space…             0          1    1093053       10000
#> # … with 10 more variables: visibility <chr>, space_role <chr>, access <chr>,
#> #   created_time <dttm>, default_project_id <lgl>, default_member_role <chr>,
#> #   access_code <lgl>, permissions <list>, updated_time <dttm>, user_max <int>
```

To create a space object, use the `rscloud_space()` function:

``` r
space <- rscloud_space(178750)
# you can also use the space name
# space <- rstudio_space(name = "test-space-1")
space
#> RStudio Cloud Space (ID: 178750)
#> <test-space-1>
#>   users: 1 | projects: 0
```

Adding members to a space can be done via `space_member_add()`:

``` r
space %>% 
  space_member_add("mine+test1@rstudio.com")

space
#> RStudio Cloud Space (ID: 178750)
#> <test-space-1>
#>   users: 2 | projects: 0
```

You can get a tidy data frame of space members with
`space_member_list()`:

``` r
space %>% 
  space_member_list()
#> # A tibble: 1 × 22
#>   user_id display_name  email  updated_time        created_time        last_name
#>     <int> <chr>         <chr>  <dttm>              <dttm>              <chr>    
#> 1 1165199 RStudio Clou… rsclo… 2021-10-05 18:34:36 2021-10-05 18:26:25 Cloud Te…
#> # … with 16 more variables: github_auth_id <lgl>, sso_account_id <lgl>,
#> #   github_auth_token <lgl>, first_name <chr>, grant <list>, picture_url <chr>,
#> #   login_attempts <int>, lockout_until <lgl>, location <chr>, homepage <chr>,
#> #   last_login_attempt <lgl>, google_auth_id <chr>, email_verified <lgl>,
#> #   local_auth <lgl>, organization <chr>, referral <lgl>
```

You can also provide a data frame of user information, which can be
useful when working with spreadsheets of class rosters:

``` r
roster <- tibble::tribble(
  ~user_email,
  "mine+test2@rstudio.com", 
  "mine+test3@rstudio.com"
)

space %>% 
  space_member_add(roster)

space
#> RStudio Cloud Space (ID: 178750)
#> <test-space-1>
#>   users: 4 | projects: 0
```

You can also work with outstanding invitations:

``` r
invitations <- space %>% 
  space_invitation_list()

invitations
#> # A tibble: 3 × 16
#>   invitation_id space_id email   type   accepted expired redirect    accepted_by
#>           <int>    <int> <chr>   <chr>  <lgl>    <lgl>   <chr>       <lgl>      
#> 1        202139   178750 mine+t… space… FALSE    FALSE   https://rs… NA         
#> 2        202140   178750 mine+t… space… FALSE    FALSE   https://rs… NA         
#> 3        202141   178750 mine+t… space… FALSE    FALSE   https://rs… NA         
#> # … with 8 more variables: updated_time <dttm>, sender <list>,
#> #   sso_enabled <lgl>, space_role <chr>, link <chr>, branding <chr>,
#> #   created_time <dttm>, message <lgl>
```

To resend invitations, use the `invitation_send()` function:

``` r
invitations %>% 
  # filter(...) %>% 
  invitation_send()
```
