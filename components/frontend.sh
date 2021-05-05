#!/bin/bash

source components/common.sh
OS_PREREQ
Head "Installing Nginx"
apt install nginx -y &>>"$LOG"
systemctl start nginx
STAT $?
Head "Installing npm"
apt install npm -y &>>$LOG
STAT $?
Head "Downloading git file"
cd /var/www/html

DOWNLOAD_COMPONENT
Head "Install Npm"
npm install &>>"${LOG}"
STAT $?
Head "Run build"
npm run build &>>${LOG}
STAT $?
Head "Change root path in nginx"
sed -i -e 's/html/&/frontend/dist' /etc/nginx/sites-available/default
STAT $?
Head "Update index.js File With Todo & Login Ip"
cd /var/www/html/frontend && cd config && vi index.js
STAT $?
Head "Restart Nginx"
systemctl restart nginx
STAT $?
Head "run npm start"
npm start
STAT $?