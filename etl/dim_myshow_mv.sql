creator='fannian@meituan.com'
'db': META['hmart_movie'],
'table': 'dim_myshow_mv'

'format': 'mv_id,event_id,event_name_lv1,event_name_lv2,page_identifier,user_int,biz_par,biz_typ,page_loc,status,modify_date',

insert OVERWRITE TABLE `$target.table`
select
    mv_id,
    event_id,
    event_name_lv1,
    event_name_lv2,
    page_identifier,
    user_int,
    biz_par,
    biz_typ,
    page_loc,
    status,
    modify_date
from 
    upload_table.my_mv_fn

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`mv_id` int COMMENT '配置ID',
`event_id` string COMMENT '标识',
`event_name_lv1` string COMMENT '一级模块名',
`event_name_lv2` string COMMENT '二级模块名',
`page_identifier` string COMMENT '所属页面',
`user_int` int COMMENT '用户意向',
`biz_par` string COMMENT '业务参数',
`biz_typ` string COMMENT '逻辑字段',
`page_loc` int COMMENT '页面位置',
`status` int COMMENT '是否最新',
`modify_date` string COMMENT '维护日期'
) COMMENT '演出模块埋点配置表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
