creator='fannian@meituan.com'
'db': META['hmart_movie'],
'format': '',

drop table if EXISTS mart_movie_test.dim_wp_userlabel_temp;
create table mart_movie_test.dim_wp_userlabel_temp as
select
    mobile,
    ci.city_id,
    case when order_src is null then 0
    else order_src end order_src,
    dt,
    case when wgs.order_id is not null then 60
    else action_flag end as action_flag,
    item_no,
    ty.category_id,
    so.order_id,
    total_money,
    row_number() over (partition by mobile order by dt desc) order_no
from (
    select
        mobile,
        order_src,
        dt,
        case when length(pay_no)>5 then 50
        else 40 end as action_flag,
        item_id,
        order_id,
        sum(total_money) total_money
    from
        upload_table.detail_wp_saleorder
    where
        mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
        and mobile is not null
        and mobile not in (13800138000,13000000000)
    group by
        mobile,
        order_src,
        dt,
        case when length(pay_no)>5 then 50
        else 40 end,
        item_id,
        order_id
    ) so
    left join (
        select
            order_id,
            row_number() over (partition by mobile order by dt) order_no
        from (
            select distinct
                dt,
                mobile,
                order_id
            from
                upload_table.detail_wp_saleorder
            where
                mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
                and mobile is not null
                and mobile not in (13800138000,13000000000)
                and length(pay_no)>5
                and order_id is not null
            ) wgn   
        ) wgs
        on wgs.order_id=so.order_id
        and wgs.order_no>1
    left join upload_table.dim_wp_items it
    on it.item_id=so.item_id
    left join upload_table.dim_wg_citymap ci
    on ci.city_name=it.city_name
    left join upload_table.dim_wg_type ty
    on ty.type_lv1_name=it.type_lv1_name
where
    ci.city_id is not null
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
        max(dt) active_date,
        collect_set(action_flag) action_flag,
        collect_set(case when order_no<=7 then item_no end) item_flag,
        collect_set(category_id) category_flag,
        count(distinct case when action_flag in (50,60) then order_id end) as pay_num,
        sum(case when action_flag in (50,60) then total_money end) as pay_money
    from
        mart_movie_test.dim_wp_userlabel_temp
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
                mobile,
                city_id,
                count(1) ov
            from
                mart_movie_test.dim_wp_userlabel_temp
            group by
                mobile,
                city_id
             ) cn1
        ) as cn
        on cn.mobile=l1.mobile
        and cn.rank=1
    left join (
        select
            mobile,
            max(order_src) order_src
        from (
            select
                mobile,
                order_src
            from
                mart_movie_test.dim_wp_userlabel_temp
            where
                order_no=1
            ) as utp
        group by
            mobile
            ) lab
        on lab.mobile=l1.mobile

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mobile` bigint COMMENT '电话号码',
`city_id` bigint COMMENT '常用偏好城市',
`order_src` bigint COMMENT '最近活跃平台',
`active_date` string COMMENT '最近活跃日期',
`action_flag` array<int> COMMENT '行为标签-意向强弱',
`item_flag` array<bigint> COMMENT '项目标签(最近7个)',
`category_flag` array<int> COMMENT '类目标签',
`pay_num` bigint COMMENT '支付频次',
`pay_money` double COMMENT '支付金额',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色-智慧剧院人群标签'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
