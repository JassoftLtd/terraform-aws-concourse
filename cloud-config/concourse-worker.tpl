#!/bin/bash -v

cd /home/ec2-user

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/v2.7.0/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

mkdir -p keys/web keys/worker

ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker

mkdir /opt/concourse/worker

touch /var/log/concourse_worker.log
chmod 666 /var/log/concourse_worker.log

/usr/local/bin/concourse worker \
  --work-dir /opt/concourse/worker \
  --tsa-host ${tsa_host} \
  --tsa-public-key ./keys/worker/tsa_host_key.pub \
  --tsa-worker-private-key ./keys/worker/worker_key \
  2>&1 > /var/log/concourse_worker.log &