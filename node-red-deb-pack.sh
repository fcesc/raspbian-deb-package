#!/bin/bash
#
# Copyright 2015 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VER=0.12.2

cd /usr/local/lib/node_modules/node-red/node_modules
sudo find . -type d -name test -exec rm -r {} \;
sudo find . -type d -name doc -exec rm -r {} \;
sudo find . -type d -name example* -exec rm -r {} \;
sudo find . -type d -name sample -exec rm -r {} \;
sudo find . -type d -iname benchmark* -exec rm -r {} \;
sudo find . -type d -iname .nyc_output -exec rm -r {} \;
sudo find . -type d -iname unpacked -exec rm -r {} \;

sudo find . -name bench.gnu -type f -exec rm {} \;
sudo find . -name .npmignore -type f -exec rm {} \;
sudo find . -name .travis.yml -type f -exec rm {} \;
sudo find . -name .jshintrc -type f -exec rm {} \;
sudo find . -iname README.md -type f -exec rm {} \;
sudo find . -iname HISTORY.md -type f -exec rm {} \;
sudo find . -iname CONTRIBUTING.md -type f -exec rm {} \;
sudo find . -iname CHANGE*.md -type f -exec rm {} \;
sudo find . -iname .gitmodules -type f -exec rm {} \;
sudo find . -iname .gitattributes -type f -exec rm {} \;
sudo find . -iname .gitignore -type f -exec rm {} \;
sudo find . -iname "*~" -type f -exec rm {} \;

# slightly more risky
sudo find . -iname test* -exec rm -r {} \;
#sudo find . -iname LICENSE* -type f -exec rm {} \;

cd /usr/local/lib/node_modules/node-red-admin/node_modules
sudo find . -type d -name test -exec rm -r {} \;
sudo find . -type d -name doc -exec rm -r {} \;
sudo find . -type d -name example* -exec rm -r {} \;
sudo find . -type d -name sample -exec rm -r {} \;
sudo find . -type d -iname benchmark -exec rm -r {} \;
sudo find . -type f -iname bench.gnu -exec rm -r {} \;
sudo find . -name .npmignore -type f -exec rm {} \;
sudo find . -name .travis.yml -type f -exec rm {} \;
sudo find . -name .jshintrc -type f -exec rm {} \;
sudo find . -iname README.md -type f -exec rm {} \;
sudo find . -iname HISTORY.md -type f -exec rm {} \;
sudo find . -iname CONTRIBUTING.md -type f -exec rm {} \;
sudo find . -iname CHANGE*.md -type f -exec rm {} \;
sudo find . -iname .gitmodules -type f -exec rm {} \;
sudo find . -iname .gitattributes -type f -exec rm {} \;
sudo find . -iname "*~" -type f -exec rm {} \;

echo "Tar up the existing install"
sudo rm -rf /tmp/n*
cd /
#sudo tar zcf /tmp/nred.tgz /usr/local/lib/node_modules/node-red* /usr/local/bin/node-red* /home/pi/.node-red* /usr/share/applications/Node-RED.desktop /etc/init.d/nodered /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
sudo tar zcf /tmp/nred.tgz /usr/local/lib/node_modules/node-red* /usr/local/bin/node-red* /usr/share/applications/Node-RED.desktop /etc/init.d/nodered /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
echo " "
ls -l /tmp/nred.tgz
echo " "

echo "Extract nred.tgz to /tmp directory"
sudo mkdir -p /tmp/nodered_$VER/DEBIAN
sudo tar zxf /tmp/nred.tgz -C /tmp/nodered_$VER
cd /tmp/nodered_$VER

echo "Move from /usr/local/... to /usr/..."
sudo mv usr/local/* usr/
sudo rm -rf usr/local

echo "Reset file owenerships and permissions"
sudo chown -R root:root *
sudo chmod -R -s *
sudo find . -type f -iname "*.js" -exec chmod 644 {} \;
sudo find . -iname "*.json" -exec chmod 644 {} \;
sudo find . -iname "*.yml" -exec chmod 644 {} \;
sudo find . -iname "*.md" -exec chmod 644 {} \;
sudo find . -iname LICENSE -exec chmod 644 {} \;
sudo find . -iname Makefile -exec chmod 644 {} \;
sudo find . -iname *.png -exec chmod 644 {} \;
sudo find . -iname *.txt -exec chmod 644 {} \;
sudo find . -iname *.conf -exec chmod 644 {} \;
sudo find . -type d -exec chmod 755 {} \;
sudo chmod 755 usr/lib/node_modules/node-red/red.js
sudo chmod 755 usr/lib/node_modules/node-red-admin/node-red-admin.js

echo "Create control file"
cd DEBIAN
echo "Package: nodered" | sudo tee control
echo "Version: $VER" | sudo tee -a control
echo "Section: editors" | sudo tee -a control
echo "Priority: optional" | sudo tee -a control
echo "Architecture: armhf" | sudo tee -a control
echo "Depends: nodejs (>= 0.10), nodejs-legacy (>= 0.10), python (>= 2.7)" | sudo tee -a control
echo "Homepage: http://nodered.org" | sudo tee -a control
echo "Maintainer: Dave Conway-Jones <dceejay@gmail.com>" | sudo tee -a control
echo "Description: Node-RED flow editor for the Internet of Things" | sudo tee -a control
echo " A graphical flow editor for event based applications." | sudo tee -a control
echo " Runs on node.js - using a browser for the user interface." | sudo tee -a control
echo " See http://nodered.org for more information, documentation and examples." | sudo tee -a control
echo " ." | sudo tee -a control
echo " Released under Apache v2 License by IBM Corp. 2015." | sudo tee -a control

echo "Build the actual deb file"
cd /tmp/
sudo dpkg-deb --build nodered_$VER
echo " "
ls -lrt no*.deb

echo "Move .deb to /home/pi directory"
sudo mv nodered_$VER.deb /home/pi/
cd /home/pi
sudo chown pi:pi nodered_$VER.deb
echo " "
echo "Now running lintian report"
lintian nodered_$VER.deb > /home/pi/lint.log
echo ' '
echo 'Errors   ' $(cat lint.log | grep E: | wc -l)
echo 'Warnings ' $(cat lint.log | grep W: | wc -l)
echo "All done - see ~/lint.log"