#!/bin/bash
usage="Usage: ./diff_dir.sh [days]"
path="/user/flume/"
delpath="/tmp/hdfsdelete.txt"
deldirpath="/tmp/hdfsdirdelete.txt"

if [ ! "$1" ]
then
  echo $usage;
  exit 1;
fi

now=$(date +%s);

# Loop through files
sudo -u hdfs hdfs dfs -ls -R $path |grep -E  *.[0-9]\{13\} | while read f; do
  # Get File Date and File Name
  file_date=`echo $f | awk '{print $6}'`;
  file_name=`echo $f | awk '{print $8}'`;

  # Calculate Days Difference
  difference=$(( ($now - $(date -d "$file_date" +%s)) / (24 * 60 * 60) ));
  if [ $difference -gt $1 ]; then
    # Insert delete logic here
   echo "sudo -u hdfs hdfs dfs -rm -skipTrash $file_name" >> $delpath
   echo "Deleting this file $file_name is dated $file_date.";
 fi
done

sudo -u hdfs hdfs dfs -ls -R $path |grep -Ev  *.[0-9]\{13\} | while read f; do
  # Get File Date and File Name
  dir_date=`echo $f | awk '{print $6}'`;
  dir_name=`echo $f | awk '{print $8}'`;

  # Calculate Days Difference
  difference=$(( ($now - $(date -d "$dir_date" +%s)) / (24 * 60 * 60) ));
  if [ $difference -gt $1 ]; then
    # Insert delete logic here
    echo "sudo -u hdfs hdfs dfs -rm -skipTrash $dir_name" >> $deldirpath
    echo "Deleting this dir $dir_name is dated $dir_date.";
  fi
done

bash $delpath
rm -f $delpath
bash $deldirpath
rm -f $deldirpath
