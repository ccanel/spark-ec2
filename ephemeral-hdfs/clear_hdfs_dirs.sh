#!/bin/bash

echo "Deleting old HDFS directories..."
# Delete the DataNode directories. This is different depending on the version.
getconf_version_1=/root/ephemeral-hdfs/sbin/hdfs
getconf_version_2=/root/ephemeral-hdfs/bin/hdfs
if [ -e $getconf_version_1 ] ; then
    getconf_version_to_use=$getconf_version_1
else
    getconf_version_to_use=$getconf_version_2
fi
data_dirs=$($getconf_version_to_use getconf -confKey dfs.datanode.data.dir)
data_dirs_list=$(echo $data_dirs | tr "," "\n")
for data_dir in $data_dirs_list ; do
    echo "Deleting contents of $data_dir"
    rm -rfv $data_dir/*
done

# Delete the NameNode directory.
echo "Deleting NameNode data..."
rm -rfv /mnt/ephemeral-hdfs/dfs/name/*
