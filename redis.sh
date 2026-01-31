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

validate() { if [ "$1" -ne 0 ]; then 
echo -e "$2 ... is $R failed $N" | tee -a "$LOGS_FILE"
exit 1
else
echo -e "$2 ... is $G success $N" | tee -a "$LOGS_FILE"
fi
}

dnf module disable redis -y &>>"$LOGS_FILE"
dnf module enable redis:7 -y &>>"$LOGS_FILE"
validate $? "enabling redis"

dnf install redis -y &>>"$LOGS_FILE"
validate $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>"$LOGS_FILE"
validate $? "redis now heariing on internet"

sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>>"$LOGS_FILE"
validate $? "disabling protect mode"

systemctl enable redis &>>"$LOGS_FILE"
systemctl restart redis &>>"$LOGS_FILE"
validate $? "redis starting"

