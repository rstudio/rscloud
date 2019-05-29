# rscloud
API wrappers to the space and membership functions for rstudio.cloud.  

To get started please install using:

`remotes::install_github("rstudio/rscloud")`

To get started you will need to create config.yml file that includes the following information.

```
default:
 CLIENT_ID: "YOUR CLIENT ID"
 CLIENT_SECRET: "YOUR CLIENT SECRET" 
 BASE_URL: "staging.rstudio.cloud"
 API_URL: "api.staging.shinyapps.io"
```

You should be able to test out that it is working by running:

```
rscloud::initialize_token()

rscloud::get_spaces()

```


