
source ./common.sh
App_name="mongodb"

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
Validate $? "Copying mongodb repo"

dnf install mongodb-org -y &>>Log_file
Validate $? "Installing mongodb"

systemctl enable mongod &>>Log_file
Validate $? "Enabling mongodb"

systemctl start mongod &>>Log_file
Validate $? "Starting mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
Validate $? "Edit the mongodb config file for remote connections"

systemctl restart mongod &>>Log_file
Validate $? "Restart the mongodb"

print_time


