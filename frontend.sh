#!/bin/bash
USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPTD=$PWD

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

dnf module disable nginx -y &>>"$LOGS_FILE"
Validate $? "Disabling nginx" 

dnf module enable nginx:1.24 -y &>>"$LOGS_FILE"
Validate $? "enabling nginx" 

dnf install nginx -y &>>"$LOGS_FILE"
Validate $? "installing nginx" 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>"$LOGS_FILE"
Validate $? "copying code" 

rm -rf /usr/share/nginx/html/*  &>>"$LOGS_FILE"
Validate $? "removing existing code" 

cd /usr/share/nginx/html &>>"$LOGS_FILE"
Validate $? "changing directory"

unzip /tmp/frontend.zip &>>"$LOGS_FILE"
Validate $? "unzipping the files"

rm -rf /etc/nginx/nginx.conf &>>"$LOGS_FILE"
Validate $? "deleting the old configuration"

cp $SCRIPTD/nginx.conf /etc/nginx/nginx.conf &>>"$LOGS_FILE"
Validate $? "copying configuration"

systemctl enable nginx &>>"$LOGS_FILE"
systemctl start nginx &>>"$LOGS_FILE"
Validate $? "starting nginx"

































