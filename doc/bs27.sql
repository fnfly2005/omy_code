
select
    sendtag,
    batch_code,
    dt,
    pt,
    case when 0 not in ($dim) then 'all'
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
                sendtag in ('$sendtag') 
                and 1 in ($dit)
            union all
            select
                mobile,
                sendtag,
                batch_code
            from 
                upload_table.send_fn_user
            where
                sendtag in ('$sendtag') 
                and 1 in ($dit)
            union all
            select
                mobile,
                sendtag,
                batch_code
            from 
                upload_table.send_wdh_user
            where
                sendtag in ('$sendtag') 
                and 1 in ($dit)
            union all
            select
                cast(mobile as bigint) mobile,
                'all' sendtag,
                -99 batch_code
            from
                upload_table.fn_uploadmobile_data
            where
                2 in ($dit)
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
                3 in ($dit)
                and mobile is not null
                and regexp_like(mobile,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$')
            ) se1
            left join (
                select
                    mobile
                from
                    upload_table.black_list_fn
                where
                    $fit_flag=1
                union all
                select
                    mobile
                from
                    upload_table.wdh_upload
                where
                    $fit_flag=2
                ) as bl
            on bl.mobile=se1.mobile
        where
            $send_cat=1
            and bl.mobile is null
        union all
        select
            phonenumber as mobile,
            'all' sendtag,
            -99 batch_code
        from origindb.dp_myshow__s_messagepush where phonenumber is not null and CreateTime>'2018-03-01' and regexp_like(phonenumber,'^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$') and phonenumber not in (13800138000,13000000000)
            and $send_cat=2
            and performanceid in ($send_performance_id)
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
                    case when 1 in ($dim) and 0 not in ($dim) then substr(pay_time,1,10) 
                    else 'all' end as dt,
                    case when 2 in ($dim) and 0 not in ($dim) then sellchannel
                    else -99 end as sellchannel,
                    sum(totalprice) totalprice,
                    count(distinct order_id) order_num
                from mart_movie.detail_myshow_saleorder where pay_time is not null and pay_time>='$$begindate' and pay_time<'$$enddate'
                    and sellchannel not in (9,10,11)
                    and $isreal=0
                    and (
                        performance_id in ($send_performance_id) 
                        or -99 in ($send_performance_id)
                        )
                group by
                    1,2,3
                union all
                select
                    mobile,
                    '$$today' as dt,
                    case when 2 in ($dim) and 0 not in ($dim) then sellchannel
                    else -99 end as sellchannel,
                    sum(totalprice) totalprice,
                    count(distinct order_id) order_num
                from (
                    select order_id, performance_id, sellchannel, usermobileno as mobile, totalprice from upload_table.detail_myshow_salerealorder where pay_time is not null
                        and (
                            performance_id in ($send_performance_id) 
                            or -99 in ($send_performance_id)
                            )
                        and sellchannel not in (9,10,11)
                        and $isreal=1
                    ) sos
                group by
                    1,2,3
                ) spo
                left join (
                    select key_name, key, key1, key2, value1, value2, value3, value4 from upload_table.myshow_dictionary_s where key_name is not null
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
    (0 not in ($dim) and dt<>'all'
    and pt<>'全部')
    or 0 in ($dim)
;
