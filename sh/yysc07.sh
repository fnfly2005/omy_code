#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

pw=`fun hd_detail_flow_pv_wide_report.sql` 
md=`fun myshow_dictionary.sql`
file="yysc07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    dt,
    case when value2 is not null then value2
    else fromtag end fromtag,
    uv,
    order_num
from (
    select
        fp1.dt,
        fp1.fromtag,
        approx_distinct(fp1.union_id) as uv,
        count(distinct order_id) as order_num
    from (
        select
            dt,
            app_name,
            case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
            when regexp_like(url,'fromTag%3D') then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
            when regexp_like(url,'from=') then split_part(regexp_extract(url,'from=[^&]+'),'=',2)
            else 'other'
            end as fromtag,
            union_id
        from
            (
            $pw
            and regexp_like(page_name,'\$id')
            ) as fpw
        ) fp1
        left join (
            select 
                partition_date as dt,
                app_name,
                union_id,
                order_id
            from mart_flow.detail_flow_mv_wide_report
            where partition_date>='\$\$begindate'
                and partition_date<'\$\$enddate'
                and partition_log_channel='movie'
                and partition_etl_source='2_5x'
                and partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
                and event_id='b_WLx9n'
            ) as fmw
        on fp1.dt=fmw.dt
        and fp1.app_name=fmw.app_name
        and fp1.union_id=fmw.union_id
    group by
        1,2
    ) fp2
    left join (
            $md
            and key_name='fromTag'
            ) md
    on md.key=fp2.fromtag
$lim">${attach}

echo "succuess,detail see ${attach}"

