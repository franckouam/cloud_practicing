aws ec2 describe-vpcs --filters Name=tag:lab-id,Values=pod1 

aws ec2 describe-vpcs --filters Name=tag:Name,Values=pod1-vpc

aws ec2 describe-instances --filters Name=tag:Name,Values=REDACTED

export INSTANCE_ID=$(aws ec2 describe-instances --filters Name=tag:Name,Values=REDACTED --output json | jq -r '.Reservations[0].Instances[0].InstanceId')

aws ec2 describe-instances --instance-ids $INSTANCE_ID --output json | jq -r '.Reservations[0].Instances[0].ImageId'

aws ec2 describe-images --region us-east-1 --image-ids ami-053b0d53c279acc90

aws ec2 stop-instances --instance-ids $INSTANCE_ID

aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --include-all-instances

aws ec2 terminate-instances --instance-ids $INSTANCE_ID
