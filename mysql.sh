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

dnf install mysql-server -y &>>"$LOGS_FILE"
Validate $? "Installing Mysql" 

systemctl enable mysqld &>>"$LOGS_FILE"
systemctl start mysqld  &>>"$LOGS_FILE"
Validate $? "starting  Mysql"

mysql -u root -pRoboShop@1 -e 'show databases;' &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
    Validate $? "Setting Root Password"
else
    echo -e "Root password already set ... $Y SKIPPING $N"
fi