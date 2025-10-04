source ./common.sh
App_name=rabbitmq

check_root


#vim /etc/yum.repos.d/rabbitmq.repo
cp $Script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
Validate $? "copying repo"

dnf install rabbitmq-server -y&>>Log_file
Validate $? "installing rabbitmq"

systemctl enable rabbitmq-server&>>Log_file
systemctl start rabbitmq-server&>>Log_file
Validate $? "enable and start rabbitmq"

rabbitmqctl add_user roboshop roboshop123&>>Log_file
Validate $? "adding user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"&>>Log_file
Validate $? "Setting permissions"

print_time