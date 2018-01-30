#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

pw=`fun hd_detail_flow_pv_wide_report.sql` 
file="yysc07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
    when regexp_like(url,'fromTag%3D') then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
    when regexp_like(url,'from=') then split_part(regexp_extract(url,'from=[^&]+'),'=',2)
    else 'other'
    end as fromtag,
    count(distinct union_id) as uv
from
    (
    $pw
    and regexp_like(page_name,'$id')
    ) as pw
group by
    1,2
$lim">${attach}

echo "succuess,detail see ${attach}"

