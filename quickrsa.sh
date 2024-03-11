#!/bin/bash
# A shell script to connect to my aws instace by unpacking the rsa key from a password protected 7zip file


echo -n "Enter the password: "
read -s password
echo

path_to_keys="./keys/"
encrypted_keys=$(find $path_to_keys -name "*.7z")
tmp_dir=$(mktemp -d)
ec2_instance="ec2-user@ip"

7z x -p"$password" -o"$tmp_dir" $encrypted_keys > /dev/null

if [ $? -eq 0 ]; then
    chmod 600 $tmp_dir/*
    chmod 644 $tmp_dir/*.pub
    ssh -i $tmp_dir/* $ec2_instance
    rm -rf $tmp_dir
else
    echo "Wrong password"
    rm -rf $tmp_dir
fi
