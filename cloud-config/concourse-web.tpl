#!/bin/bash -v

cd /home/ec2-user

if ! which concourse; then
  curl -v -L https://github.com/concourse/concourse/releases/download/${concourse_version}/concourse_linux_amd64 -o concourse
  chmod +x concourse
  mv concourse /usr/local/bin/concourse
fi

if [ `aws s3 ls s3://${keys_bucket}/web/tsa_host_key | grep tsa_host_key.pub -c` -eq 0 ]; then
    mkdir -p keys/web keys/worker

    ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
    ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

    ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

    cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
    cp ./keys/web/tsa_host_key.pub ./keys/worker

    aws s3 cp ./keys s3://${keys_bucket}/ --recursive
else
    aws s3 cp s3://${keys_bucket}/ ./keys --recursive
fi

touch /var/log/concourse_web.log
chmod 666 /var/log/concourse_web.log

crontab -l > concoursecron
echo "@reboot /usr/local/bin/concourse web \
                --github-auth-client-id ${github_auth_client_id} \
                --github-auth-client-secret ${github_auth_client_secret} \
                --github-auth-team ${github_auth_team} \
                --session-signing-key /home/ec2-user/keys/web/session_signing_key \
                --tsa-host-key /home/ec2-user/keys/web/tsa_host_key \
                --tsa-authorized-keys /home/ec2-user/keys/web/authorized_worker_keys \
                --postgres-data-source postgres://${database_username}:${database_password}@${database_address}:${database_port}/${database_identifier} \
                --bind-port 80 \
                --external-url ${external-url} \
                --peer-url http://$(hostname -I) \
                2>&1 > /var/log/concourse_web.log &" >> concoursecron

crontab concoursecron
rm concoursecron

reboot