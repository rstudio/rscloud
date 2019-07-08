# rscloud
API wrappers for the rstudio.cloud service.  The initial release includes APIs for managing space memberships, and listing projects within a space. 

## Getting started

To get started you will need to create config.yml file that includes the following information. 

```yaml
default:
  CLIENT_ID: "YOUR CLIENT ID"
  CLIENT_SECRET: "YOUR CLIENT SECRET" 
```
As of June 17, 2019, you will need to reach out to the rstudio.cloud team to get your client ID and secret.  We expect to have it available in the UI over the summer.


To try this out you can start a session in your IDE or on rstudio.cloud and run the folllowing commands:

```R
install.packages("remotes")
remotes::install_github("rstudio/rscloud")

library(rscloud)

initialize_token()
spaces <- space_get()

# Assuming you have at least one space, those should return the members and the projects in the space
users <- space_user_get(spaces$space_id[[1]])
projects <- space_project_get(spaces$space_id[[1]])

# You can retrieve only public projects by passing in filters that limit visibility
projects <- space_project_get(spaces$space_id[[1]], filters = c("visibility:public"))

# To filter for projects that were updated since August 25, 2019 AND ones that are public by combining them in the filters
projects <- space_project_get(spaces$space_id[[1]], filters = c("updated_time:gt:2017-08-25T00:00:00", "visibility:public"))

```

