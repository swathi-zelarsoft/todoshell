#!/bin/bash


LID=lt-0d8cd83146152a5b9
LVER=1
#COMPONENT=$1

if [ -z "$1" ]; then
  echo "Component Name INput is needed"
  exit 1
fi

Instance_Create() {
  COMPONENT=$1
  INSTANCE_EXISTS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${COMPONENT}  | jq .Reservations[])
  STATE=$(aws ec2 describe-instances     --filters Name=tag:Name,Values=${COMPONENT}  | jq .Reservations[].Instances[].State.Name | xargs)
  if [ -z "${INSTANCE_EXISTS}" -o "$STATE" == "terminated"  ]; then
    aws ec2 run-instances --launch-template LaunchTemplateId=${LID},Version=${LVER}  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}, {Key=Project,Value=todo}]" | jq
  else
    echo "Instance ${COMPONENT} already exists"
  fi


  IPADDRESS=$(aws ec2 describe-instances  --filters Name=tag:Name,Values=${COMPONENT} | jq .Reservations[].Instances[].PrivateIpAddress | grep -v null |xargs)

  sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${IPADDRESS}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z06752241NSSN6BC0B4NW --change-batch file:///tmp/record.json
  sed -i -e "/${COMPONENT}/ d" ../inv
  echo "${IPADDRESS} COMPONENT=$(echo ${COMPONENT} | awk -F - '{print $1}')" >>../inv
}

if [ "$1" == "all" ]; then
  for instance in frontend login todo users ; do
    Instance_Create $instance
  done
else
  Instance_Create $1
fi