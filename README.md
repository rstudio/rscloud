# rscloud
API wrappers to the space and membership functions for rstudio.cloud.  

To get started please install using:

`remotes::install_github("rstudio/rscloud")`

To get started you will need to create config.yml file that includes the following information for staging.

```
default:
 CLIENT_ID: "YOUR CLIENT ID"
 CLIENT_SECRET: "YOUR CLIENT SECRET" 
 BASE_URL: "staging.rstudio.cloud"
 API_URL: "api.staging.shinyapps.io"
```

For production you would configure it as follows:

```
default:
 CLIENT_ID: "YOUR CLIENT ID"
 CLIENT_SECRET: "YOUR CLIENT SECRET" 
 BASE_URL: "rstudio.cloud"
 API_URL: "api.shinyapps.io"
```


You should be able to test out that it is working by running:

```
rscloud::initialize_token()

rscloud::get_spaces()

```

**NOTE:** Please select 2 when httr asks if you want to cache with httr-oauth since we haven't implemented the refresh protocol in our oauth flows.  If you do cache it, you will want to delete the .httr-oauth when everything stops working 61 minutes later :)


