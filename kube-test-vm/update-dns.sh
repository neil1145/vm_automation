#!/bin/bash

sudo sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf

sudo service systemd-resolved restart