terraform {
 required_providers {
   aws = {                      # provider local name
     source  = "hashicorp/aws"  # global and unique source address
     version = "~> 4.0"         # version constrain
   } 
 }
}

provider "aws" {
    region = var.region
  
}

resource "aws_iam_user" "devops" {
  name = each.value
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
  for_each    = toset(var.iam-user)
  user        = aws_iam_user.devops[each.key].name
  policy_arn  = aws_iam_policy.poweruser.arn
}

variable "region" {
    type = string
    description = "My prefered aws region"
    default = "us-east-1"
  
}
variable "force_destroy" {
    type = bool
    description = "deletion policy"
    default = true
  
}
#for_each implementation
variable "iam-user" {
    type = list(string)
    default = [ "chidiogo" ]
  
}
