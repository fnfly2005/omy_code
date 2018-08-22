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
    'table': 'dim_myshow_shop', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)

##Load##
##-- Load节点, (可以留空)
drop table if EXISTS mart_movie_test.dim_myshow_shop_tempa1;
create table mart_movie_test.dim_myshow_shop_tempa1 as
select
    venueid as venue_id,
    dpshopid as shop_id,
    name as shop_name,
    address as shop_address,
    cityid as city_id,
    cityname as city_name,
    status as shop_status,
    createtime as create_time,
    updatetime as update_time,
    protectstatus as protect_status,
    topstatus as top_status,
    audittime as audit_time,
    applytime as apply_time,
    bduserid as bduser_id,
    audituserid as audituser_id,
    bdusername as bduser_time,
    auditusername as audituser_time,
    branchname as branch_name,
    mtshopid as mtshop_id
from
    origindb.dp_myshow__t_venue --基础场馆表
;
insert OVERWRITE TABLE `$target.table`
select
    ShopID as shop_id,
    TPVenueName as shop_name,
    city_id,
    city_name,
    longitude,
    latitude,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
union all
select
from (
    select
        poi.shop_id as venue_id,
        poi.shop_id,
		null as shop_name,
		null as shop_address,
		null as city_id,
		null as city_name,
		null as shop_status,
		null as create_time,
		null as update_time,
		null as protect_status,
		null as top_status,
		null as audit_time,
		null as apply_time,
		null as bduser_id,
		null as audituser_id,
		null as bduser_time,
		null as audituser_time,
		null as branch_name,
		null as mtshop_id
    from (
        select distinct
            shopid as shop_id
        from 
            origindb.dp_myshow__s_poishopmap --第三方场馆表
        ) as poi
        left join mart_movie_test.dim_myshow_shop_tempa1 ven
            on ven.shop_id=poi.shop_id
    where
        ven.shop_id is null
    union all
    select
		venue_id,
		shop_id,
		shop_name,
		shop_address,
		city_id,
		city_name,
		shop_status,
		create_time,
		update_time,
		protect_status,
		top_status,
		audit_time,
		apply_time,
		bduser_id,
		audituser_id,
		bduser_time,
		audituser_time,
		branch_name,
		mtshop_id
    from
        mart_movie_test.dim_myshow_shop_tempa1
    ) as pov
    left join dw.dim_dp_shop dds
        on dds.dp_shop_id=pov.shop_id

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`shop_id` bigint COMMENT '演出场馆ID',
`shop_name` string COMMENT '演出场馆名称',
`city_id` bigint COMMENT '城市ID',
`city_name` string COMMENT '城市名称',
`province_id` int COMMENT '省份ID',
`province_name` string COMMENT '省份名称',
`longitude` double COMMENT '经度',
`latitude` double COMMENT '纬度',
`etl_time` string COMMENT '更新时间'
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
