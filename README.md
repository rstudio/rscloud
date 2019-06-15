# rscloud
API wrappers for the rstudio.cloud service.  The initial release includes APIs for managing space memberships, and listing projects within a space. 

To get started please install using:

`remotes::install_github("rstudio/rscloud")`

To get started you will need to create config.yml file that includes the following information. 

```
default:
 CLIENT_ID: "YOUR CLIENT ID"
 CLIENT_SECRET: "YOUR CLIENT SECRET" 
```

You should be able to test out that it is working by running:

```
rscloud::initialize_token()

rscloud::get_spaces()

```

6/15/2019 Note: Some have reported issues getting the package to run locally due to the use of the github version of tidyr.  To install that, please run: `remotes::install_github("tidyverse/tidyr")`. 


