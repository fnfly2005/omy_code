/*'unique_keys': 'mobile,sendtag',*/
/*'format': 'mobile,send_date,batch_code,sendtag,etl_time',*/
insert OVERWRITE TABLE $delta.table
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
select
    mobile,

from (
    select distinct
        dt,
        mobile,
        item_no,
        order_id,
        order_src,
        case when length(pay_no)>5 then 1
        else 0 end as pay_flag,
        total_money,
        ci.city_id,
        ty.category_id
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
    ) sic

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mobile` bigint COMMENT '电话号码',
`etl_time` string COMMENT '更新时间'
) COMMENT '用户染色项目-智慧剧院人群标签'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
