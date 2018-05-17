creator='fannian@meituan.com'
'db': META['hmart_movie'],
'format': '',

drop table if EXISTS tmp.dim_wg_userlabel_temp1;
create table tmp.dim_wg_userlabel_temp1 as
select
	dt,
	user_id,
	mobile,
    item_id,
	action_flag,
    order_id,
	order_src,
    total_money,
    row_number() over (partition by user_id order by dt desc) order_no
from (
    select
        case when wso.user_id is null then wus.dt
        else wso.dt end as dt,
        case when wso.user_id is null then wus.user_id
        else wso.user_id end as user_id,
        case when wso.user_id is null then wus.mobile
        else wso.mobile end as mobile,
        item_id,
        case when wso.user_id is null then 1
            when wgs.order_id is not null then 6
        else action_flag end as action_flag,
        wso.order_id,
        case when wso.user_id is null then 0
        else order_src end as order_src,
        total_money
    from (
        select
            dt,
            user_id,
            order_mobile as mobile,
            item_id,
            case when length(pay_no)>5 then 5
            else 4 end as action_flag,
            order_id,
            order_src,
            total_money
        from
            upload_table.detail_wg_saleorder
        where
            order_mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            and order_mobile<>13800138000
        ) wso
        left join (
            select
                order_id,
                row_number() over (partition by user_id order by dt) order_no
            from
                upload_table.detail_wg_saleorder
            where
                order_mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                and length(pay_no)>5
                and order_mobile<>13800138000
            ) wgs
            on wgs.order_id=wso.order_id
            and wgs.order_no>1
        full join (
            select
                dt,
                user_id,
                mobile
            from
                upload_table.dim_wg_users
            where
                 mobile<>13800138000
            ) as wus
        on wso.user_id=wus.user_id
    ) as so
;
drop table if EXISTS tmp.dim_wg_userlabel_temp2;
create table tmp.dim_wg_userlabel_temp2 as
select
    dt,
    mobile,
    ii.item_nu,
    action_flag,
    order_id,
    order_src,
    total_money,
    ii.city_id,
    ii.category_id,
    order_no,
    row_number() over (partition by mobile order by dt desc) act_no
from (
    select
        dt,
        mobile,
        item_id,
        action_flag,
        order_id,
        order_src,
        total_money,
        order_no
    from
        tmp.dim_wg_userlabel_temp1
    union all
    select
        ia.dt,
        lba.mobile,
        ia.item_id,
        2 as action_flag,
        NULL order_id,
        0 as order_src,
        NULL total_money,
        1 as order_no
    from (
        select
            dt,
            user_id,
            item_id
        from
            upload_table.detail_wg_iteminterests
        union all
        select
            dt,
            user_id,
            item_id
        from
            upload_table.detail_wg_itemattentions
        ) as ia
        join (
            select distinct
                user_id,
                mobile
            from 
                tmp.dim_wg_userlabel_temp1
            where 
                order_no=1
            ) lba
        on lba.user_id=ia.user_id
    union all
    select
        dt,
        mobile,
        item_id,
        3 as action_flag,
        NULL order_id,
        0 as order_src,
        NULL total_money,
        1 as order_no
    from
        upload_table.detail_wg_outstockrecords
    where
        mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
        and mobile<>13800138000
    union all
    select
        dt,
        mobile,
        item_id,
        3 as action_flag,
        NULL order_id,
        0 as order_src,
        NULL total_money,
        1 as order_no
    from
        upload_table.detail_wg_salereminders
    where
        mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
        and mobile<>13800138000
    ) so
    left join (
        select
            it.item_id,
            it.item_nu,
            ci.city_id,
            ty.category_id
        from
            upload_table.dim_wg_performance it
            left join upload_table.dim_wg_citymap ci
            on ci.city_name=it.city_name
            left join upload_table.dim_wg_type ty
            on ty.type_lv1_name=it.category_name
            ) ii
    on ii.item_id=so.item_id
    and so.action_flag<>1
;
insert OVERWRITE TABLE `$target.table`
select
    l1.mobile,
    city_id,
    order_src,
    active_date,
    pay_num,
    pay_money,
    action_flag,
    item_flag,
    category_flag,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select
        mobile,
        case when act_no=1 then dt end as active_date,
        case when order_no=1 then order_src end as order_src,
        count(distinct case when action_flag=5 then order_id end) as pay_num,
        sum(case when action_flag=5 then total_money end) as pay_money,
        collect_set(action_flag) action_flag,
        collect_set(case when act_no<=7 then item_nu end) item_flag,
        collect_set(category_id) category_flag
    from
        tmp.dim_wg_userlabel_temp2
    group by
        mobile,
        case when act_no=1 then dt end,
        case when order_no=1 then order_src end
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
                    tmp.dim_wg_userlabel_temp2
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
`pay_num` bigint COMMENT '支付频次',
`pay_money` double COMMENT '支付金额',
`action_flag` array<int> COMMENT '行为标签-意向强弱',
`item_flag` array<bigint> COMMENT '项目标签(最近7个)',
`category_flag` array<int> COMMENT '类目标签',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色项目-微格用户人群标签表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
