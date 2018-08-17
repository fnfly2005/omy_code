#!/bin/bash
source ./fuc.sh

dss=`fun dim_myshow_salesplan.sql`
file="bs40"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    substr(createtime,1,4) as yea,
    count(distinct cus.tpid) as cus_num,
    count(DISTINCT ss.customer_id) as per_cus_num
from 
    origindb.dp_myshow__s_customer cus
    left join (
        select distinct 
            customer_id
        from 
            mart_movie.dim_myshow_salesplan
        ) ss
    on ss.customer_id=cus.tpid
where 
    createtime<='2018-08-17'
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
