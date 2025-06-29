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
#Installation of catalogue
dnf module disable nodejs -y&>>Log_file
Validate $? "Disabling module"

dnf module enable nodejs:20 -y&>>Log_file
Validate $? "Enabling module"

dnf install nodejs -y&>>Log_file
Validate $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>Log_file
    Validate $? "Adding system user"
else
    echo "System user roboshop already exists"
fi

# useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
# Validate $? "Adding system user"

mkdir -p /app &>>Log_file
Validate $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>Log_file
Validate $? "Downloading Catalogue content"

rm -rf /app/*&>>Log_file
Validate $? "Removing everything in app folder"

cd /app 
unzip /tmp/catalogue.zip&>>Log_file
Validate $? "Extracting the content"

cd /app 
npm install &>>Log_file
Validate $? "Installing npm"

#vim /etc/systemd/system/catalogue.service
cp $Script_dir/catalogue.service /etc/systemd/system/catalogue.service
Validate $? "Copying catalogue service"

systemctl daemon-reload&>>Log_file
Validate $? "Daemon reload"

systemctl enable catalogue &>>Log_file
systemctl start catalogue&>>Log_file
Validate $? "Enabling and starting catalogue "

#vim /etc/yum.repos.d/mongo.repo
cp $Script_dir/mongo.repo /etc/yum.repos.d/mongo.repo&>>Log_file
Validate $? "Copying the mongosh repo content"

dnf install mongodb-mongosh -y&>>Log_file
Validate $? "Installing mongosh client"

Status=$(mongosh --host mongodb.raheemweb.fun --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $Status -ge 0 ]
then 
    echo "data is already loaded"
else
    mongosh --host mongodb.raheemweb.fun </app/db/master-data.js&>>Log_file
    Validate $? "Loading the master data"
fi




# mongosh --host mongodb.raheemweb.fun
# Validate $? "Checking connection to client mongoosh"







