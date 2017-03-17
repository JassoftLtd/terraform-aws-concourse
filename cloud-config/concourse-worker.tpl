#!/bin/bash -v

cd /home/ec2-user

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/v2.7.0/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

aws s3 cp s3://${keys_bucket}/ ./keys --recursive

mkdir -p /opt/concourse/worker

touch /var/log/concourse_worker.log
chmod 666 /var/log/concourse_worker.log

/usr/local/bin/concourse worker \
  --work-dir /opt/concourse/worker \
  --tsa-host ${tsa_host} \
  --tsa-public-key ./keys/worker/tsa_host_key.pub \
  --tsa-worker-private-key ./keys/worker/worker_key \
  2>&1 > /var/log/concourse_worker.log &