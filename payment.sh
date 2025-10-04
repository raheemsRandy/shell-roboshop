source ./common.sh
App_name=payment

check_root
app_setup



dnf install python3 gcc python3-devel -y&>>Log_file
Validate $? "Installing python"


cd /app &>>Log_file
pip3 install -r requirements.txt&>>Log_file
Validate $? "installing pip"

systemd_setup


print_time