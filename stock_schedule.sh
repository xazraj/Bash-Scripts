export AWS_ACCESS_KEY_ID=removed
export AWS_SECRET_ACCESS_KEY=removed
export AWS_DEFAULT_REGION=us-west-2

ins_id=i-05aa1606f0dcas13
if [ "$1" == "start" ]; then
    aws ec2 start-instances --instance-ids $ins_id > /dev/null
elif [ "$1" == "stop" ]; then
    aws ec2 stop-instances --instance-ids $ins_id > /dev/null
else
  ip=$(aws ec2 describe-instances --instance-ids $ins_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
  ssh -o StrictHostKeyChecking=no root@$ip
fi
