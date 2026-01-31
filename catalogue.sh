#!/bin/bash
USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPTD=$PWD
DB_HOST="mongodb.dawsrs.online"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
if [ "$USER_ID" -ne 0 ]; then
echo -e "$R Please run the script with root user $N"
exit 1
fi
mkdir -p "$LOG_FOLDER"
Validate() { if [ "$1" -ne 0 ]; then
echo -e " "$2" ... is "$R" Failed $N" | tee -a  "$LOGS_FILE"
exit 1
else
echo -e " "$2" ... is "$G" SUCCESS $N" | tee -a  "$LOGS_FILE"
fi
}
dnf module disable nodejs -y &>>$LOGS_FILE
Validate $? "Disabling nodejs" 
dnf module enable nodejs:20 -y &>>$LOGS_FILE
Validate $? "enabling nodejs" 
dnf install nodejs -y &>>$LOGS_FILE
Validate $? "installing nodejs" 
id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    Validate $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi
mkdir -p /app &>>$LOGS_FILE
Validate $? "Creatign directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
Validate $? "downloading the code"
rm -rf /app/* &>>$LOGS_FILE
Validate $? "Clearing the previous code"
cd /app &>>$LOGS_FILE
Validate $? "Redirecting to the app folder"
unzip /tmp/catalogue.zip &>>$LOGS_FILE
Validate $? "Redirecting to the app folder"
npm install &>>$LOGS_FILE
Validate $? "Installing the dependencies"
cp $SCRIPTD/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGS_FILE
Validate $? "coping the service file"
systemctl daemon-reload &>>$LOGS_FILE
Validate $? "RELOADING THE SERVICES"
systemctl enable catalogue &>>$LOGS_FILE
Validate $? "enabling the catalogue"
systemctl start catalogue &>>$LOGS_FILE
Validate $? "starting catalogue"
cp $SCRIPTD/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
Validate $? "copying mongo repo"
dnf install mongodb-mongosh -y &>>$LOGS_FILE
Validate $? "installing mongodb client"
INDEX=$(mongosh --host $DB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $INDEX -lt 0 ]; then
    mongosh --host $DB_HOST  </app/db/master-data.js &>>$LOGS_FILE
    Validate $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi
systemctl restart catalogue &>>$LOGS_FILE
Validate $? "Restarting catalogue"



























