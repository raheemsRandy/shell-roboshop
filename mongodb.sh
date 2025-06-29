#!/bin/bash

userId=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_folder="/var/log/shellscript-logs"
Script_name=$(echo $0 | cut -d "." -f1) 
Log_file="$Logs_folder/$Script_name.log"
#Packages=("mysql" "python3" "nginx")
# Packages=$@

mkdir -p $Logs_folder
echo "Script started at: $(date)"  | tee -a $Log_file

if [ $userId -ne 0 ]
then 
    echo -e "$R please run this command with root access $N" | tee -a $Log_file
    exit 1
else
    echo -e "$G Your are running with root access $N"  | tee -a $Log_file
fi

#-----------------------------------------



Validate(){
    if [ $1 -eq 0 ]
     then 
        echo -e "$2 .....$G Success $N"  | tee -a $Log_file
     else
        echo -e " $2 .....$R Failure $N"| tee -a $Log_file
        exit 1
    fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
Validate $? "Copying mongodb repo"

dnf install mongodb-org -y &>>Log_file
Validate $? "Insatlling mongodb"

systemctl enable mongod &>>Log_file
Validate $? "Enabling mongodb"

systemctl start mongod &>>Log_file
Validate $? "Starting mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
Validate $? "Edit the mongodb config file for remote connections"

systemctl restart mongod &>>Log_file
Validate $? "Restart the mongodb"


