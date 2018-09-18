#!/bin/bash
#演出模块埋点配置字典
source ./fuc.sh

mp=`fun dim_myshow_pv.sql`
mm=`fun dim_myshow_mv.sql`
md=`fun myshow_dictionary.sql`
fmw=`fun detail_flow_mv_wide_report.sql ut`

file="xk06"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    '\$\$today{-1d}' dt,
    page_name_my,
    event_name_lv1,
    event_name_lv2,
    mm.event_id,
    mm.biz_par,
    mm.biz_typ,
    cid_type,
    mm.page_identifier,
    user_intention,
    user_int,
    page_loc,
    event_type,
    uv
from (
    $mm
    ) mm
    left join (
        select 
            event_id,
            page_identifier,
            event_type,
            approx_distinct(union_id) uv
        $fmw
        group by
            1,2,3
        ) as fpw
    on mm.event_id=fpw.event_id
    and mm.page_identifier=fpw.page_identifier
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


