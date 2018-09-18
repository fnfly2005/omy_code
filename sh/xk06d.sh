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
    uv
from (
    $mp
    ) mp
    left join (
        select 
            page_identifier,
            approx_distinct(union_id) uv
        $ort
        group by
            1
        ) as fpw
    on mp.page_identifier=fpw.page_identifier
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


