#!/bin/bash
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
path="/Users/fannian/Documents/my_code/"
fun() {
echo `cat ${path}sql/${1}.sql | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
=`fun ` 
file=""
attach="${path}doc/${file}.sql"

echo "
select
from
    (
    )
"|tee ${attach}

${presto_e}"
${se}
with as (
${}
),
temp as (select 1)
"|grep -iv "SET">${attach}

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
presto_f=${presto_e/-execute/f}
mysql_e="mysql -h10.50.50.48 -P3360 -ubiuser -pkOi9H-G3I;vvnVt4 -N -e"
mysql_f=${mysql_e/-e/-dsalesorder<}
spark_e="spark-sql --master spark://hdn8:9077 -e"
hive_e="/opt/hive/bin/hive -e "
hive_f="/opt/hive/bin/hive -f "
#非常用，文件大小检验
fsize=`ls -l ${attach} | cut -d' ' -f 5`
if [ ${fsize} -ge 25000000 ]
then
${attach}=""
content="﻿文件大于25MB未发出，邮件由系统发出，有问题请联系樊年"
exit 0
fi

presto_e="/opt/presto/bin/presto --server hc:9980 --catalog hive --execute "
se="set session optimize_hash_generation=true;"
fut() {
echo `grep -iv "\-time" ${path}sql/${1}.sql`
}
