#!/bin/bash
# Generate SSH keys for container authentication

mkdir -p /hdd/home/decasfl/dev/benchmarks/config/ssh
ssh-keygen -t rsa -f /hdd/home/decasfl/dev/benchmarks/config/ssh/id_rsa -N "" -C "tls-benchmarks"
chmod 600 /hdd/home/decasfl/dev/benchmarks/config/ssh/id_rsa
chmod 644 /hdd/home/decasfl/dev/benchmarks/config/ssh/id_rsa.pub