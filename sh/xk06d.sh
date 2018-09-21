#!/bin/bash
#演出页面埋点配置字典
source ./fuc.sh
mp=`fun dim_myshow_pv.sql`
md=`fun dim_myshow_dictionary.sql`
ort=`fun sql/detail_myshow_pv_wide_report.sql ut`

file="xk06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '\$\$today{-1d}' as dt,
    biz_bg_name,
    page_intention,
    page_name_my,
    cid_type,
    mp.page_identifier,
    page_cat,
    biz_bg,
    biz_par,
    sum(uv) as uv,
    sum(custom_uv) as custom_uv
from (
    $mp
    ) mp
    left join (
        select 
            page_identifier,
            app_name,
            approx_distinct(union_id) uv,
            approx_distinct(case when page_name_my='演出详情页' and performance_id is not null then union_id end) custom_uv
        $ort
        group by
            1,2
        ) as fpw
    on mp.page_identifier=fpw.page_identifier
group by
    1,2,3,4,5,6,7,8,9
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


