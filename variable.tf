variable "app_ami_id" {

    default = "ami-07d8796a2b0f8d29c"

}

variable "db_ami_id" {

    default = "ami-0cf3a10afcf13b434"

}

variable "default_instance" {

    default = "t2.micro"

}

variable "keypair" {

    default = "eng103a_zilamo"

}

variable "public_ip_boolean" {

    default = true

}

variable "Name_tag" {

    default = { 
        "Name": "eng103a_zilamo_tf_app" 
    }

}

variable "Name_tagdb" {

    default = { 
        "Name": "eng103a_zilamo_tf_db" 
    }

}
variable "private_ip_boolean" {

    default = true

}
variable "nat_gateway_id" {

    default = "nat-0a54c9bd3b2eb6d1f"
}