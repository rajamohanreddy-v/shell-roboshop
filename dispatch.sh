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

mkdir -p "$LOG_FOLDER" &>>"$LOGS_FILE"
Validate $? "Creating Log Folder"

dnf install golang  -y &>>"$LOGS_FILE"
Validate $? "installing golang"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "system user" roboshop
Validate $? "Creating user"
fi

mkdir -p /app
Validate $? "Creating directory"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>"$LOGS_FILE"
Validate $? "downloading the code"

cd /app &>>"$LOGS_FILE"
Validate $? "Redirecting to the app folder"

unzip /tmp/dispatch.zip &>>"$LOGS_FILE"
Validate $? "Unziping the dispatch folder"

go mod init dispatch &>>"$LOGS_FILE"
go get &>>"$LOGS_FILE"
go build &>>"$LOGS_FILE"
Validate $? "installing dependencies"

cp $SCRIPTD/dispatch.service /etc/systemd/system/dispatch.service &>>"$LOGS_FILE"
Validate $? "copying the service file"

systemctl daemon-reload &>>$LOGS_FILE
Validate $? "reloading services "

systemctl enable dispatch &>>$LOGS_FILE
Validate $? "enabling payment "

systemctl start dispatch &>>$LOGS_FILE
Validate $? "starting payment"


