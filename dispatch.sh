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


dnf install golang -y&>>Log_file
Validate $? "installing go"

id roboshop
if [ $? -eq 0 ]
then    
    echo "user already exists"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>Log_file
    Validate $? "Adding systemuser"
fi

mkdir /app 
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>Log_file
Validate $? "Downloading"

rm -rf /app/*&>>Log_file
Validate $? "Removing content"

cd /app 
unzip /tmp/dispatch.zip&>>Log_file
Validate $? "Extracting"

cd /app 
go mod init dispatch&>>Log_file
go get &>>Log_file
go build&>>Log_file
Validate $? "Installing dependcies"


#vim /etc/systemd/system/dispatch.service
cp $Script_dir/dispatch.service /etc/systemd/system/dispatch.service
Validate $? "copying Service"

systemctl daemon-reload
systemctl enable dispatch 
systemctl start dispatch
Validate $? "enable and start dispatch"

