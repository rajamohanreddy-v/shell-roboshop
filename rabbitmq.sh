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

cp "$SCRIPTD"/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>"$LOGS_FILE"
Validate $? "Copying the repos"

dnf install rabbitmq-server -y &>>"$LOGS_FILE"
Validate $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl start rabbitmq-server &>>"$LOGS_FILE"

rabbitmqctl list_users | grep -w "roboshop" &>>"$LOGS_FILE"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>"$LOGS_FILE"
    Validate $? "Creating roboshop user"
else
    echo -e "Roboshop user already exists ... $Y SKIPPING $N"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>"$LOGS_FILE"
Validate $? "setting permissions"

systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl restart rabbitmq-server &>>"$LOGS_FILE"
Validate $? "starting rabbitmq"
