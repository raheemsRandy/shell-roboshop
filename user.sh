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


dnf module disable nodejs -y
Validate $? "Copying mongodb repo"

dnf module enable nodejs:20 -y

dnf install nodejs -y

id roboshop
if [ $? -eq 0 ]
then    
    echo "user already exists"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    Validate $? "Adding systemuser"
fi

mkdir -p /app 
Validate $? "Creating directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
Validate $? "Downloading the content"

cd /app 
unzip /tmp/user.zip
Validate $? "extracting the content"

cd /app 
npm install 
Validate $? "installing npm"

#vim /etc/systemd/system/user.service
cp $Script_dir/user.service /etc/systemd/system/user.service
Validate $? "copying service file"

systemctl daemon-reload
Validate $? "Daemon reload"

systemctl enable user 
systemctl start user
Validate $? "enable and start"