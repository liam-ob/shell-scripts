#!/bin/bash

# Script to deploy a python program on a binary lane instance

# Make a new user
read -p "Enter the username of the new user: " username
# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User $username already exists."
    exit 1
fi
useradd -m -s /bin/bash -c "Binary Lane User" $username
passwd "$username"
# Add user to sudo group
usermod -aG sudo $username
# switch to user
su - $username

# Install the latest version of python
sudo apt-get update -qq
sudo apt-get install python3.11 -y -qq

# Install nginx
sudo apt-get install nginx -y -qq

# Install curl
sudo apt-get install curl -y -qq

# Install poetry 
curl -sSL https://install.python-poetry.org | python3.11 -
sudo ln -s $HOME/.local/bin/poetry /usr/bin/poetry 
if command -v poetry &> /dev/null
then
    echo "Poetry is installed."
else
    echo "Poetry is NOT installed!"
fi
sudo poetry config virtualenvs.create false
sudo poetry config virtualenvs.in-project true
# Repeat becasue sometimes it doesnt work?
poetry config virtualenvs.create false
poetry config virtualenvs.in-project true
