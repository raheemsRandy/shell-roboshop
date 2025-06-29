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

echo "Please enter mysql root password"
read -s Mysql_root_pass

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


dnf install maven -y&>>Log_file
Validate $? "Disabling maven"

id roboshop
if [ $? -eq 0 ]
then    
    echo "user already exists"
else
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop&>>Log_file
    Validate $? "Adding systemuser"
fi


mkdir /app 
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip v
Validate $? "downloading shipping"

rm -rf /app/*&>>Log_file
Validate $? "removing content in app folder"

cd /app 
unzip /tmp/shipping.zip&>>Log_file
Validate $? "Extracting shipping"

cd /app 
mvn clean package &>>Log_file
mv target/shipping-1.0.jar shipping.jar &>>Log_file
Validate $? "Installing packages"


#vim /etc/systemd/system/shipping.service
cp $Script_dir/shipping.service /etc/systemd/system/shipping.service&>>Log_file
Validate $? "Copying system service"

systemctl daemon-reload&>>Log_file
systemctl enable shipping &>>Log_file
systemctl start shipping&>>Log_file
Validate $? "Enable and start shipping"

dnf install mysql -y &>>Log_file
Validate $? "installing mysql"

mysql -h mysql.raheemweb.fun -uroot -p$Mysql_root_pass < /app/db/schema.sql&>>Log_file
mysql -h mysql.raheemweb.fun -uroot -p$Mysql_root_pass < /app/db/app-user.sql &>>Log_file
mysql -h mysql.raheemweb.fun -uroot -p$Mysql_root_pass < /app/db/master-data.sql&>>Log_file


systemctl restart shipping&>>Log_file
Validate $? "Restarting shipping"

End_time=$(date +%s)
Total_time=$(($End_time - $Start_time))

echo -e "Scriptexecution completed Time taken : $Total_time"| tee -a $Log_file