#!/bin/bash

userId=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_folder="/var/log/shellscript-logs"
Script_name=$(echo $0)
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
#&>>Log_file


dnf module disable nodejs -y&>>Log_file
Validate $? "disable nodejs"

dnf module enable nodejs:20 -y&>>Log_file
dnf install nodejs -y
Validate $? "enabling and installing"

id roboshop
if [ $? -eq 0 ]
then    
    echo "user already exists"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>Log_file
    Validate $? "Adding systemuser"
fi

mkdir -p /app &>>Log_file
Validate $? "Creating directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>Log_file
Validate $? "Downloading the content"

rm -rf /app/*&>>Log_file
Validate $? "Removing the content in app folder"

cd /app &>>Log_file
unzip /tmp/user.zip&>>Log_file
Validate $? "extracting the content"

cd /app &>>Log_file
npm install &>>Log_file
Validate $? "installing npm"

#vim /etc/systemd/system/user.service
cp $Script_dir/user.service /etc/systemd/system/user.service&>>Log_file
Validate $? "copying service file"

systemctl daemon-reload
Validate $? "Daemon reload"

systemctl enable user &>>Log_file
systemctl start user&>>Log_file
Validate $? "enable and start"