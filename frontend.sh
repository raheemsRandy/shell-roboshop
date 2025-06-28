#!/bin/bash
User_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

Logs_folder="/var/logs/shellscript-logs"
Script_name=$(echo $0)
Log_file=$Log_folder/$Script_name.log
Script_dir=$PWD



echo "Script stared at : $(date)" | tee -a $Log_file

#Checking root access ,user_id of root is zero

if [ $User_id -eq 0 ]
then
    echo "you are having root access you can go on"  | tee -a $Log_file
    
else
    echo "you dont have root access"  | tee -a $Log_file
    exit 1;
fi

# we can pass values $1 and $2 for the validate
Validate (){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 $R....Success$N"  | tee -a $Log_file

    else
        echo -e "$2 $R....Failure$N"  | tee -a $Log_file
        exit 1
    fi
}

#nginx installation

dnf module disable nginx -y &>>$Log_file
# dnf module disable Errornginx -y checking whether it hrows error or not
Validate $? Disabling module &>>$Log_file
#echo "Continued eventhough failure occurs solun give exit status after failure"

# if [ $? eq 0 ]
# then
#     echo "disabling module is Success"

# else
#     echo "disabling module is a failure"
# fi
 

dnf module enable nginx:1.24 -y &>>$Log_file
Validate $? "Enabling nginx module"

dnf install nginx -y &>>$Log_file
Validate $? "Installing nginx module"

rm -rf /usr/share/nginx/html/* &>>$Log_file
Validate $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$Log_file
Validate $? "Downloading fontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$Log_file
Validate $? "Extracting the content"

#vim /etc/nginx/nginx.conf
#create a file and copy the content

rm -rf /etc/nginx/nginx.conf &>>$Log_file
cp $Script_dir/nginx.conf /etc/nginx/nginx.conf
Validate $? copying nginx.conf

systemctl restart nginx 
Validate $? "Restaring nginx"

echo -e "$R Everything$N $G is$N $Y perfect$N"