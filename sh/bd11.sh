#!/bin/bash
source ./fuc.sh
dms=`fun detail_myshow_salesplan.sql u`
ssp=`fun dim_myshow_salesplan.sql`
ssu=`fun dim_myshow_salesplan.sql u`

file="bd11"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select distinct
    case when \$online=1 then dt
    else minon_dt end as dt,
	ssp.customer_type_name,
	ssp.customer_lvl1_name,
	ssp.area_1_level_name,
	ssp.area_2_level_name,
	ssp.province_name,
	ssp.city_name,
	ssp.category_name,
	ssp.performance_id,
	ssp.performance_name,
	ssp.shop_name,
	ssp.bd_name
from (
    $ssp
    ) ssp
    left join (
        select
            partition_date as dt,
            salesplan_id
        $dms
            and salesplan_sellout_flag=0
            and \$online=1
        ) dms
    on ssp.salesplan_id=dms.salesplan_id
    left join (
        select
            performance_id,
            substr(min(salesplan_ontime),1,10) as minon_dt
        $ssu
            and \$online=0
        group by
            1
        ) ssu
    on ssp.performance_id=ssu.performance_id
    and minon_dt>='\$\$begindate'
    and minon_dt<'\$\$enddate'
where
    (\$online=1 
    and dms.salesplan_id is not null)
    or (\$online=0
    and ssu.performance_id is not null)
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
