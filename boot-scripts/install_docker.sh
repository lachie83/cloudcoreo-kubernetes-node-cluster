#!/bin/bash

yum install -y docker
/etc/init.d/docker start
chkconfig docker on
