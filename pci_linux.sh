#!/bin/sh

# for debugging, delete the file at the start of every run so it doesn't endlessly append
rm -f linux__$(hostname).txt

set -x #echo on

exec > linux__$(hostname).txt 2>&1 # Pipe STDOUT and STDERR to file

# Evidence metadata
hostname
date

#######################################################################################################################
# Local users, groups, and sudo permissions
# Supports PCI DSS Requirements 3.3.b, 7.1.1, 7.1.4, 7.2.1 - 7.2.3, 8.1, 8.1.2, 8.5.a
#######################################################################################################################
for i in passwd group sudoers
do
	sudo cat /etc/$i
done


#######################################################################################################################
# SSH configuration including allowed ciphers and MACs, protocol version, and idle timeout.
# Supports PCI DSS Requirements 7.2.2, 8.2, 8.2.1, 8.3, 8.3.1, 8.3.2
#######################################################################################################################
# -G Causes ssh to print its configuration after evaluating Host and Match blocks and exit.
ssh -G 127.0.0.1


#######################################################################################################################
# Password configurations including secure storage (hashing algorithm), rotation, length, complexity, and history.
# Account lockout configurations including number of attempts, and lockout period. 
# Supports PCI DSS Requirements 8.1.4, 8.1.6.a, 8.1.7, 8.2.3, 8.2.4, 8.2.5
#######################################################################################################################

# This is the first divergence between RHEL and Debian. So sometimes you'll have an empty result.
# Shows hashing algorithm used by system passwords. Only return the first 3 digis. 
# $1$ is MD5, $2a$ is Blowfish, $2y$ is Blowfish, $5$ is SHA-256, $6$ is SHA-512
sudo awk '{FS = "$"}{print $1, $2}' /etc/shadow

cat /etc/login.defs
cat /etc/security/pwquality.conf

# This works on a Debian/Ubuntu server
cat /etc/pam.d/common-password
cat /etc/pam.d/common-auth

# This work on a RHEL/CentOS server
cat /etc/pam.d/system-auth
cat /etc/pam.d/password-auth
cat /etc/pam.d/system-auth


#######################################################################################################################
# Host-based firewall ruleset.
# Supports PCI DSS Requirements 1.1.6.c, 1.2.1, 1.2.3, 1.3.1- 1.3.7, 2.2.2 - 2.2.5, 2.3, 6.2.b, 8.2.1
#######################################################################################################################
ip address show
sudo iptables -L


#######################################################################################################################
# Running services/processes, active network connections, and CPU information. 
# Supports PCI DSS Requirements 2.2.1 - 2.2.5, 2.3
#######################################################################################################################
sudo ps -auxww
netstat -peanut
lscpu


#######################################################################################################################
# Audit logging configuration showing audit rules and remote syslog target. 
# Supports PCI DSS Requirements10.1
#######################################################################################################################
sudo auditctl -s # Report  the kernel's audit subsystem status.
sudo auditctl -l #  List all rules
cat /etc/rsyslog.conf # Log target


#######################################################################################################################
# Patch history, current patch status, and OS version. 
# Supports PCI DSS Requirement 6.2
#######################################################################################################################

cat /etc/os-release

# This works on a Debian/Ubuntu server
sudo apt-get update # Update the package cache
sudo grep " install " /var/log/dpkg.log /var/log/dpkg.log.1 # Installed packages by date
apt list --upgradable # What can be upgraded now?

# This work on a RHEL/CentOS server
sudo rpm -qa --last # Installed packages by date
sudo yum check-update # What can be upgraded now?

set +x # echo off
