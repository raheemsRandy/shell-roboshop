#!/bin/bash

userId=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_folder="/var/log/shellscript-logs"
Script_name=$(echo $0 | cut -d "." -f1) 
Log_file="$Logs_folder/$Script_name.log"
Script_dir=$PWD

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

#vim /etc/yum.repos.d/rabbitmq.repo
cp $Script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
Validate $? "copying repo"

dnf install rabbitmq-server -y&>>Log_file
Validate $? "installing rabbitmq"

systemctl enable rabbitmq-server&>>Log_file
systemctl start rabbitmq-server&>>Log_file
Validate $? "enable and start rabbitmq"

rabbitmqctl add_user roboshop roboshop123&>>Log_file
Validate $? "adding user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"&>>Log_file
Validate $? "Setting permissions"