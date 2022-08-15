#!/bin/bash

link="https://github.com/anchore/syft/archive/refs/heads/main.zip"
path="/var/lib/docker"

for s in brasil{2..22}
do
   ssh root@${s} "wget $link && unzip main.zip && cd syft-main && ./install.sh && cd bin/ && ./syft dir:$path |grep log4j"
done