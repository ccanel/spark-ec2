#!/bin/bash

EPHEMERAL_HDFS=/root/ephemeral-hdfs

# Set hdfs url to make it easier
HDFS_URL="hdfs://$PUBLIC_DNS:9000"
echo "export HDFS_URL=$HDFS_URL" >> ~/.bash_profile

pushd /root/spark-ec2/ephemeral-hdfs
source ./setup-slave.sh

for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  ssh -t -t $SSH_OPTS root@$node "/root/spark-ec2/ephemeral-hdfs/setup-slave.sh" & sleep 0.3
done
wait

/root/spark-ec2/copy-dir $EPHEMERAL_HDFS/conf

echo "Stopping ephemeral HDFS..."
# The scripts directory is different depending on the version.
scripts_dir_1=$EPHEMERAL_HDFS/sbin
scripts_dir_2=$EPHEMERAL_HDFS/bin
if [ -e $scripts_dir_1/stop-dfs.sh ] ; then
    scripts_dir_to_use=$scripts_dir_1
else
    scripts_dir_to_use=$scripts_dir_2
fi

$scripts_dir_to_use/stop-dfs.sh
/root/spark-ec2/ephemeral-hdfs/clear_hdfs_dirs.sh
$scripts_dir_to_use/slaves.sh /root/spark-ec2/ephemeral-hdfs/clear_hdfs_dirs.sh

echo "Formatting ephemeral HDFS namenode..."
$EPHEMERAL_HDFS/bin/hdfs namenode -format

echo "Starting ephemeral HDFS..."
$scripts_dir_to_use/start-dfs.sh

popd
