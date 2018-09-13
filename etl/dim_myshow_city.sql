##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标表meta名(库名).表名

##Description##
##-- 这个节点填写本ETL的描述信息, 包括目标表定义, 建立时的需求jira编号等

##TaskInfo##
creator = 'fannian@maoyan.com'

source = {
    'db': META['horigindb'], ##-- 这里的单引号内填写在哪个数据库链接执行 Extract阶段, 具体有哪些链接请点击"查看META"按钮查看
}

stream = {
    'format': '', ##-- 这里的单引号中填写目标表的列名, 以逗号分割, 按照Extract节点的结果顺序做对应, 特殊情况Extract的列数可以小于目标表列数
}

target = {
    'db': META['hmart_movie'], ##-- 单引号中填写目标表所在库
    'table': 'dim_myshow_city', ##-- 单引号中填写目标表名
}


##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)
#if $isRELOAD
drop table `$target.table`
#end if

##Load##
##-- Load节点, (可以留空)
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
    mcm.parentdpcity_id,
    mcm.parentdpcity_name,
    dpct.mt_city_id,
    dp_flag,
    case when cl.mt_city_id is null then 4
    else city_level end city_level,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time,
    region_code,
    citykey
from (
    select distinct
        dc.cityid as city_id,
        dc.cityname as city_name,
        dp.province_id,
        dp.province_name,
        case when dc.cityid<>7 then dp.area_1_level_id
        else 4 end as area_1_level_id,
        case when dc.cityid<>7 then dp.area_1_level_name
        else '南部' end as area_1_level_name,
        case when dc.cityid<>7 then dp.area_2_level_id
        else 10 end as area_2_level_id,
        case when dc.cityid<>7 then dp.area_2_level_name
        else '华南' end as area_2_level_name,
        mt_city_id,
        case when cms.mt_city_id is null then 1
            when cms.mt_city_id=0 then 1
        else 0 end as dp_flag,
        ad_code as region_code
    from 
        origindb.dp_myshow__s_dpcitylist dc
        join dw.dim_dp_mt_city_mapping_scd cms
        on cast(dc.cityid as bigint)=cms.dp_city_id
        and cms.is_enabled=1
        left join upload_table.dim_myshow_province_s as dp
        on dp.province_id=dc.provinceid
    ) as dpct
    left join upload_table.dim_myshow_citylevel cl
    on cl.mt_city_id=dpct.mt_city_id
    and dp_flag=0
    left join upload_table.dim_myshow_dxcitymap mcm
    on mcm.mtcity_id=dpct.mt_city_id
    and dp_flag=0
    left join upload_table.dim_myshow_dpcitykey ke
    on ke.dpcityid=dpct.city_id

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`city_id` bigint COMMENT '点评城市ID',
`city_name` string COMMENT '点评城市名称',
`province_id` int COMMENT '点评省份ID',
`province_name` string COMMENT '省份名称',
`area_1_level_id` int COMMENT '战区ID',
`area_1_level_name` string COMMENT '战区名称',
`area_2_level_id` int COMMENT '分区ID',
`area_2_level_name` string COMMENT '分区名称',
`parentdpcity_id` bigint COMMENT '点评父级城市ID,若无父级城市则为空',
`parentdpcity_name` string COMMENT '点评父级城市名称',
`mt_city_id` bigint COMMENT '美团城市ID',
`dp_flag` int COMMENT '点评专属城市标志 0:美团点评共有 1:点评专属',
`city_level` int COMMENT '猫眼城市等级',
`etl_time` string COMMENT '更新时间',
`region_code` bigint COMMENT '行政区编码',
`citykey` string COMMENT '城市关键词'
) COMMENT '猫眼演出城市维度表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
