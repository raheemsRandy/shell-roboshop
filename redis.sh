source ./common.sh
App_name=redis

check_root
app_setup



dnf module disable redis -y &>>Log_file
Validate $? "Disabling redis"

dnf module enable redis:7 -y &>>Log_file
Validate $? "Enabling redis"

dnf install redis -y &>>Log_file
Validate $? "Installing redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>>Log_file
Validate $? "Remote connection"

systemctl enable redis &>>Log_file
systemctl start redis &>>Log_file
Validate $? "Enabling and starting redis"

print_time

