#!/usr/bin/env bash

G13D_HOME="/usr/lib/g13d"

if [ -d "./build" ]
then
    echo "using existing build from ./build ..."
else
    echo "executing ./build.sh ..."
    ./build.sh
fi

cd build

mkdir -p "$G13D_HOME"

echo "installing scripts and bindings to $G13D_HOME ..."
cp -r * "$G13D_HOME/" && chmod a+x "$G13D_HOME"/g13d*

#create symlinks for executables in /usr/bin and /etc/init.d
echo "create symlinks for g13d-run in /usr/bin ..."
ln -s "$G13D_HOME/g13d-run" /usr/bin/g13d-run
mkdir "/tmp/g13d" && chmod -R a+rwx "/tmp/g13d"

echo "create symlinks for g13d-service in /etc/init.d ..."
ln -s "$G13D_HOME/g13d-service" /etc/init.d/g13d-service

#create symlink for bind configs in /etc/g13d
echo "create symlink for g13d config dir in /etc/g13d ..."
ln -s "$G13D_HOME/etc" /etc/g13d.d

#setup service
echo "systemd service setup ..."
ln -s  "$G13D_HOME/g13d-service.service" /lib/systemd/g13d-service.service
systemctl daemon-reload
systemctl enable g13d-service.service



