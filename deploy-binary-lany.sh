#!/bin/bash
set -e

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


# Configure fail2ban
echo "Configuring fail2ban for SSH..."
sudo apt install fail2ban

# Configure fail2ban for SSH
sudo cat <<EOL > "/etc/fail2ban/jail.local"
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 604800
EOL

# Confirm the file has been created
if [ -f "/etc/fail2ban/jail.local" ]; then
    echo "File created successfully at $FILE"
else
    echo "Failed to create the file"
fi

# Restart fail2ban
echo "Restarting fail2ban..."
sudo systemctl restart fail2ban

echo "You can check the status of the SSH jail with: sudo fail2ban-client status sshd"

