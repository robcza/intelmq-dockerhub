#!/bin/bash
service redis-server start
/opt/intelmq/bin/intelmqctl --botnet start
tail -f /opt/intelmq/var/log/*

