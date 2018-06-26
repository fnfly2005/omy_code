creator='fannian@meituan.com'
'db': META['hmart_movie'],
'format': '',

drop table if EXISTS mart_movie_test.dim_myshow_userlabel_tempa0;
create table mart_movie_test.dim_myshow_userlabel_tempa0 as
select
    mt_user_id as user_id,
    phonenumber as mobile,
    sellchannel,
    substr(createtime,1,10) as dt,
    30 as action_flag,
    performanceid as performance_id,
    NULL as order_id,
    NULL as totalprice
from (
    select
        userid,
        phonenumber,
        sellchannel,
        createtime,
        performanceid
    from
        origindb.dp_myshow__s_messagepush
    where
        phonenumber rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
        and phonenumber not in (13800138000,13000000000)
        and phonenumber is not null
        and usertype=1
        and userid<>0
    ) as mp
    left join dw.dim_mt_user mu
    on mu.recom_dp_user_id=mp.userid
where
    mt_user_id is not null
;
drop table if EXISTS mart_movie_test.dim_myshow_userlabel_tempa1;
create table mart_movie_test.dim_myshow_userlabel_tempa1 as
select
    user_id,
    mobile,
    city_id,
    sellchannel,
    dt,
    action_flag,
    so.performance_id,
    category_id,
    order_id,
    totalprice,
    row_number() over (partition by user_id order by dt desc) act_no
from (
    select
        wso.user_id,
        wso.mobile,
        sellchannel,
        dt,
        case when wgs.user_id is not null then 60
        else action_flag end as action_flag,
        performance_id,
        wso.order_id,
        totalprice
    from (
        select
            meituan_userid as user_id,
            usermobileno as mobile,
            sellchannel,
            substr(order_create_time,1,10) as dt,
            case when pay_time is not null then 50
            else 40 end as action_flag,
            performance_id,
            order_id,
            totalprice
        from
            mart_movie.detail_myshow_saleorder
        where
            usermobileno rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            and usermobileno not in (13800138000,13000000000)
            and order_id is not null
            and sellchannel not in (9,10,11)
        ) wso
        left join (
            select
                meituan_userid as user_id
            from
                mart_movie.detail_myshow_salefirstorder
            where
                category_id=-99
                and pay_dt_num>1
            ) wgs
            on wgs.user_id=wso.user_id
    union all
    select
        mtuserid as user_id,
        usermobileno as mobile,
        sellchannel,
        substr(rr.createtime,1,10) as dt,
        30 as action_flag,
        performanceid as performance_id,
        NULL as order_id,
        NULL as totalprice
    from
        origindb.dp_myshow__s_stockoutregisterrecord rr
        left join origindb.dp_myshow__s_stockoutregisterstatistic rs
        on rr.stockoutregisterstatisticid=rs.stockoutregisterstatisticid
    where
        usermobileno rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
        and usermobileno not in (13800138000,13000000000)
        and usermobileno is not null
        and mtuserid<>0
    union all
    select
        userid as user_id,
        phonenumber as mobile,
        sellchannel,
        substr(createtime,1,10) as dt,
        30 as action_flag,
        performanceid as performance_id,
        NULL as order_id,
        NULL as totalprice
    from
        origindb.dp_myshow__s_messagepush
    where
        phonenumber rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
        and phonenumber not in (13800138000,13000000000)
        and phonenumber is not null
        and usertype=2
        and userid<>0
    union all
    select
		user_id,
		mobile,
        sellchannel,
		dt,
		action_flag,
		performance_id,
		order_id,
		totalprice
    from
        mart_movie_test.dim_myshow_userlabel_tempa0
    union all
    select
        userid as user_id,
        NULL as mobile,
        1 as sellchannel,
        substr(createtime,1,10) as dt,
        20 as action_flag,
        maoyanid as performance_id,
        NULL as order_id,
        NULL as totalprice
    from
        origindb.dp_myshow__s_favormap
    where
        biztype=24
    ) so
    left join mart_movie.dim_myshow_performance per
    on per.performance_id=so.performance_id
where
    user_id<>0
;
    
insert OVERWRITE TABLE `$target.table`
select
    l1.user_id,
    mobile,
    city_id,
    sellchannel,
    active_date,
    action_flag,
    performance_flag,
    category_flag,
    cel.celebrity_flag,
    pay_num,
    pay_money,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select
        user_id,
        max(dt) active_date,
        collect_set(action_flag) action_flag,
        collect_set(case when act_no<=7 then performance_id end) performance_flag,
        collect_set(category_id) category_flag,
        count(distinct case when action_flag in (50,60) then order_id end) as pay_num,
        sum(case when action_flag in (50,60) then totalprice end) as pay_money
    from
        mart_movie_test.dim_myshow_userlabel_tempa1
    group by
        user_id
    ) as l1
    join (
        select
            user_id,
            mobile,
            row_number() over (partition by user_id order by ov desc) as rank
        from (
            select
                user_id,
                mobile,
                count(1) ov
            from
                mart_movie_test.dim_myshow_userlabel_tempa1
            where
                mobile is not null
            group by
                user_id,
                mobile
            ) cn1
        ) mn
        on mn.user_id=l1.user_id
        and mn.rank=1
    left join (
        select
            user_id,
            collect_set(celebrityid) as celebrity_flag
        from
            mart_movie_test.dim_myshow_userlabel_tempa1 t1
            left join origindb.dp_myshow__s_celebrityperformancerelation ce
            on t1.performance_id=ce.performanceid
        group by
            user_id
        ) cel
        on l1.user_id=cel.user_id
    left join (
        select
            user_id,
            city_id,
            row_number() over (partition by user_id order by ov desc) as rank
        from (
            select
                user_id,
                city_id,
                count(1) ov
            from
                mart_movie_test.dim_myshow_userlabel_tempa1
            group by
                user_id,
                city_id
            ) cn1
        ) cn
        on cn.user_id=l1.user_id
        and cn.rank=1
    left join (
        select
            user_id,
            sellchannel,
            row_number() over (partition by user_id order by ov desc) as rank
        from (
            select
                user_id,
                sellchannel,
                count(1) ov
            from
                mart_movie_test.dim_myshow_userlabel_tempa1
            group by
                user_id,
                sellchannel
            ) cn1
        ) sn
        on sn.user_id=l1.user_id
        and sn.rank=1

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`user_id` bigint COMMENT '美团用户ID',
`mobile` bigint COMMENT '常用电话号码',
`city_id` bigint COMMENT '常用偏好城市',
`sellchannel` bigint COMMENT '常用下单平台',
`active_date` string COMMENT '最近活跃日期',
`action_flag` array<int> COMMENT '行为标签-意向强弱',
`performance_flag` array<bigint> COMMENT '项目标签(最近7个)',
`category_flag` array<bigint> COMMENT '类目标签',
`celebrity_flag` array<bigint> COMMENT '艺人标签',
`pay_num` bigint COMMENT '支付频次',
`pay_money` double COMMENT '支付金额',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色-猫眼人群标签'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
