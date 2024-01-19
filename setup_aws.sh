#! /bin/bash

# Sets up the AWS CLI on an Ubuntu 20.04/22.04 machine

# Install the aws cli
if ( which aws > /dev/null ); then
  echo 'aws cli already installed 🟢'
else
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -r aws/ awscliv2.zip
fi

# Verify AWS cli installation
if ( which aws > /dev/null ); then
  echo "$(aws --version)"
else
  echo 'aws was not installed successfully 🔴'
fi