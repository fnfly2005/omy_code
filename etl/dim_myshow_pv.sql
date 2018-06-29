creator='fannian@meituan.com'
'db': META['hmart_movie'],
'table': 'dim_myshow_pv'

'format': 'pv_id,page_identifier,page_name_my,cid_type,page_cat,biz_par,biz_bg,status,modify_date',

insert OVERWRITE TABLE `$target.table`
select
    pv_id,
    page_identifier,
    page_name_my,
    cid_type,
    page_cat,
    biz_par,
    biz_bg,
    status,
    modify_date
from 
    upload_table.my_pv_fn

#if $isRELOAD
drop table `$target.table`
#end if

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`pv_id` int COMMENT '配置ID',
`page_identifier` string COMMENT '标识',
`page_name_my` string COMMENT '名称',
`cid_type` string COMMENT '埋点类型',
`page_cat` int COMMENT '页面分类',
`biz_par` string COMMENT '业务参数',
`biz_bg` int COMMENT '业务归属',
`status` int COMMENT '是否最新',
`modify_date` string COMMENT '维护日期'
) COMMENT '演出页面埋点配置表'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
