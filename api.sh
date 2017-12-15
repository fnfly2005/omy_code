#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
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
echo `grep -iv "\-time" ${path}sql/${1}.sql | grep -iv "/\*"`
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
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
