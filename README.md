### Infrastructure as Code using GCP

This repo conatins setting up our networking resources such as Virtual Private Cloud (VPC), Internet Gateway, Route Table, and Routes. Terraform is used for infrastructure setup and tear down.

## Prerequisites

Google Cloud SDK: Install and configure the Google Cloud SDK on your local machine.

Terraform: Install Terraform on your local machine.

Google Cloud Platform Account: Create a project on GCP and set up billing.

## Steps

1. create provider.tf file to include google provider

2. create main.tf file to include vpc and subnet setup

3. create variables.tf to declare all the variables used

4. create terraform.tfvars to store all the confidential values

5. once all the setup is done, run the following -
    ```terraform init```
    ```terraform plan```
    ```terraform apply```

6. Enable Compute Engine API as part of the service and OS Login API is enabled by default
