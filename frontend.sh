#!/bin/bash
User_id=$(id -u)

echo "Script stared at : $(date)"

#Checking root access ,user_id of root is zero

if [ $User_id -eq 0 ]
then
    echo "you are having root access you can go on"
    
else
    echo "you dont have root access"
    exit 1;
fi

# we can pass values $1 and $2 for the validate
Validate (){
    if [ $1 -eq 0 ]
    then
        echo "$2 ....Success"

    else
        echo "$2 ....Failure"
    fi
}

#nginx installation

dnf module disable 2nginx -y
Validate $? Disabling module
echo "contine just checking"
# if [ $? eq 0 ]
# then
#     echo "disabling module is Success"

# else
#     echo "disabling module is a failure"
# fi


# dnf module enable nginx:1.24 -y 


# dnf install nginx -y 


