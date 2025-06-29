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
Validate $? "enable nodejs"

dnf install nodejs -y&>>Log_file
Validate $? "disable nodejs"

id roboshop
if [ $? -eq 0 ]
then    
    echo "user already exists"
else
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>Log_file
    Validate $? "Adding systemuser"
fi


mkdir -p /app 

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip&>>Log_file
Validate $? "downloading cart"

cd /app 
unzip /tmp/cart.zip&>>Log_file
Validate $? "extract cart app"

cd /app &>>Log_file
npm install &>>Log_file
Validate $? "install npm"

#vim /etc/systemd/system/cart.service
cp  $Script_dir/cart.service /etc/systemd/system/cart.service&>>Log_file
Validate $? "copying service file"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
Validate $? "enable and start cart"