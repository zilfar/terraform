# terrraform init will download any required packages
# provider aws
provider "aws" {

# which region
    region = "eu-west-1" 

# what do we want to launch
}

# init with terraform `terraform init`
# what do we want to launch
# automate the process of creating EC2 instance

# name of the resource
resource "aws_instance" "zilamo_tf_app" {

# which AMI to use
    ami = var.app_ami_id

# what type of instance
    instance_type = var.default_instance

# name the keypair
    key_name = var.keypair

# do you want public IP
    associate_public_ip_address = var.public_ip_boolean

# what is the name of your instance
    tags = {
        Name = var.Name_tag
    }
}