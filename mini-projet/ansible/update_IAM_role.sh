#!/bin/bash

aws ec2 associate-iam-instance-profile --iam-instance-profile Name=r53-devops --instance-id $1

