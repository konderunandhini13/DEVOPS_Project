terraform {
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~>4.0"
        }
    }
    backend "s3"{
        bucket = "devops-terraform-state-nand"
        key = "aws/ec2-deploy/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region= var.region
} 
resource "aws_instance" "server" {
    ami = "ami-0b0faec6b121c8bca"
    instance_type = "t2.micro" 
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.maingroup.id]
    iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
    connection {
        type = "ssh"
        host = self.public_ip
        user = "windows"
        private_key = var.private_key
        timeout = "4u"
    }
    tags = {
        "name" = "DeployVM"
    }
}
resource "aws_iam_instance_profile" "ec2-profile" {
    name = "ec2-profile"
    role = "EC2-ECRR-AUTH"
}

resource "aws_security_group" "maingroup" {
    egress = [
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 0
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "-1"
            security_groups = []
            self = false
            to_port = 0
          }
    ]
    ingress = [
        {
            cidr_blocks = ["0.0.0.0/0", ]
            description = ""
            from_port = 3389
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "tcp"
            security_groups = []
            self = false
            to_port = 3389
        },
        {
            cidr_blocks = ["0.0.0.0/0", ]
            description = ""
            from_port = 80
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "tcp"
            security_groups = []
            self = false
            to_port = 80
        }
    ]
}
resource "aws_key_pair" "deployer"{
    key_name = var.key_name
    public_key = var.public_key
}

output "instance_public_ip" {
    value = aws_instance.server.public_ip
    sensitive = true
}