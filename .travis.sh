#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -e
trap 'kill $(jobs -p)' SIGINT SIGTERM EXIT

export TRAVIS=1
export DOCKER_HOST="unix:///var/run/docker.sock"

cgroups-umount
cgroups-mount

docker -d &
sleep 2 
chmod +rw /var/run/docker.sock 

cd $DIR
docker run -d --name db \
-e MYSQL_ROOT_PASSWORD=root \
-e MYSQL_DATABASE=testdb \
-e MYSQL_USER=user \
-e MYSQL_PASSWORD=pw \
mysql

make image

docker run -i -t --name=wordpress \
-e DB_SERVICE_ADDRESS=db \
-e APP_DB_NAME=testdb \
-e APP_DB_USERNAME=user \
-e APP_DB_PASSWORD=pw \
-e APP_TCP_PORT=80 \
-e APP_TEST_HTTP_ENDPOINT="/" \
-e APP_TEST_HTTP_STATUS_CODE=200 \
-e APP_TEST_STRING="Powered by WordPress, state-of-the-art semantic personal publishing platform." \
-e APP_FQDN=wordpress.test \
--link db:db \
inclusivedesign/wordpress \
ansible-playbook /srv/ansible/container.yml --tags "start,test"
