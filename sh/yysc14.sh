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

mi=`fun mobile_info.sql`
md=`fun myshow_dictionary.sql`
so=`fun detail_myshow_saleorder.sql u`
dub=`fun detail_user_base_info.sql`
cit=`fun dim_myshow_city.sql`
sme=`fun dp_myshow__s_messagepush.sql u`

file="bs30"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select 
    case when 1 in (\$dim) then pt
    else 'all' end as pt,
    case when 2 in (\$dim) then province_name
    else 'all' end as province_name,
    case when 3 in (\$dim) then city_name
    else 'all' end as city_name,
    case when 4 in (\$dim) then age
    else 'all' end as age,
    count(distinct mobile) user_num
from (
    select
        md.value2 as pt,
        case when cit.city_id is not null then cit.city_id
        else mi.city_id end as city_id,
        datediff(dt,birthday)/365 age,
        so.mobile
    from (
        select
            dt,
            sellchannel,
            meituan_userid,
            mobile,
            row_number() over (partition by mobile order by dt desc) rank
        from (
            select
                substr(pay_time,1,10) dt,
                sellchannel,
                case when sellchannel in (1,2,5) then meituan_userid
                else -99 end as meituan_userid,
                usermobileno as mobile
            $so
                and performance_id in (\$performance_id)
                and sellchannel not in (9,10,11)
                and usermobileno rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                and usermobileno not in (13800138000,13000000000)
                and 1 in (\$action_flag)
            union all
            select
                substr(CreateTime,1,10) as dt,
                sellchannel,
                case when usertype=2 and sellchannel in (1,2,5) then userid
                else -99 end as meituan_userid,
                phonenumber as mobile
            from
                origindb.dp_myshow__s_messagepush 
            where
                phonenumber is not null
                and CreateTime>'2018-03-01'
                and performanceid in (\$performance_id)
                and 2 in (\$action_flag)
                and phonenumber rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                and phonenumber not in (13800138000,13000000000)
            ) sro
        ) so
        left join (
            $dub
                and city_id is not null
            ) dub
        on dub.userid=so.meituan_userid
        and so.meituan_userid<>-99
        and rank=1
        left join (
            $md
            and key_name='sellchannel'
            ) md
        on md.key=so.sellchannel
        left join (
            $mi
            ) mi
        on mi.mobile=substr(so.mobile,1,7)
        left join (
            $cit
            ) cit
        on cit.mt_city_id=dub.city_id
    where
        rank=1
    ) sim
    left join (
        $cit
        ) ciy
    on ciy.city_id=sim.city_id
group by
    case when 1 in (\$dim) then pt
    else 'all' end,
    case when 2 in (\$dim) then province_name
    else 'all' end,
    case when 3 in (\$dim) then city_name
    else 'all' end,
    case when 4 in (\$dim) then age
    else 'all' end
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


