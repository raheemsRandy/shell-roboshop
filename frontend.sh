source ./common.sh
App_name=

check_root



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

print_time

echo -e "$R Everything$N $G is$N $Y perfect$N"