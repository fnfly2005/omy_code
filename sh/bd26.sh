#!/bin/bash
#电子票检票二维码
source ./fuc.sh

ket=`fun sql/dp_myshow__s_orderticket.sql`
spo=`fun sql/detail_myshow_salepayorder.sql u`
file="bd26"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    qrcode
from (
    select
        order_id
    $spo
        and performance_id in (\$performance_id)
    ) spo
    join (
        $ket
            and qrcode is not null
            and CreateTime>'2017-11-17'
        ) ket
    on ket.order_id=spo.order_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
