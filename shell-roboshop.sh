#!/bin/bash

AMI="ami-0220d79f3f480ecf5"
SG_ID="sg-025f74819c6142f22"
ZONE_ID="Z02656783P2XJV1RKB5U2"
DOMAIN="dawsrs.online"



for instance in $@
do

INSTANCE_ID=$( aws ec2 run-instances \
    --image-id "$AMI" \
    --instance-type "t2.micro" \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
     --query 'Instances[0].InstanceId' \
    --output text 

)

echo "Waiting for $instance to get an IP address..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

if [ "$instance" == "frontend" ]; then 
    IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text
    )
    RECORD_NAME="$DOMAIN"
    else

    IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text 
    )
    RECORD_NAME="$instance.$DOMAIN"
fi
    echo " $IP for the $instance "

    

    
aws route53 change-resource-record-sets \

 --hosted-zone-id $ZONE_ID \

 --change-batch '
{
  "Comment": "Creating records",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value":"'$IP'"
          }
        ]
      }
    }
  ]
}'

done


