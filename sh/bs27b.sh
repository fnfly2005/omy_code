#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path="/Users/fannian/Documents/my_code/"
fun() {
    if [ $2x == ex ];then
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

so=`fun detail_myshow_saleorder.sql u`
per=`fun dim_myshow_performance.sql`
md=`fun myshow_dictionary.sql`
cus=`fun dim_myshow_customer.sql`
sos=`fun detail_myshow_salerealorder.sql`
sme=`fun dp_myshow__s_messagepush.sql u`


file="bs27"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
    sendtag,
    batch_code,
    dt,
    pt,
    case when 0 not in (\$dim) then 'all'
    else send_num end as send_num,
    totalprice,
    order_num
from (
    select
        sendtag,
        batch_code,
        case when dt is null then 'all'
        else dt end as dt,
        case when pt is null then '全部'
        else pt end as pt,
        count(distinct sed.mobile) send_num,
        sum(totalprice) totalprice,
        sum(order_num) order_num
    from (
        select distinct
            se1.mobile,
            sendtag,
            batch_code
        from (
            select
                mobile,
                sendtag,
                batch_code
            from 
                mart_movie.detail_myshow_msuser
            where
                sendtag in ('\$sendtag') 
                and 1 in (\$dit)
            union all
            select
                mobile,
                sendtag,
                batch_code
            from 
                upload_table.send_fn_user
            where
                sendtag in ('\$sendtag') 
                and 1 in (\$dit)
            union all
            select
                mobile,
                sendtag,
                batch_code
            from 
                upload_table.send_wdh_user
            where
                sendtag in ('\$sendtag') 
                and 1 in (\$dit)
            union all
            select
                cast(mobile as bigint) mobile,
                'all' sendtag,
                -99 batch_code
            from
                upload_table.fn_uploadmobile_data
            where
                2 in (\$dit)
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            union all
            select
                cast(mobile as bigint) mobile,
                'all' sendtag,
                -99 batch_code
            from
                upload_table.wdh_uploadmobile_data
            where
                3 in (\$dit)
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            ) se1
            left join (
                select
                    mobile
                from
                    upload_table.black_list_fn
                where
                    \$fit_flag=1
                union all
                select
                    mobile
                from
                    upload_table.wdh_upload
                where
                    \$fit_flag=2
                ) as bl
            on bl.mobile=se1.mobile
        where
            \$send_cat=1
            and bl.mobile is null
        union all
        select
            phonenumber as mobile,
            'all' sendtag,
            -99 batch_code
        $sme
            and \$send_cat=2
            and performanceid in (\$send_performance_id)
        ) sed
        left join (
            select
                mobile,
                dt,
                value2 as pt,
                sum(totalprice) totalprice,
                sum(order_num) order_num
            from (
                select
                    usermobileno as mobile,
                    case when 1 in (\$dim) and 0 not in (\$dim) then substr(pay_time,1,10) 
                    else 'all' end as dt,
                    case when 2 in (\$dim) and 0 not in (\$dim) then sellchannel
                    else -99 end as sellchannel,
                    sum(totalprice) totalprice,
                    count(distinct order_id) order_num
                $so
                    and sellchannel not in (9,10,11)
                    and \$isreal=0
                    and (
                        performance_id in (\$send_performance_id) 
                        or -99 in (\$send_performance_id)
                        )
                group by
                    1,2,3
                union all
                select
                    mobile,
                    '\$\$today' as dt,
                    case when 2 in (\$dim) and 0 not in (\$dim) then sellchannel
                    else -99 end as sellchannel,
                    sum(totalprice) totalprice,
                    count(distinct order_id) order_num
                from (
                    $sos
                        and (
                            performance_id in (\$send_performance_id) 
                            or -99 in (\$send_performance_id)
                            )
                        and sellchannel not in (9,10,11)
                        and \$isreal=1
                    ) sos
                group by
                    1,2,3
                ) spo
                left join (
                    $md
                    and key_name='sellchannel'
                    ) md
                on md.key=spo.sellchannel
            group by
                1,2,3
        ) so
        on so.mobile=sed.mobile
    group by
        1,2,3,4
    ) as a
where
    (0 not in (\$dim) and dt<>'all'
    and pt<>'全部')
    or 0 in (\$dim)
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi
