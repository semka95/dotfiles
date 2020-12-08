#!/bin/bash

mac=`macchanger --show wlp2s0 |grep -o '[^ ,]\+'| sed '3q;d'`
echo '' $mac
