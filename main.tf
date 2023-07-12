terraform {
  required_providers {
    aws = {                     # provider local name
      source  = "hashicorp/aws" # global and unique source address
      version = "~> 4.0"        # version constrain
    }
  }
}

provider "aws" {
  region = var.region

}
resource "aws_s3_bucket" "steve-backend_01" {
  bucket = "steve-tf-state-bucket01"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

terraform {
  backend "s3" {
    bucket = "steve-tf-state-bucket01"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
#The data "aws_ami" "ubuntu" block retrieves information about the
# most recent Ubuntu AMI matching the specified filters.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  owners = ["099720109477"] # Canonical -specifies the owner ID for the AMI.
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}




resource "aws_iam_user" "devops" {
  name     = each.value
  for_each = toset(var.iam-user)
  #path = "/system/"
  force_destroy = var.force_destroy


  tags = {
    Description = "Devops Team Member"
  }
}
#this need to be revisited
#resource "aws_iam_access_key" "devops-key" {
# user = aws_iam_user.devops.name
#}

resource "aws_iam_policy" "poweruser" {
  name        = "devops-policy"
  description = "A limited devops policy"
  policy      = file("aws-poweruser-policy.json")
}

resource "aws_iam_user_policy_attachment" "policy-attach" {
  for_each   = toset(var.iam-user)
  user       = aws_iam_user.devops[each.key].name
  policy_arn = aws_iam_policy.poweruser.arn
}

variable "region" {
  type        = string
  description = "My prefered aws region"
  default     = "us-east-1"

}
variable "force_destroy" {
  type        = bool
  description = "deletion policy"
  default     = true

}
#for_each implementation
variable "iam-user" {
  type    = list(string)
  default = ["chidiogo"]

}


