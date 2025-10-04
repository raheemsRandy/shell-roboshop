#!/bin/bash

Start_time=$(date +%s)
userId=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_folder="/var/log/shellscript-logs"
#Script_name=$(echo $0 | cut -d "." -f1) 
Script_name=$(echo $0)
Log_file="$Logs_folder/$Script_name.log"
Script_dir=$PWD
#Packages=("mysql" "python3" "nginx")
# Packages=$@

mkdir -p $Logs_folder
echo "Script started at: $(date)"  | tee -a $Log_file
-----------------------------------------------------------------
check_root(){
if [ $userId -ne 0 ]
then 
    echo -e "$R please run this command with root access $N" | tee -a $Log_file
    exit 1
else
    echo -e "$G Your are running with root access $N"  | tee -a $Log_file
fi
}

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
-------------------------------------------------------------
app_setup(){
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

    curl -o /tmp/$App_name.zip https://roboshop-artifacts.s3.amazonaws.com/$App_name-v3.zip &>>Log_file
    Validate $? "Downloading $App_name content"

    rm -rf /app/*&>>Log_file
    Validate $? "Removing everything in app folder"

    cd /app 
    unzip /tmp/$App_name.zip&>>Log_file
    Validate $? "Extracting the content" 
}
-------------------------------------------------------
nodejs_setup(){
    dnf module disable nodejs -y&>>Log_file
    Validate $? "Disabling module"

    dnf module enable nodejs:20 -y&>>Log_file
    Validate $? "Enabling module"

    dnf install nodejs -y&>>Log_file
    Validate $? "Installing nodejs"

    cd /app 
    npm install &>>Log_file
    Validate $? "Installing npm"
}

---------------------------------------------------------


systemd_setup(){
    cp $Script_dir/$App_name.service /etc/systemd/system/$App_name.service&>>Log_file
    Validate $? "Copying $App_name service"
    systemctl daemon-reload&>>Log_file
    Validate $? "Daemon reload"

    systemctl enable $App_name &>>Log_file
    systemctl start $App_name&>>Log_file
    Validate $? "Enabling and starting $App_name"
    }

-------------------------------------------------------------------------


print_time(){
    End_time=$(date +%s)
    Total_time=$((End_time-Start_time))
    echo -e "Script executed, Time taken: $Total_time "
}