creator = 'fannian@maoyan.com'
'db': META['hmart_movie']
'format': 'city_id,city_name,province_id,province_name,area_1_level_id,area_1_level_name,area_2_level_id,area_2_level_name,mt_city_id,dp_flag,city_level,etl_time',
'db': META['mart_movie_mis'],
'table': 'dim_myshow_city',

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='猫眼演出城市维度表'
