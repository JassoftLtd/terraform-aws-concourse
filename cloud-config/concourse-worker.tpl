#!/bin/bash -v

cd /home/ec2-user

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/${concourse_version}/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

while [ `aws s3 ls s3://${keys_bucket}/worker/tsa_host_key.pub | grep tsa_host_key.pub -c` -eq 0 ]
do
    echo "sleeping"
    sleep 10
done

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