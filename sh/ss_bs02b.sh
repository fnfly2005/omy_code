#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api2.0*******************
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/-time1/$3/g;s/-time2/$4/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/-time1/$3/g;s/-time2/$4/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}
beg_key=2734699
end_key=2741187

so=`fun S_Order.sql t $beg_key $end_key`
sos=`fun S_OrderSalesPlanSnapshot.sql t $beg_key $end_key`

file="ss_bs02"
attach="${path}doc/${file}.sql"
lim="limit 20000;"

echo "
$sos
$lim
">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
