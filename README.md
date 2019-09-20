# rscloud

API wrappers for the rstudio.cloud service.  The initial release includes APIs for managing space memberships, and listing projects within a space. 

## Getting started

To get started, you'll need to obtain credentials from the RStudio Cloud team and set the environment variables `RSCLOUD_CLIENT_ID` and `RSCLOUD_CLIENT_SECRET`. The recommended way to set these is by editing your `.Renviron` file. This can be easily done by calling the `usethis::edit_r_environ()` function. Your `.Renviron` file may look something like the following:

```
RSCLOUD_CLIENT_ID=xxxxxxx
RSCLOUD_CLIENT_SECRET=zzzzzzz
```

To try this out you can start a session in your IDE or on rstudio.cloud and run the folllowing commands:

```R
install.packages("remotes")
remotes::install_github("rstudio/rscloud")

library(rscloud)

spaces <- space_get()

# Assuming you have at least one space, those should return the members and the projects in the space
users <- space_member_get(spaces$space_id[[1]])
projects <- space_project_get(spaces$space_id[[1]])

# You can retrieve only public projects by passing in filters that limit visibility
projects <- space_project_get(spaces$space_id[[1]], filters = c("visibility:public"))

# To filter for projects that were updated since August 25, 2019 AND ones that are public by combining them in the filters
projects <- space_project_get(spaces$space_id[[1]], filters = c("updated_time:gt:2017-08-25T00:00:00", "visibility:public"))

```

