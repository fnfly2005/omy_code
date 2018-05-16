creator='fannian@meituan.com'
'db': META['hmart_movie'],
'format': '',

drop table if EXISTS mart_movie_test.dim_wg_userlabel_temp1;
create table mart_movie_test.dim_wg_userlabel_temp1 as
select
    case when wso.user_id is null then wus.dt
    else wso.dt end as dt,
    case when wso.user_id is null then wus.user_id
    else wso.user_id end as user_id,
    case when wso.user_id is null then wus.mobile
    else wso.mobile end as mobile,
    item_id,
    case when wso.user_id is null then 1
    else action_flag as action_flag,
    order_id,
    order_src,
    total_money,
    row_number() over (partition by user_id order by dt desc) order_no
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
    ) wso
    full join (
        select
            dt,
            user_id,
            mobile
        from
            upload_table.dim_wg_users
        ) as wus
    on wso.user_id=wus.user_id
;
drop table if EXISTS mart_movie_test.dim_wg_userlabel_temp2;
create table mart_movie_test.dim_wg_userlabel_temp2 as
select
    dt,
    mobile,
	item_no,
    pay_flag,
    order_id,
    order_src,
    total_money,
    ci.city_id,
	ty.category_id,
    row_number() over (partition by mobile order by dt desc) order_no
from (
    select
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
            mart_movie_test.dim_wg_userlabel_temp1
        union all
        select
            ia.dt,
            lba.mobile,
            ia.item_id,
            2 as action_flag,
            NULL order_id,
            NULL order_src,
            NULL total_money,
            NULL order_no
        from (
            select
                dt,
                user_id,
                item_id
            from
                upload_table.dim_wg_iteminterests
            union all
            select
                dt,
                user_id,
                item_id
            from
                upload_table.dim_wg_itemattentions
            ) as ia
            join (
                select distinct
                    user_id,
                    mobile
                from 
                    mart_movie_test.dim_wg_userlabel_temp1
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
            NULL order_src,
            NULL total_money,
            NULL order_no
        from (
            select
                dt,
                mobile,
                item_id
            from
                upload_table.detail_wg_outstockrecords
            where
                mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            union all
            select
                dt,
                mobile,
                item_id
            from
                upload_table.detail_wg_salereminders
            where
                mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
            ) osr
        ) s2
    ) s3
    left join upload_table.dim_wg_item it
    on it.item_id=so.item_id
    left join upload_table.dim_wg_citymap ci
    on ci.city_name=it.city_name
    left join upload_table.dim_wg_type ty
    on ty.type_lv1_name=it.type_lv1_name
;
drop table if EXISTS mart_movie_test.dim_wg_userlabel_temp2;
create table mart_movie_test.dim_wg_userlabel_temp2 as
select
    case when l1.user_id is not null then l1.user_id
    else us.user_id end user_id,
    case when l1.user_id is not null then l1.mobile
    else us.mobile end mobile,
    city_id,
    order_src,
    case when l1.user_id is not null then active_date
    else us.dt end active_date,
    pay_num,
    pay_money,
    item_flag,
    category_flag
from (
    select
        user_id,
        case when order_no=1 then mobile end mobile,
        case when order_no=1 then dt end active_date,
        count(case when pay_flag=1 then 1 end) as pay_num,
        sum(case when pay_flag=1 then total_money end) as pay_money,
        collect_set(case when order_no<=7 then item_no end) item_flag,
        collect_set(category_id) category_flag
    from
        mart_movie_test.dim_wg_userlabel_temp1
    group by
        user_id,
        case when order_no=1 then mobile end,
        case when order_no=1 then dt end
    ) as l1
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
                mart_movie_test.dim_wg_userlabel_temp1
            group by
                user_id,
                city_id
             ) cn1
        ) as cn
        on cn.user_id=l1.user_id
        and cn.rank=1
    left join (
        select
            user_id,
            order_src,
            row_number() over (partition by user_id order by ov desc) as rank
        from (
            select
                user_id,
                order_src,
                count(1) ov
            from
                mart_movie_test.dim_wg_userlabel_temp1
            group by
                user_id,
                order_src
             ) sn1
        ) as sn
        on sn.user_id=l1.user_id
        and sn.rank=1
    full join upload_table.dim_wg_users us
        on us.user_id=l1.user_id
;
insert OVERWRITE TABLE `$target.table`
select
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select
        user_id,
        mobile,
        city_id,
        order_src,
        active_date,
        pay_num,
        pay_money,
        item_flag,
        category_flag
    from
        mart_movie_test.dim_wg_userlabel_temp2
    union all
    select
        user_id,
        mobile,
        -99 city_id,
        NULL order_src,
        dt active_date,
        NULL pay_num,
        NULL pay_money,
        NULL item_flag,
        NULL category_flag
    from
        upload_table.dim_wg_users

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mobile` bigint COMMENT '电话号码',
`city_id` bigint COMMENT '主要活跃城市',
`order_src` bigint COMMENT '主要活跃平台',
`active_date` string COMMENT '最近活跃日期',
`pay_num` bigint COMMENT '支付频次',
`pay_money` double COMMENT '支付金额',
`item_flag` array<bigint> COMMENT '项目标志(最近7个)',
`category_flag` array<int> COMMENT '类目标志',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色项目-智慧剧院人群标签'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
