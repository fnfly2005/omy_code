#!/bin/bash
#exec "/Users/fannian/my_code/mou.sh" "$@"
file=`echo $0 | sed "s/[a-z]*\.sh//g;s/.*\///g"`
echo $file
