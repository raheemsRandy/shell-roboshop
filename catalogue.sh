#!/bin/bash

User_id=$(id -u)
$Script_dir=$PWD
#checking root access
if [ $User_id -eq 0 ]
then
    echo "You are having root access you can go on"
else
    echo "You dont have root access"
fi

#Takes argument $1=exit status and $2=process done
Validate(){
    if [ $1 -eq 0 ]
    then
        echo "$2 ...is Success"
    else
        echo "$2 ...is Failure"
    fi

}
#Installation of catalogue
dnf module disable nodejs -y
Validate $? "Disabling module"

dnf module enable nodejs:20 -y
Validate $? "Enabling module"

dnf install nodejs -y
Validate $? "Installing nodejs"

# id roboshop
# if [ $? -ne 0]
# then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
#     Validate $? "Adding system user"
# else
#     echo "System user roboshop already exists"
# fi

 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
Validate $? "Adding system user"

mkdir /app 
Validate $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip"
Validate "$? "Downloading Catalogue content"

cd /app 
unzip /tmp/catalogue.zip
Validate $? "Extracting the content"

cd /app 
npm install 
Validate $? "Installing npm"

systemctl daemon-reload
Validate $? "Daemon reload"

systemctl enable catalogue 
systemctl start catalogue
Validate $? "Enabling and starting catalogue "

#vim /etc/yum.repos.d/mongo.repo
cp $Script_dir/mongo.rep /etc/yum.repos.d/mongo.repo
Validate $? "Copying the mongosh repo content"

dnf install mongodb-mongosh -y
Validate $? "Installing mongosh client"

mongosh --host mongodb.raheemweb.fun </app/db/master-data.js
Validate $? "Loading the master data"

mongosh --host mongodb.raheemweb.fun
Validate $? "Checking connection to client mongoosh"







