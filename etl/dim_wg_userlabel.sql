creator='fannian@meituan.com'
'db': META['hmart_movie'],
'format': '',

drop table if EXISTS mart_movie_test.dim_wg_userlabel_tempa1;
create table mart_movie_test.dim_wg_userlabel_tempa1 as
select
    user_id,
    mobile,
    order_src,
    dt,
    action_flag,
    item_id,
    order_id,
    total_money,
    row_number() over (partition by user_id order by dt desc) order_no
from (
    select
        case when wso.user_id is null then wus.user_id
        else wso.user_id end as user_id,
        case when wso.user_id is null then wus.mobile
        else wso.mobile end as mobile,
        case when wso.user_id is null then 0
        else order_src end as order_src,
        case when wso.user_id is null then wus.dt
        else wso.dt end as dt,
        case when wso.user_id is null then 10
            when wgs.order_id is not null then 60
        else action_flag end as action_flag,
        item_id,
        wso.order_id,
        total_money
    from (
        select
            user_id,
            order_mobile as mobile,
            order_src,
            dt,
            case when length(pay_no)>5 then 50
            else 40 end as action_flag,
            item_id,
            order_id,
            sum(total_money) total_money
        from
            upload_table.detail_wg_saleorder
        where
            order_mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            and order_mobile not in (13800138000,13000000000)
            and order_id is not null
        group by
            user_id,
            order_mobile,
            order_src,
            dt,
            case when length(pay_no)>5 then 50
            else 40 end,
            item_id,
            order_id
        ) wso
        left join (
            select
                order_id,
                row_number() over (partition by user_id order by dt) order_no
            from (
                select distinct
                    user_id,
                    order_id,
                    dt
                from
                    upload_table.detail_wg_saleorder
                where
                    order_mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                    and length(pay_no)>5
                    and order_mobile not in (13800138000,13000000000)
                    and order_id is not null
                ) wgn   
            ) wgs
            on wgs.order_id=wso.order_id
            and wgs.order_no>1
        full join (
            select
                user_id,
                mobile,
                dt
            from
                upload_table.dim_wg_users
            where
                mobile not in (13800138000,13000000000)
            ) as wus
        on wso.user_id=wus.user_id
    ) as so
;
drop table if EXISTS mart_movie_test.dim_wg_userlabel_tempa2;
create table mart_movie_test.dim_wg_userlabel_tempa2 as
select
    mobile,
	city_id,
    order_src,
    dt,
    action_flag,
	item_nu,
	category_id,
    order_id,
    total_money,
    order_no,
    row_number() over (partition by mobile order by dt desc) act_no
from (
    select
        mobile,
        ii.city_id,
        order_src,
        dt,
        action_flag,
        ii.item_nu,
        ii.category_id,
        order_id,
        total_money,
        order_no
    from (
        select
            mobile,
            order_src,
            dt,
            action_flag,
            item_id,
            order_id,
            total_money,
            row_number() over (partition by mobile order by dt desc) order_no
        from (
            select
                tpa.mobile,
                order_src,
                dt,
                action_flag,
                item_id,
                order_id,
                total_money
            from
                mart_movie_test.dim_wg_userlabel_tempa1 tpa
                left join (
                    select
                        user_id,
                        mobile
                    from 
                        mart_movie_test.dim_wg_userlabel_tempa1
                    where 
                        order_no=1
                    ) lta
                on lta.user_id=tpa.user_id
            ) as lpa
        union all
        select
            lba.mobile,
            0 as order_src,
            ia.dt,
            20 as action_flag,
            ia.item_id,
            NULL order_id,
            NULL total_money,
            1 as order_no
        from (
            select
                user_id,
                dt,
                item_id
            from
                upload_table.detail_wg_iteminterests
            union all
            select
                user_id,
                dt,
                item_id
            from
                upload_table.detail_wg_itemattentions
            ) as ia
            join (
                select
                    user_id,
                    mobile
                from 
                    mart_movie_test.dim_wg_userlabel_tempa1
                where 
                    order_no=1
                ) lba
            on lba.user_id=ia.user_id
        union all
        select
            mobile,
            0 as order_src,
            dt,
            30 as action_flag,
            item_id,
            NULL order_id,
            NULL total_money,
            1 as order_no
        from
            upload_table.detail_wg_outstockrecords
        where
            mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            and mobile not in (13800138000,13000000000)
        union all
        select
            mobile,
            0 as order_src,
            dt,
            30 as action_flag,
            item_id,
            NULL order_id,
            NULL total_money,
            1 as order_no
        from
            upload_table.detail_wg_salereminders
        where
            mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            and mobile not in (13800138000,13000000000)
        ) so
        left join (
            select
                ci.city_id,
                it.item_id,
                it.item_nu,
                ty.category_id
            from
                upload_table.dim_wg_performance it
                left join upload_table.dim_wg_citymap ci
                on ci.city_name=it.city_name
                left join upload_table.dim_wg_type ty
                on ty.type_lv1_name=it.category_name
                ) ii
        on ii.item_id=so.item_id
        and so.action_flag<>10
    where
        so.action_flag=10
        or (ii.item_id is not null
        and so.action_flag<>10
            )
    ) as spo
;
insert OVERWRITE TABLE `$target.table`
select
    l1.mobile,
    city_id,
    order_src,
    active_date,
    action_flag,
    item_flag,
    category_flag,
    pay_num,
    pay_money,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select
        mobile,
        max(case when order_no=1 then order_src end) as order_src,
        max(dt) active_date,
        collect_set(action_flag) action_flag,
        collect_set(case when act_no<=7 then item_nu end) item_flag,
        collect_set(category_id) category_flag,
        count(distinct case when action_flag in (50,60) then order_id end) as pay_num,
        sum(case when action_flag in (50,60) then total_money end) as pay_money
    from
        mart_movie_test.dim_wg_userlabel_tempa2
    group by
        mobile
    ) as l1
    left join (
        select
            mobile,
            city_id,
            row_number() over (partition by mobile order by ov desc) as rank
        from (
            select
                cn1.mobile,
                case when cn1.city_id is null then mi.city_id
                else cn1.city_id end city_id,
                ov
            from (
                select
                    mobile,
                    city_id,
                    count(1) ov
                from
                    mart_movie_test.dim_wg_userlabel_tempa2
                group by
                    mobile,
                    city_id
                ) cn1
                left join upload_table.mobile_info mi
                on substr(cn1.mobile,1,7)=mi.mobile
            ) cn2
        ) as cn
        on cn.mobile=l1.mobile
        and cn.rank=1
where
    cn.city_id is not null

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mobile` bigint COMMENT '电话号码',
`city_id` bigint COMMENT '常用偏好城市',
`order_src` bigint COMMENT '最近下单平台',
`active_date` string COMMENT '最近活跃日期',
`action_flag` array<int> COMMENT '行为标签-意向强弱',
`item_flag` array<bigint> COMMENT '项目标签(最近7个)',
`category_flag` array<int> COMMENT '类目标签',
`pay_num` bigint COMMENT '支付频次',
`pay_money` double COMMENT '支付金额',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色-微格人群标签'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
