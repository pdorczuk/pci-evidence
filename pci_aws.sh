#!/bin/bash
# This runs from any POSIX shell that has AWS CLI installed and pointing at the correct org

# for debugging, delete the file at the start of every run so it doesn't endlessly append
rm -f $(hostname)__aws__pcidss.txt
exec > $(aws sts get-caller-identity --query ""Account"" --output text)__aws__pcidss.txt 2>&1 # Pipe STDOUT and STDERR
set -x #echo on


# Evidence metadata
date


#######################################################################################################################
# IAM password policy showing password rotation, minimum length, complexity, and history.
# AND authentication and authorization parameters. 
# Supports PCI DSS Requirements 3.3.b, 7.1.1, 7.1.4, 7.2.1 - 7.2.3, 8.1, 8.1.2, 8.5.a
#######################################################################################################################
aws iam get-account-authorization-details --output yaml
aws iam generate-credential-report
aws iam get-credential-report --output text --query Content | base64 -d
aws iam list-saml-providers --output yaml


#######################################################################################################################
# IAM password policy showing password rotation, minimum length, complexity, and history.
# Supports PCI DSS Requirements 8.1.4, 8.2.3, 8.2.4, 8.2.5
#######################################################################################################################
aws iam get-account-password-policy --output=yaml


#######################################################################################################################
# AWS networking configuration including VPCs, subnets, NACLs, security groups, route tables, and IGWs.
# Supports PCI DSS Requirements 1.1.6.c, 1.2.1, 1.2.3, 1.3.1- 1.3.7, 2.2.2 - 2.2.5, 2.3, 6.2.b, 8.2.1
#######################################################################################################################
for i in vpcs vpc-peering-connections subnets route-tables internet-gateways network-acls security-groups
do
    aws ec2 describe-$i --output=yaml
done


#######################################################################################################################
# AWS EC2 instance descriptions showing associated security groups.
# Supports PCI DSS Requirement 1.3
#######################################################################################################################
aws ec2 describe-instances --no-paginate --output=yaml


#######################################################################################################################
# Cloudtrail configuration settings showing storage location, log validation, and scope. 
# Supports PCI DSS Requirement 10.1
#######################################################################################################################
aws cloudtrail describe-trails --output yaml
for trail in `aws cloudtrail describe-trails --output text | awk -F '\t' '{print $NF}'`
do 
    aws cloudtrail get-trail-status --name $trail --output yaml
    aws cloudtrail get-event-selectors --trail-name $trail --output yaml
done


#######################################################################################################################
# CloudTrail bucket configuration showing access permissions and logging.  
# Supports PCI DSS Requirement 10.5.5
#######################################################################################################################
for bucket in `aws cloudtrail describe-trails --output text | cut -f11`
do
    aws s3api get-bucket-policy --bucket $bucket --output yaml
    aws s3api get-bucket-logging --bucket $bucket --output yaml
done


#######################################################################################################################
# Cloudwatch metrics and alert settings.
# Supports PCI DSS Requirement 10.6
#######################################################################################################################
aws logs describe-metric-filters --output=yaml
aws cloudwatch describe-alarms --output yaml


set +x # echo off
