creator = 'fannian@maoyan.com'
'db': META['hmart_movie']
'format': 'id,performance_id,activity_id,performance_name,performance_shortname,category_id,category_name,city_id,city_name,province_id,province_name,area_1_level_id,area_1_level_name,area_2_level_id,area_2_level_name,shop_id,shop_name,performance_ticketstatus,performance_editstatus,performance_online_flag,performance_createtime,firstshowtime,lastshowtime,minprice,maxprice,premiumstatus,performance_seattype,iscomplete,etl_time',
'db': META['mart_movie_mis'],
'table': 'dim_myshow_performance',

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql
select
    0 as id,
    performance_id,
    activity_id,
    performance_name,
    performance_shortname,
    category_id,
    category_name,
    city_id,
    city_name,
    province_id,
    province_name,
    area_1_level_id,
    area_1_level_name,
    area_2_level_id,
    area_2_level_name,
    shop_id,
    shop_name,
    performance_ticketstatus,
    performance_editstatus,
    performance_online_flag,
    performance_createtime,
    firstshowtime,
    lastshowtime,
    minprice,
    maxprice,
    premiumstatus,
    performance_seattype,
    iscomplete,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from
    mart_movie.dim_myshow_performance

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)
#if $isRELOAD
drop table `$target.table`
#else
delete from `$target.table`
#end if

##TargetDD
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
id bigint not null primary key auto_increment comment 'primary key',
performance_id bigint COMMENT '演出ID-项目ID',
activity_id bigint COMMENT '后台演出ID',
performance_name varchar(80) COMMENT '演出名称',
performance_shortname varchar(80) COMMENT '演出短标题',
category_id bigint COMMENT '类别ID',
category_name varchar(80) COMMENT '类别名称',
city_id bigint COMMENT '城市ID',
city_name varchar(80) COMMENT '城市名称',
province_id int COMMENT '省份ID',
province_name varchar(80) COMMENT '省份名称',
area_1_level_id int COMMENT '战区ID',
area_1_level_name varchar(80) COMMENT '战区名称',
area_2_level_id int COMMENT '分区ID',
area_2_level_name varchar(80) COMMENT '分区名称',
shop_id bigint COMMENT '场馆ID',
shop_name varchar(80) COMMENT '场馆名称',
performance_ticketstatus int COMMENT '售票状态 1:未上线 2:预售 3:在售中 4:已售罄 5:已结束',
performance_editstatus int COMMENT '编辑状态 0:下架,1:上架',
performance_online_flag int COMMENT '在线标志 0:停售 1:在线 2:售罄',
performance_createtime varchar(80) COMMENT '创建时间',
firstshowtime varchar(80) COMMENT '首场时间',
lastshowtime varchar(80) COMMENT '末场时间',
minprice double COMMENT '最低票价',
maxprice double COMMENT '最高票价',
premiumstatus int COMMENT '溢价状态 1:未知 2:溢价 3:没有溢价',
performance_seattype int COMMENT '场次座位类型 0:非选座 1:选座 2:既有选座也有非选座',
iscomplete int COMMENT '用于校验完整性 0:不完整 1:完整',
etl_time varchar(80) COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='猫眼演出项目维度表'
