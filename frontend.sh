#!/bin/bash


echo "Script stared at : $(date)"

#Checking root access ,user_id of root is zero

if [ User_id eq 0 ]
then
    echo "you are having root access you can go on"
    
else
    echo "you dont have root access"
    exit 1;
fi

Validate

#nginx installation

dnf module disable nginx -y
# if [ $? eq 0 ]
# then
#     echo "disabling module is Success"

# else
#     echo "disabling module is a failure"


dnf module enable nginx:1.24 -y 


dnf install nginx -y 


