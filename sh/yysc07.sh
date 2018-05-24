#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

pw=`fun hd_detail_flow_pv_wide_report.sql` 
md=`fun myshow_dictionary.sql`
file="yysc07"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    case when md.value2 is not null then md.value2
    else fromtag end fromtag,
    dt,
    md2.value2 as pt,
    uv,
    order_num
from (
    select
        fp1.fromtag,
        fp1.dt,
        fp1.app_name,
        approx_distinct(fp1.union_id) as uv,
        count(distinct order_id) as order_num
    from (
        select
            partition_date as dt,
            app_name,
            case when regexp_like(url_parameters,'[Ff]romTag=') then split_part(regexp_extract(url_parameters,'[Ff]romTag=[^&]+'),'=',2)
            when regexp_like(substr(url,40,40),'fromTag%3D') then split_part(regexp_extract(url,'fromTag%3D[^%]+'),'%3D',2)
            when regexp_like(substr(url,40,40),'from=') then split_part(regexp_extract(url,'from=[^&]+'),'=',2)
            else 'other'
            end as fromtag,
            union_id
        from
            mart_flow.detail_flow_pv_wide_report
        where partition_date>='\$\$begindate'
            and partition_date<'\$\$enddate'
            and (
                (partition_log_channel='firework'
                and \$source=1)
                or (partition_log_channel='cube'
                and \$source=2)
                )
            and partition_app in (
            'movie',
            'dianping_nova',
            'other_app',
            'dp_m',
            'group'
            )
            and regexp_like(page_name,'\$id')
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
        1,2,3
    ) fp2
    left join (
            $md
            and key_name='fromTag'
            ) md
    on md.key=fp2.fromtag
    left join (
            $md
            and key_name='app_name'
            ) md2
    on md2.key=fp2.app_name
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
