
AMI_id=ami-09c813fb71547fc4f
SG_id=sg-06f547eb4973bc2c4
Instances=("mongodb" "catalogue" "redis" "mysql" "user" "cart" "shipping" "payment" "rabbitmq" "dispatch" "frontend")
Zone_id=Z03949492VIIV3UN1MEFO
Domain_name=raheemweb.fun

#for i in ${Instances[@]}
for i in $*
do
    #if [ ]
    Instance_id=$(aws ec2 run-instances \
  --image-id ami-09c813fb71547fc4f \
  --instance-type t2.micro \
  --security-group-ids sg-06f547eb4973bc2c4 \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
  --query "Instances[0].InstanceId" \
  --output text)
  
   if [ $i != "frontend" ]
   then
        Ip=$(aws ec2 describe-instances \
        --instance-ids $Instance_id \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text) 
    else
        Ip=$(aws ec2 describe-instances \
        --instance-ids $Instance_id \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text) 
    fi
    echo "$i Ip address: $Ip"

aws route53 change-resource-record-sets \
  --hosted-zone-id $Zone_id \
  --change-batch '
  {
    "Comment": "Tcreating a record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$i'.'$Domain_name'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$Ip'"
        }]
      }
    }]
  }'
done
