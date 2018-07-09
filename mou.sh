#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************mou1.0*******************
# 
file="sh/${1}.sh"

if [ ${2}r == nr ]
#加上任意字符，如r 避免空值报错
then
cat api.sh | head -40 >$file
echo "succuess! mode:normal path:$file"
elif [ ${2}r == rr ]
then 
cat api.sh | head -80 | tail -40 >$file
echo "succuess! mode:realtime path:$file"
fi
