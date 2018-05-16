creator='fannian@meituan.com'
'db': META['hmart_movie'],
'format': '',

drop table if EXISTS mart_movie_test.dim_wp_userlabel_temp;
create table mart_movie_test.dim_wp_userlabel_temp as
select distinct
    dt,
    mobile,
    item_no,
    case when length(pay_no)>5 then 1
    else 0 end as pay_flag,
    order_id,
    order_src,
    total_money,
    ci.city_id,
    ty.category_id,
    row_number() over (partition by mobile order by dt desc) order_no
from 
    upload_table.detail_wp_saleorder so
    left join upload_table.dim_wp_items it
    on it.item_id=so.item_id
    left join upload_table.dim_wg_citymap ci
    on ci.city_name=it.city_name
    left join upload_table.dim_wg_type ty
    on ty.type_lv1_name=it.type_lv1_name
where
    mobile rlike '^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$'
;
insert OVERWRITE TABLE `$target.table`
select
    l1.mobile,
    city_id,
    order_src,
    active_date,
    pay_num,
    pay_money,
    item_flag,
    category_flag,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select
        mobile,
        case when order_no=1 then dt end as active_date,
        case when order_no=1 then order_src end as order_src,
        count(case when pay_flag=1 then 1 end) as pay_num,
        sum(case when pay_flag=1 then total_money end) as pay_money,
        collect_set(case when order_no<=7 then item_no end) item_flag,
        collect_set(category_id) category_flag
    from
        mart_movie_test.dim_wp_userlabel_temp
    group by
        mobile,
        case when order_no=1 then dt end,
        case when order_no=1 then order_src end
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
`pay_num` bigint COMMENT '支付频次',
`pay_money` double COMMENT '支付金额',
`item_flag` array<bigint> COMMENT '项目标签(最近7个)',
`category_flag` array<int> COMMENT '类目标签',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色项目-智慧剧院人群标签'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
