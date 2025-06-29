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

dnf install python3 gcc python3-devel -y&>>Log_file
Validate $? "Installing python"

id roboshop
if [ $? -eq 0 ]
then    
    echo "user already exists"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>Log_file
    Validate $? "Adding systemuser"
fi

mkdir /app 
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>Log_file
Validate $? "Downloading"


rm -rf /app/*&>>Log_file
Validate $? "Removing the content in app folder"

cd /app 
unzip /tmp/payment.zip&>>Log_file
Validate $? "Extracting"

cd /app &>>Log_file
pip3 install -r requirements.txt&>>Log_file
Validate $? "installing pip"

#vim /etc/systemd/system/payment.service
cp $Script_dir/user.service /etc/systemd/system/user.service&>>Log_file
Validate $? "copying service file"

systemctl enable payment 
systemctl start payment
Validate $? "Enable and start payment"