source ./common.sh
App_name=shipping

check_root
app_setup


echo "Please enter mysql root password"
read -s Mysql_root_pass



dnf install maven -y&>>Log_file
Validate $? "Disabling maven"


cd /app 
mvn clean package &>>Log_file
mv target/shipping-1.0.jar shipping.jar &>>Log_file
Validate $? "Installing packages"


systemd_setup

dnf install mysql -y &>>Log_file
Validate $? "installing mysql"

mysql -h mysql.raheemweb.fun -u root -pRoboShop@1 -e 'use cities'
if[ $? -ne 0 ]
then
    mysql -h mysql.raheemweb.fun -uroot -p$Mysql_root_pass < /app/db/schema.sql&>>Log_file
    mysql -h mysql.raheemweb.fun -uroot -p$Mysql_root_pass < /app/db/app-user.sql &>>Log_file
    mysql -h mysql.raheemweb.fun -uroot -p$Mysql_root_pass < /app/db/master-data.sql&>>Log_file
else    
    echo "Data is already loaded"
fi


systemctl restart shipping&>>Log_file
Validate $? "Restarting shipping"

print_time