#!/bin/bash
/opt/intelmq/bin/intelmqctl --botnet start
sleep 30s
tail -F /opt/intelmq/var/log/*
