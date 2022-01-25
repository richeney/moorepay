# Moorepay testing

1. Accept marketplace terms

    ```bash
    az term accept \
      --product "microsoftserveroperatingsystems-previews" \
      --publisher "microsoftwindowsserver" \
      --plan "windows-server-2022-azure-edition-preview"
    ```

1. Clone the repo
1. Change directory
1. Initialise Terraform
1. Deploy the environment
