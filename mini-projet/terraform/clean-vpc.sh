read -p 'Please enter your VPC Name:  ' VPC_NAME

# Retrieve your vpc-id
VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=${VPC_NAME} | jq -r '.Vpcs[].VpcId')

# Check if your VPC exist
if [ -z "$VPC_ID" ]; then
    echo "VPC not found with name : ${VPC_NAME}"
    exit 1 
fi

echo -e "Cleaning VPC : ${VPC_ID}"

# Detach internet gateway from your VPC
for igw in $(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values="${VPC_ID}" | jq -r '.InternetGateways[].InternetGatewayId'); do
  echo -e "\tDetach Internet Gateway ${igw}"
  aws ec2 detach-internet-gateway --internet-gateway-id=$igw --vpc-id=$VPC_ID
  # Wait for IGW to be detached
  sleep 5
  # Delete the internet gateway
  echo -e "\tDelete Internet Gateway ${igw}"
  aws ec2 delete-internet-gateway --internet-gateway-id=$igw
done

# Delete all subnets attached to your VPC
for subnet in $(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}" | jq -r '.Subnets[].SubnetId'); do
  echo -e "\tDelete Subnet : ${subnet}"
  aws ec2 delete-subnet --subnet-id ${subnet}
done

# Delete all route table attached to your VPC but the main one (Forbidden)
for route_table in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=${VPC_ID}" --query 'RouteTables[?Associations == `[]`]' | jq -r '.[].RouteTableId'); do
  echo -e "\tDelete Route-Table : ${route_table}"
  aws ec2 delete-route-table --route-table-id "$route_table"
done


# Delete Security Groups attached to your VPC but the default one (Forbidden)
for sg in $(aws ec2 describe-security-groups --filters Name=vpc-id,Values="${VPC_ID}" --query "SecurityGroups[?GroupName!='default']" | jq -r '.[].GroupId'); do
  echo -e "\tDelete Security Group ${sg}"
  aws ec2 delete-security-group --group-id $sg
done
