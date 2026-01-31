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
echo "$R installing $2 failed $N" | tee -a "$LOGS_FILE"
exit 1
else
echo "$G installing $2 success $N" | tee -a "$LOGS_FILE"
fi
}

cp "$SCRIPTD/mongo.repo" /etc/yum.repos.d/mongo.repo &>>"$LOGS_FILE"
Validate $? "Copying mongo repo"

dnf install mongodb-org -y &>>"$LOGS_FILE"
Validate $? "Installing mongodb"

systemctl enable mongod &>>"$LOGS_FILE"
systemctl start mongod &>>"$LOGS_FILE"
Validate $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>"$LOGS_FILE"
Validate $? "DB now heariing on internet"

systemctl restart mongod &>>"$LOGS_FILE"
Validate $? "re-starting mongod"








