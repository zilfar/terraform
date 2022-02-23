# Intrastructure as code with Terraform
## What is Terraform
### Terraform Architecture
#### Terraform default file/folder structure
##### .gitignore
###### AWS Keys with Terraform security

## Installing Terraform

First we install choco: <br>
- Launch powershell with administrator rights:
`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

Next we install terraform: <br>
`choco install terraform` <br>
Next, we restart the powershell instance to refresh the environment variables. We can use Terraform now.

## Terraform Commands
- `terraform init` to initialise Terraform
- `terraform plan` checks the script
- `terraform apply` implements the script
- `terraform destroy` to delete everything

- Terraform file/folder structure
- `.tf` extension - e.g. `main.tf`
- Apply `DRY` (do not repeat yourself)

### Set up AWS keys as an ENV in windows machine
- `AWS_ACCES_KEY_ID` for aws access key
- `AWS_SECRET_ACCESS_KEY` for aws secret
- Click windows key - type `env` - edit the system env variable - New user variable - Create a new one for each of AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.