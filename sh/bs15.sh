#!/bin/bash
path="/Users/fannian/Documents/my_code/"
t1='$time1'
fun() {
echo `cat ${path}sql/${1} | sed "s/'-time3'/substr(date_add('day',-1,timestamp'$t1'),1,10)/g" | grep -iv "/\*"`
}

ss=`fun detail_myshow_salesplan.sql`
sho=`fun dim_myshow_show.sql`

file="bs15"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
from (
    select
       dt,
       count(distinct show_id) as s_num,
       count(distinct case when dg<=7 then show_id end) as s_7num,
       count(distinct case when dg<=15 then show_id end) as s_15num,
       count(distinct case when dg<=30 then show_id end) as s_30num
    from (
        select
            dt,
            date_diff('day',
                date_parse(dt,'%Y-%m-%d'),
                date_parse(sho.show_starttime,'%Y-%m-%d')) as dg,
            show_id 
        from (
            $ss
            and salesplan_sellout_flag=0
            ) ss
            join (
            $sho
            ) sho
            on ss.show_id=sho.show_id
            and sho.show_starttime>=ss.dt
        group by
            1,2,3
        ) as ss1
    group by
        1
    ) ss2
    left join (
    select
        
    from (
        $spo
        ) spo
    group by
        
$lim">${attach}

echo "succuess,detail see ${attach}"

