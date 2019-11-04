#!/bin/bash

cp -rvf /media/services/.ssh /var/jenkins_home/
chown jenkins. -R /var/jenkins_home/.ssh
chown jenkins:entermedia -R /home/entermedia/workspace
