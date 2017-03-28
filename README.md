# Concourse AWS Terraform script
Terraform scripts to deploy Concourse into an AWS account.

This Concourse setup runs with a Postgres instance in RDS and workers in a spot request fleet.
This gives a discount to running the workers and also allows a flexible number of instances to be configured in the auto scaling group.

# Deploy to AWS
To deploy Concourse to AWS simply run terraform apply. 
```
terraform apply \
    -var key_name=MY_KEY_NAME \
    -var aws_access_key=YOUR_AWS_ACCESS_KEY \
    -var aws_secret_key=YOUR_AWS_SECRET_KEY \
    -var dns_zone_id=YOUR_DNS_ZONE_ID \
    -var dns_zone_name=YOUR_DNS_ZONE_NAME 
```