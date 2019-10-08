
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rscloud

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/rstudio/rscloud.svg?branch=master)](https://travis-ci.org/rstudio/rscloud)
[![Codecov test
coverage](https://codecov.io/gh/rstudio/rscloud/branch/master/graph/badge.svg)](https://codecov.io/gh/rstudio/rscloud?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
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
#> # A tibble: 2 x 16
#>   space_id name  description project_count user_count account_id
#>      <int> <chr> <chr>               <int>      <int>      <int>
#> 1    31783 test… foo bar                 2          1     326004
#> 2    31785 test… foo bar two             0          1     326004
#> # … with 10 more variables: project_max <int>, visibility <chr>,
#> #   updated_time <dttm>, access <chr>, created_time <dttm>,
#> #   default_project_id <lgl>, default_member_role <chr>,
#> #   access_code <lgl>, permissions <list>, user_max <int>
```

To create a space object, use the `rscloud_space()` function:

``` r
space <- rscloud_space(31783)
# you can also use the space name
# space <- rstudio_space(name = "test-space-1")
space
#> RStudio Cloud Space (ID: 31783)
#> <test-space-1>
#>   users: 1 | projects: 2
```

Adding members to a space can be done via `space_member_add()`:

``` r
space %>% 
  space_member_add("kevin.kuo+test1@rstudio.com")

space
#> RStudio Cloud Space (ID: 31783)
#> <test-space-1>
#>   users: 2 | projects: 2
```

You can get a tidy data frame of space members with
`space_member_list()`:

``` r
space %>% 
  space_member_list()
#> # A tibble: 2 x 21
#>   user_id display_name email updated_time        created_time       
#>     <int> <chr>        <chr> <dttm>              <dttm>             
#> 1  370063 rscloud0 ke… kevi… 2019-09-25 20:30:11 2019-09-24 04:41:46
#> 2  370067 rscloud1 ke… kevi… 2019-09-24 04:46:43 2019-09-24 04:46:33
#> # … with 16 more variables: github_auth_token <lgl>, first_name <chr>,
#> #   last_name <chr>, grant <list>, login_attempts <int>,
#> #   email_verified <lgl>, picture_url <chr>, github_auth_id <lgl>,
#> #   lockout_until <lgl>, local_auth <lgl>, location <chr>,
#> #   last_login_attempt <chr>, organization <chr>, referral <lgl>,
#> #   homepage <lgl>, google_auth_id <lgl>
```

You can also provide a data frame of user information, which can be
useful when working with spreadsheets of class
rosters:

``` r
emails <- c("kevin.kuo+test2@rstudio.com", "kevin.kuo+test3@rstudio.com")
df <- tibble::tibble(user_email = emails)

space %>% 
  space_member_add(df)

space
#> RStudio Cloud Space (ID: 31783)
#> <test-space-1>
#>   users: 4 | projects: 2
```

You can also work with outstanding invitations:

``` r
invitations <- space %>% 
  space_invitation_list()

invitations
#> # A tibble: 2 x 15
#>   invitation_id space_id email type  accepted expired redirect accepted_by
#>           <int>    <int> <chr> <chr> <lgl>    <lgl>   <chr>    <lgl>      
#> 1         69227    31783 kevi… spac… FALSE    FALSE   https:/… NA         
#> 2         69228    31783 kevi… spac… FALSE    FALSE   https:/… NA         
#> # … with 7 more variables: updated_time <dttm>, sender <list>,
#> #   space_role <chr>, link <chr>, branding <chr>, created_time <dttm>,
#> #   message <lgl>
```

To resend invitations, use the `invitation_send()` function:

``` r
invitations %>% 
  # filter(...) %>% 
  invitation_send()
```
