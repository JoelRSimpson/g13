#!/usr/bin/env bash

rm /usr/bin/g13d-run
rm /etc/g13d.d
rm /etc/init.d/g13d-service
rm /lib/systemd/g13d-service.service
rm -rf /usr/lib/g13d/
rm -rf /tmp/g13d
systemctl daemon-reload
