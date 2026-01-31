#!/bin/bash
USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPTD=$PWD
DBHOST="mysql.dawsrs.online"


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

dnf install maven -y
Validate $? "Installing Maven"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "system user" roboshop
Validate $? "Creating user"
fi

mkdir -p /app
Validate $? "Creating directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>"$LOGS_FILE"
Validate $? "downloading the code"

cd /app &>>"$LOGS_FILE"
Validate $? "Redirecting to the app folder"

unzip /tmp/shipping.zip &>>"$LOGS_FILE"
Validate $? "Unziping the shipping folder"

mvn clean package &>>"$LOGS_FILE"
Validate $? "installing the dependencies"

mv target/shipping-1.0.jar shipping.jar &>>"$LOGS_FILE"
Validate $? "Renaming the buildfile"

cp $SCRIPTD/shipping.service /etc/systemd/system/shipping.service &>>"$LOGS_FILE"
Validate $? "copying the service configuration"

dnf install mysql -y &>>"$LOGS_FILE"
Validate $? "installing db client"

mysql -h $DBHOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>"$LOGS_FILE"
Validate $? "loading schema"

mysql -h  $DBHOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>"$LOGS_FILE"
Validate $? "Creating db user"

mysql -h $DBHOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>"$LOGS_FILE"
Validate $? "loading master schema"

systemctl daemon-reload &>>"$LOGS_FILE"
systemctl enable shipping &>>"$LOGS_FILE"
systemctl start shipping &>>"$LOGS_FILE"
Validate $? "starting the shipping service"





