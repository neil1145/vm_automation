#!/bin/bash
export FLASK_APP=app
export FLASK_ENV=development

date=$(date +"%d-%m-%Y_%H_%M_%S")

flask run --host=192.168.56.18 -p 5000 > server_log-$date 2>&1 &

pgrep 'flask'