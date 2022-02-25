# terrraform init will download any required packages
# provider aws
provider "aws" {

# which region
    region = "eu-west-1" 
}

# vpc data stored
data "aws_vpc" "selected" {

    tags = {
        Name = "eng103a_zilamo_terraform_vpc_test"
    }



}

# setting up app security group
resource "aws_security_group" "app_security_group" {

    name = "app_security_group"
    description = "public security group for the app"
    vpc_id = data.aws_vpc.selected.id

    ingress {
        description = "allow port 80"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        description = "allow port 3000"
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        description = "allow port 22"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "eng103a_zilamo_app_terraform_SG"
    }
}

# setting up database security group
resource "aws_security_group" "db_security_group" {

    name = "db_security_group"
    description = "public security group for the app"
    vpc_id = data.aws_vpc.selected.id

    ingress {
        description = "allow port 27017"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = [data.aws_vpc.selected.cidr_block]
        ipv6_cidr_blocks = [data.aws_vpc.selected.cidr_block]
    }

    ingress {
        description = "allow port 22"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "eng103a_zilamo_db_terraform_SG"
    }
} 

# setting up the first public subnet in eu-west-1a
resource "aws_subnet" "create_public_subnet" {

    vpc_id = data.aws_vpc.selected.id
    cidr_block = "10.0.20.0/24"
    tags = {

        Name = "eng103a_zilamo_public_subnet"
    }
    availability_zone = "eu-west-1a"
}

# setting up the second public subnet in eu-west-1b
resource "aws_subnet" "create_public_subnet2" {

    vpc_id = data.aws_vpc.selected.id
    cidr_block = "10.0.21.0/24"
    tags = {

        Name = "eng103a_zilamo_public_subnet2"
    }
    availability_zone = "eu-west-1b"
}
# setting up the third public subnet in eu-west-1c
resource "aws_subnet" "create_public_subnet3" {

    vpc_id = data.aws_vpc.selected.id
    cidr_block = "10.0.22.0/24"
    tags = {

        Name = "eng103a_zilamo_public_subnet3"
    }
    availability_zone = "eu-west-1c"
}


# launch database instance
resource "aws_instance" "zilamo_tf_db" {

# which AMI to use
    ami = var.db_ami_id

# what type of instance
    instance_type = var.default_instance

# name the keypair
    key_name = var.keypair

# do you want public IP
    associate_public_ip_address = var.public_ip_boolean
    subnet_id = aws_subnet.create_public_subnet.id
    vpc_security_group_ids = [aws_security_group.db_security_group.id]


# what is the name of your instance
    tags = var.Name_tagdb
 }

resource "aws_vpc" "terraform_vpc_code_test" {

    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    tags = {

        Name = "eng103a_zilamo_terraform_vpc_test"
    }


}

# internet gateway for the routing table
resource "aws_internet_gateway" "int_gateway" {
    vpc_id = data.aws_vpc.selected.id
}

#routing tables for the subnets
resource "aws_route_table" "public_route_table" {
    vpc_id = data.aws_vpc.selected.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.int_gateway.id
    }

    tags = {
        Name = "public_route_table"
    }
}
# resource "aws_route_table" "private_route_table" {
#     vpc_id = data.aws_vpc.selected.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         nat_gateway_id = var.nat_gateway_id
#     }

#     tags = {
#         Name = "private_route_table"
#     }
# }

# associating route table with subnet 1a
resource "aws_route_table_association" "zilamo_terraform_association_private" {
    subnet_id = aws_subnet.create_public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

# associating route table with subnet 1b
resource "aws_route_table_association" "zilamo_terraform_association_private2" {
    subnet_id = aws_subnet.create_public_subnet2.id
    route_table_id = aws_route_table.public_route_table.id
}

# associating route table with subnet 1c
resource "aws_route_table_association" "zilamo_terraform_association_private3" {
    subnet_id = aws_subnet.create_public_subnet3.id
    route_table_id = aws_route_table.public_route_table.id
}

# create launch configuration with our app ami (has app folder in it)
resource "aws_launch_configuration" "launchconf" {
  image_id      = "ami-0ee7dd3dae0998e9b"
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
  key_name = "eng103a_zilamo"
  associate_public_ip_address = true
  security_groups = ["sg-0ce1ca64fa9e098cd"]
  user_data = <<EOF
#!/bin/bash
echo "mongodb://${aws_instance.zilamo_tf_db.private_ip}:27017/posts" > /home/ubuntu/mongoip
echo "yes" > /home/ubuntu/newfile.txt
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install nginx -y
sudo apt-get install python-software-properties -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y
cp /home/ubuntu/default /etc/nginx/sites-available/
systemctl restart nginx
systemctl enable nginx
cd /home/ubuntu
npm install
node seeds/seed.js
screen -d -m npm start
EOF
}


resource "aws_autoscaling_group" "asg" {
  name                      = "zilamo_terraform_asg"
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.launchconf.name
  vpc_zone_identifier       = [aws_subnet.create_public_subnet.id]
  force_delete = true
  tag {
    key                 = "Name"
    value               = "zilamo_terraform_asg"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }


}

# autoscaling policies for cloudwatch alarm actions (up and down)
resource "aws_autoscaling_policy" "asgpolicy" {
  name = "zilamo_terraform_policy"
  cooldown = 300
  scaling_adjustment = 1
  adjustment_type = "ChangeCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
resource "aws_autoscaling_policy" "asgpolicydown" {
  name = "zilamo_terraform_policy"
  cooldown = 300
  scaling_adjustment = -1
  adjustment_type = "ChangeCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# cloudwatch alarm setup (over 60% cpu util and under 20% cpu util autoscales)
resource "aws_cloudwatch_metric_alarm" "cloudwatchalarm" {
  alarm_name          = "greaterthan80alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asgpolicy.arn]
}
resource "aws_cloudwatch_metric_alarm" "cloudwatchalarm" {
  alarm_name          = "lowerthan20alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.asgpolicyup.arn]
}

# create internet-facing application load balancer
resource "aws_alb" "loadbalancer" {
  name               = "zilamo-load-balancer"
  security_groups    = [aws_security_group.app_security_group.id]
  subnets            = [aws_subnet.create_public_subnet.id, aws_subnet.create_public_subnet2.id, aws_subnet.create_public_subnet3.id]
  tags = {
    Name = "zilamo-load-balancer"
  }
}

# attach the application load balancer to the autoscaling group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn = aws_alb_target_group.targetgroup.arn
}

# set up the target group to direct load balancer traffic to port 80
resource "aws_alb_target_group" "targetgroup" {
  name     = "zilamo-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

# set up an application load balancer listener to hear requests at port 80
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.targetgroup.arn
    type             = "forward"
  }
}
