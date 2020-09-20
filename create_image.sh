#!/bin/bash
echo "Username dockerhub: ";
read param;
echo "Password dockerhub: ";
read param2;
docker login --username=$param --password=$param2
docker build -t $param/mvn-intergration-tests-image:latest .
docker push $param/mvn-intergration-tests-image:latest