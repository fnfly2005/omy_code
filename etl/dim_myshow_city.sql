creator = 'fannian@maoyan.com'
'db': META['horigindb']
'table': 'dim_myshow_city'
insert OVERWRITE TABLE `$target.table`
select
    city_id,
    city_name,
    province_id,
    province_name,
    area_1_level_id,
    area_1_level_name,
    area_2_level_id,
    area_2_level_name,
    dpct.mt_city_id,
    dp_flag,
    case when cl.mt_city_id is null then 4
    else city_level end city_level,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
    select 
        sd.cityid as city_id,
        sd.cityname as city_name,
        dp.province_id,
        dp.province_name,
        dp.area_1_level_id,
        dp.area_1_level_name,
        dp.area_2_level_id,
        dp.area_2_level_name,
        sd.mt_city_id,
        dp_flag
    from (
        select distinct
            dc.cityid,
            dc.cityname,
            dc.provinceid,
            mt_city_id,
            case when cms.mt_city_id is null then 1
                when cms.mt_city_id=0 then 1
            else 0 end as dp_flag
        from 
            origindb.dp_myshow__s_dpcitylist dc
            join dw.dim_dp_mt_city_mapping_scd cms
            on cast(dc.cityid as bigint)=cms.dp_city_id
            and cms.is_enabled=1
        where 
            dc.cityid<>7
        ) as sd
        left join upload_table.dim_myshow_province_s as dp
        on dp.province_id=sd.provinceid
    union all 
    select 
        sd.cityid as city_id,
        sd.cityname as city_name,
        sd.provinceid as province_id,
        '广东' as province_name,
        dp.area_1_level_id,
        dp.area_1_level_name,
        dp.area_2_level_id,
        dp.area_2_level_name,
        sd.mt_city_id,
        0 as dp_flag
    from (
        select
            1 as link,
            dc.cityid,
            dc.cityname,
            dc.provinceid,
            cms.mt_city_id
        from 
            origindb.dp_myshow__s_dpcitylist dc
            join dw.dim_dp_mt_city_mapping_scd cms
            on cast(dc.cityid as bigint)=cms.dp_city_id
            and cms.is_enabled=1
        where 
            dc.cityid=7
        ) as sd
        join (
            select distinct 
                1 as link,
                area_1_level_id,
                area_1_level_name,
                area_2_level_id,
                area_2_level_name
            from 
                upload_table.dim_myshow_province_s
            where 
                area_2_level_id=10
            ) as dp
        on sd.link=dp.link
    ) as dpct
    left join upload_table.dim_myshow_citylevel cl
    on cl.mt_city_id=dpct.mt_city_id

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`city_id` bigint COMMENT '城市ID',
`city_name` string COMMENT '城市名称',
`province_id` int COMMENT '省份ID',
`province_name` string COMMENT '省份名称',
`area_1_level_id` int COMMENT '战区ID',
`area_1_level_name` string COMMENT '战区名称',
`area_2_level_id` int COMMENT '分区ID',
`area_2_level_name` string COMMENT '分区名称',
`mt_city_id` bigint COMMENT '美团城市ID',
`dp_flag` int COMMENT '点评专属城市标志 0:美团点评共有 1:点评专属',
`city_level` int COMMENT '猫眼城市等级',
`etl_time` string COMMENT '更新时间'
) COMMENT '猫眼演出城市维度表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
