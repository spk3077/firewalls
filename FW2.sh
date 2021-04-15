#!/usr/bin/env bash

# Sean Kells, 3rd Year CSEC Major
# CSEC 473 Spring Semester 2021

# DOES NOT RETAIN AFTER REBOOT

# REQUIRES ROOT PRIVILEDGES and sed -i 's/\r$//' <file>
# sudo iptables -L

if [ `id -u` -ne 0 ]; then
      echo "This script can be executed only as root, Exiting.."
      exit 1
   fi

# Wiping iptables Rules
iptables -F

# Setting Default Inbound, Outbound, and FORWARD as Drop
# This is to create a Secure default policy.
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Loopback Interfaces 
# Required so internal services can communicate 
iptables -A INPUT -i lo -m comment --comment "Loopback Inbound" -j ACCEPT
iptables -A OUTPUT -o lo -m comment --comment "Loopback Outbound" -j ACCEPT

# ICMP Traffic
iptables -A INPUT -p icmp -m comment --comment "ICMP INBOUND" -j ACCEPT
iptables -A OUTPUT -p icmp -m comment --comment "ICMP OUTBOUND" -j ACCEPT

# Allowing Client DNS Traffic
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allowing Client Web Access
iptables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --sport 3000 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allowing DHCP Client Access
iptables -A INPUT -p udp --sport 67 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allowing Git Client Access
iptables -A INPUT -p tcp --sport 9418 -m conntrack --ctstate ESTABLISHED -j ACCEPT 
iptables -A OUTPUT -p tcp --dport 9418 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allow SSH Client Access
iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allowing SMTP Client Access
iptables -A INPUT -p tcp --sport 25 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 25 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Web Server
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Persistence
sudo apt-get install iptables-persistent -y | echo "y"
sudo iptables-save > /etc/iptables/rules.v4
