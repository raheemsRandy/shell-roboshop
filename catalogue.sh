
source ./common.sh
App_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup


#vim /etc/yum.repos.d/mongo.repo
cp $Script_dir/mongo.repo /etc/yum.repos.d/mongo.repo&>>Log_file
Validate $? "Copying the mongosh repo content"

dnf install mongodb-mongosh -y&>>Log_file
Validate $? "Installing mongosh client"

Status=$(mongosh --host mongodb.raheemweb.fun --eval 'db.getMongo().getDbNames().indexOf("catalogue")')
if [ $Status -gt 0 ]
then 
    echo "data is already loaded"
else
    mongosh --host mongodb.raheemweb.fun </app/db/master-data.js&>>Log_file
    Validate $? "Loading the master data"
fi

print_time




# mongosh --host mongodb.raheemweb.fun
# Validate $? "Checking connection to client mongoosh"







