#!/bin/bash
# Copyright (c) 2017 Lexicon & XP Dev team
# Script written by Lexicon
echo "Updating System And Sources"
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y -qq
echo "Installing Git Software"
sudo apt-get install git -y -qq
echo "Cloning XPCoin"
git clone https://github.com/eXperiencePoints/XPCoin

echo "Installing Dependencies - build-essential"
sudo apt-get install build-essential -y -qq

echo "Installing Dependencies - libssql-dev"

sudo apt-get install libssl-dev -y -qq

echo "Installing Dependencies - libdb4.8++-dev"
sudo apt-get install libdb4.8-dev -y -qq
sudo apt-get install libdb4.8++-dev -y -qq

echo "Installing Dependencies - libboost-all-dev"

sudo apt-get install libboost-all-dev -y -qq

echo "Installing Dependencies - libqrencode-dev"

sudo apt-get install libqrencode-dev -y -qq

echo "Compiling XPCoin"

cd XPCoin/
cd src/
make -f makefile.unix 

chmod +x XPd
strip XPd

read -p "Would you like to download and unzip the blockchain?"  CONT
if [ "$CONT" = "y" ]; then
echo "Downloading BootStrap"

sudo apt install unzip -y -qq
wget https://pool1.xpcoin.io/files/bootstrap-latest.zip --no-check-certificate
echo "Unzipping Files"
unzip ./bootstrap-latest.zip -d ~/.XP

else
  echo "XP Compile Finished";
fi


