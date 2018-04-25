#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == ex ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

=`fun ` 
file=""
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
from (
    )
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi



#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fun() {
echo `cat ${path}sql/${1} | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
=`fun ` 
file=""
lim=";"
attach="${path}doc/${file}.sql"
echo "select
from
    (
    )
$lim">${attach}
echo "succuess,detail see ${attach}"

fut() {
echo `grep -iv "\-time" ${path}sql/${1} | grep -iv "/\*"`
}

model=${attach/00output/model}
cp ${model} ${attach}

script="${path}bin/mail.sh"
topic="﻿${file}数据报表"
content="﻿数据从${t1% *} 0点至${t2% *} 0点，邮件由系统发出，有问题请联系樊年"
address="fannian@maoyan.com"
my_name=(
)
for i in "${my_name[@]}"
do 
address="${address}, ${i}@maoyan.com"
done
bash ${script} "${topic}" "${content}" "${attach}" "${address}"


tp=`date -d today +"%s"`
#检验输入变量
if [ ${end% *} \< ${sta% *} ]
then 
echo "input errer"
exit 0
fi
#拆分文件
split -b 7m 00output/hd04_andriod.csv andriod
split -l 100000 00output/hd04_andriod.csv andriod
#循环
mode="0"
min=0
max=2
list=(
8
5
4
)
while [ ${min} -le ${max} ]
do
content=${list[${min}]}
echo "min:"${min}
echo "content:"${content}
echo "max:"${max}
let min=min+1
done
#backup 方式
#非常用，文件大小检验
fsize=`ls -l ${attach} | cut -d' ' -f 5`
if [ ${fsize} -ge 25000000 ]
then
${attach}=""
content="﻿文件大于25MB未发出，邮件由系统发出，有问题请联系樊年"
exit 0
fi

se="set session optimize_hash_generation=true;"
