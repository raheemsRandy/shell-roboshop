#!/bin/bash

userId=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_folder="/var/log/shellscript-logs"
Script_name=$(echo $0 | cut -d "." -f1) 
Log_file="$Logs_folder/$Script_name.log"

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


dnf module disable redis -y &>>Log_file
Validate $? "Disabling redis"

dnf module enable redis:7 -y &>>Log_file
Validate $? "Enabling redis"

dnf install redis -y &>>Log_file
Validate $? "Installing redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>>Log_file
Validate $? "Remote connection"

systemctl enable redis &>>Log_file
systemctl start redis &>>Log_file
Validate $? "Enabling and starting redis"

