#!/bin/bash
# This runs from any POSIX shell that has kubectl installed and pointing at the correct cluster

# for debugging, delete the file at the start of every run so it doesn't endlessly append
rm -f $(kubectl config view --minify | grep name | cut -f 2- -d "":"" | tr -d "" "" | head -1)__kube__pcidss.txt
exec > $(kubectl config view --minify | grep name | cut -f 2- -d "":"" | tr -d "" "" | head -1)__kube__pcidss.txt 2>&1 # Pipe STDOUT and STDERR
set -x #echo on

# Evidence metadata
date
kubectl config view

#######################################################################################################################
# Kubernetes users, roles, and bindings.
# Supports PCI DSS Requirements 3.3.b, 7.1.1, 7.1.4, 7.2.1 - 7.2.3, 8.1, 8.1.2, 8.5.a
#######################################################################################################################
for i in clusterrole clusterrolebinding role rolebinding serviceaccount
do
    kubectl get $i --all-namespaces -o yaml
done


#######################################################################################################################
# API server TLS certificate details.
# Supports PCI DSS Requirements 7.2.2, 8.2, 8.2.1, 8.3, 8.3.1, 8.3.2
#######################################################################################################################
for i in tls1 tls1_1 tls1_2 tls1_3
do
    openssl s_client -connect $(kubectl config view --minify | grep server | cut -f 3- -d ""/"" | tr -d "" "") -$i
done


#######################################################################################################################
# Network policy and service configurations demonstrating that pod communication is restricted.
# Supports PCI DSS Requirements 1.1.6.c, 1.2.1, 1.2.3, 1.3.1- 1.3.7, 2.2.2 - 2.2.5, 2.3, 6.2.b, 8.2.1
#######################################################################################################################
for i in ingress namespace networkpolicy pods service
do
    kubectl get $i  -o yaml -A
done


#######################################################################################################################
# Kubernetes version in use.
# Supports PCI DSS Requirement 6.2
#######################################################################################################################
kubectl version


set +x # echo off