#!/bin/bash
get_opw_ebs_drive() {
    # nvme0/sda1 will always be the root drive, to my knowledge.
    # Here we assume a single non-root drive attached to the instance.
    # TODO: make sure this works with non-nitro instances.
    drive=($(lsblk -o +SERIAL | grep vol | grep -v loop | grep -v nvme0 | grep -v sda | awk '{print $1}' | head -n 1))
    echo "$${drive}"
}

sudo apt -y update
sudo apt -y install apt-transport-https curl gnupg

sudo sh -c "echo 'deb [signed-by=/usr/share/keyrings/datadog-archive-keyring.gpg] https://apt.datadoghq.com/ stable observability-pipelines-worker-1' > /etc/apt/sources.list.d/datadog.list"
sudo touch /usr/share/keyrings/datadog-archive-keyring.gpg
sudo chmod a+r /usr/share/keyrings/datadog-archive-keyring.gpg
curl https://keys.datadoghq.com/DATADOG_APT_KEY_CURRENT.public | sudo gpg --no-default-keyring --keyring /usr/share/keyrings/datadog-archive-keyring.gpg --import --batch
curl https://keys.datadoghq.com/DATADOG_APT_KEY_382E94DE.public | sudo gpg --no-default-keyring --keyring /usr/share/keyrings/datadog-archive-keyring.gpg --import --batch
curl https://keys.datadoghq.com/DATADOG_APT_KEY_F14F620E.public | sudo gpg --no-default-keyring --keyring /usr/share/keyrings/datadog-archive-keyring.gpg --import --batch

sudo apt -y update
sudo apt -y install observability-pipelines-worker datadog-signing-keys

sudo cat <<"EOF" > /etc/default/observability-pipelines-worker
DD_API_KEY=${api-key}
DD_OP_PIPELINE_ID=${pipeline-id}
DD_SITE=${site}
EOF

sudo cat <<"EOF" > /etc/observability-pipelines-worker/pipeline.yaml
${pipeline-config}
EOF

# Mount the associated EBS drive at the data directory.
device=$(get_opw_ebs_drive)
sudo mkfs.xfs $device
sudo mount -o rw $device /var/lib/observability-pipelines-worker
sudo chown observability-pipelines-worker:observability-pipelines-worker /var/lib/observability-pipelines-worker

sudo systemctl restart observability-pipelines-worker