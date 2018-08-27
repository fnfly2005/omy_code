#!/bin/bash
#2.0 2018-08-14
source ./fuc.sh
so=`fun detail_myshow_salepayorder.sql`
soi=`fun dp_myshow__s_orderidentification.sql u`
md=`fun myshow_dictionary.sql`
pro=`fun dim_myshow_project.sql`

file="bd15"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    count(distinct so.order_id) as order_num
from (
    $so
    ) so
    join (
        select
            OrderID as order_id,
            count(distinct IDNumber) as id_num,
            count(distinct case when TicketNumber>0 then IDNumber end) as idti_num
        $soi
        group by
            1,2
        ) soi
    using(order_id)
    left join (
        $pro
        ) pro
    on pro.project_id=so.project_id
where
    id_num>ticket_num
group by
    1
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
