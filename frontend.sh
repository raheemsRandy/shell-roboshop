#!/bin/bash
User_id=$(id -u)
R="\e[31m"


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
        echo  "$2 ....Success"

    else
        echo "$2 $R....Failure"
        exit 1
    fi
}

#nginx installation

#dnf module disable nginx -y
dnf module disable Errornginx -y checking whether it hrows error or not
Validate $? Disabling module
#echo "Continued eventhough failure occurs solun give exit status after failure"

# if [ $? eq 0 ]
# then
#     echo "disabling module is Success"

# else
#     echo "disabling module is a failure"
# fi
 

dnf module enable nginx:1.24 -y 
Validate $? "Enabling nginx module"

dnf install nginx -y 
Validate $? "Installing nginx module"

rm -rf /usr/share/nginx/html/* 
Validate $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
Validate $? "Downloading fontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
Validate $? "Extracting the content"

#vim /etc/nginx/nginx.conf
#create a file and copy the content

systemctl restart nginx 
Validate $? "Restaring nginx"