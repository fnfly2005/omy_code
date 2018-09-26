#--------------------猫眼演出readme-------------------
#*************************api3.0*******************
#2.0新增实时模版;3.0函数模块化
#!/bin/bash
source ./fuc.sh

=`fun `

fus() {
echo "
select
from (
${lim-;}"
}

fuc $1 $file

#!/bin/bash
source ./fuc.sh

beg_key=
end_key=

=`fun  $beg_key $end_key`

fus() {
echo "
select
from (
${lim-limit 20000;}"
}

fuc $1 ss_

#!/bin/bash
path="/Users/fannian/Documents/my_code/"
clock="00"
t1=${1:-`date -v -1d +"%Y-%m-%d ${clock}:00:00"`}
t2=${2:-`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) + 86400) +"%Y-%m-%d ${clock}:00:00"`}
t3=`date -j -f %s $(expr $(date -j -f%Y-%m-%d ${t1% *} +%s) - 86400) +"%Y-%m-%d ${clock}:00:00"`
fun() {
echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/-time1/${2:-${t1% *}}/g;
s/-time2/${3:-${t2% *}}/g;s/-time3/${4:-${t3% *}}/g"`
}
=`fun ` 
file=""
lim="limit 100000;"
attach="${path}doc/${file}.sql"
echo "
select
from (

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

fun() {
    if [ $2x == dx ];then
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
