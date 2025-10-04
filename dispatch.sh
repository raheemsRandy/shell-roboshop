source ./common.sh
App_name=dispatch

check_root
app_setup



dnf install golang -y&>>Log_file
Validate $? "installing go"

cd /app 
go mod init dispatch&>>Log_file
go get &>>Log_file
go build&>>Log_file
Validate $? "Installing dependcies"

systemd_setup


print_time

