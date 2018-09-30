##Description##
##TaskInfo##
creator = 'fannian@maoyan.com'
source = {
    'db': META['hdw'], 
}

stream = {
    'format': '',
}

target = {
    'db': META['hmart_movie'],
    'table': 'detail_myshow_mv_wide_report', 
}

##Load##
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.parallel=true;
set hive.exec.reducers.max =1000;
set mapreduce.reduce.memory.mb=4096;
set mapreduce.map.memory.mb=4096;
set mapred.child.java.opts=-Xmx3072m;
set hive.auto.convert.join=true;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=256000000;
set mapred.min.split.size.per.rack=256000000;
set hive.merge.size.per.task=256000000;
set hive.merge.smallfiles.avgsize=256000000;
set hive.merge.mapfiles=true;
set hive.merge.mapredfiles=true;
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
INSERT OVERWRITE TABLE `$target.table` PARTITION (partition_date = '$now.date')
select
    app_name,
    custom,
    event_attribute,
    event_category,
    event_id,
    event_identifier,
    event_timestamp,
    event_type,
    extension,
    geo_city_id,
    idfa,
    imei,
    ip_location_city_id,
    is_native,
    os,
    page_city_id,
    page_identifier,
    cast(fp1.performance_id as bigint) as performance_id,
    refer_page_identifier,
    sequence,
    session_id,
    stat_time,
    union_id,
    user_id,
    uv_src,
    order_id,
    item_index,
    coalesce(cit.city_id,ity.city_id,fp1.geodpcity_id) as pagedpcity_id,
    coalesce(ity.city_id,fp1.geodpcity_id) geodpcity_id,
    event_name_lv1,
    event_name_lv2,
    page_name_my,
    coalesce(per.category_id,fp1.category_id) as category_id,
    per.city_id,
    per.province_id,
    per.shop_id
from (
    select
        mv.app_name,
        mv.custom,
        mv.event_attribute,
        mv.event_category,
        mv.event_id,
        mv.event_identifier,
        mv.event_timestamp,
        mv.event_type,
        mv.extension,
        coalesce(mv.geo_city_id,mv.ip_location_city_id) geo_city_id,
        mv.idfa,
        mv.imei,
        mv.ip_location_city_id,
        mv.is_native,
        mv.os,
        coalesce(mv.page_city_id,(
            case when cast(biz_tag%10 as int)=1 then
                (case cid_type
                    when 'h5' then mv.event_attribute['city_id']
                    when 'mini_programs' then coalesce(mv.event_attribute['cityId'],mv.custom['cityId'])
                    when 'native' then coalesce(mv.custom['city_id'],mv.event_attribute['city_id'])
                end)
            end)
            ) as page_city_id,
        mv.page_identifier,
        (case when page_cat<4 and cast(biz_tag%100/10 as int)=1 then
            case cid_type
                when 'h5' then custom['performance_id']
                when 'mini_programs' 
                    then coalesce(custom['id'],custom['pId'],event_attribute['id'])
                when 'native' then custom['drama_id']
            end
        end) as performance_id,
        mv.refer_page_identifier,
        mv.sequence,
        mv.session_id,
        mv.stat_time,
        mv.union_id,
        mv.user_id,
        (case when cid_type='h5' then custom['fromTag']
             when cid_type in ('mini_programs','pc') then utm_source
        end) as uv_src,
        case when page_cat=3 then coalesce(mv.order_id,(
            case when cast(biz_tag%100000/10000 as int)=1 and cid_type='mini_programs'
                then coalesce(mv.custom['id'],mv.event_attribute['orderId']) 
            end)) 
        end as order_id,
        case when page_cat=1 then coalesce(mv.item_index,(
            case when cast(biz_tag%10000/1000 as int)=1 
                then coalesce(mv.event_attribute['index'],mv.custom['index']) 
            end))
        end as item_index,
        case when cid_type='mini_programs' 
            then custom['gcityId'] 
        end as geomtcity_id,
        cit.city_id as geodpcity_id,
        dmm.event_name_lv1,
        dmm.event_name_lv2,
        dmm.page_name_my,
        dmm.cid_type,
        (case when page_cat=1 and cast(biz_tag%1000/100 as int)=1 then 
            case cid_type 
                when 'mini_programs' then custom['categoryId'] 
                when 'pc' then custom['cat_id'] 
            end
        end) as category_id
    from (
        select 
            event_id,
            event_name_lv1,
            event_name_lv2,
            page_identifier,
            page_name_my,
            cid_type,
            biz_tag,
            page_cat
        from 
            mart_movie.dim_myshow_mv
        where 
            status=1
         ) dmm    
        join (
            select 
                *
            from 
                mart_flow.detail_flow_mv_wide_report
            where
                partition_date='$now.date'
                and partition_log_channel='movie'
                and partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
            ) mv
        on dmm.page_identifier=mv.page_identifier
        and dmm.event_id=mv.event_id
        left join (
            select
                city_id,
                city_name,
                region_code
            from
                mart_movie.dim_myshow_city
                ) cit
            on cit.region_code=coalesce(mv.geo_city_id,mv.ip_location_city_id)
            and coalesce(mv.geo_city_id,mv.ip_location_city_id) is not null
    ) fp1 
    left join (
        select 
            performance_id, 
            category_id, 
            province_id, 
            city_id, 
            shop_id
        from mart_movie.dim_myshow_performance
        ) per
    on fp1.performance_id=per.performance_id
    left join (
        select
            city_id,
            mt_city_id,
            city_name
        from
            mart_movie.dim_myshow_city
        where
            dp_flag=0
            ) cit
        on (case when fp1.app_name='dianping_nova' then cit.city_id
            else cit.mt_city_id end)=fp1.page_city_id
            and fp1.page_city_id is not null
    left join (
        select
            city_id,
            mt_city_id
        from
            mart_movie.dim_myshow_city
        where
            dp_flag=0
            ) ity
        on fp1.geomtcity_id=ity.mt_city_id
        and fp1.geomtcity_id is not null
        and fp1.cid_type='mini_programs'
;
##TargetDDL##
CREATE TABLE IF NOT EXISTS `$target.table`
(
`app_name` string COMMENT 'APP中文描述',
`custom` map<string,string> COMMENT 'custom',
`event_attribute` map<string,string> COMMENT '事件属性描述',
`event_category` string COMMENT '事件类别(取值包括mpt,mge,order,pay,launch的大类别)',
`event_id` string COMMENT '事件标识ID,bid',
`event_identifier` string COMMENT '点评数据唯一ID，去重使用',
`event_timestamp` bigint COMMENT '事件发生时间戳',
`event_type` string COMMENT '操作类型view(展现),tap(点击)',
`extension` map<string,string> COMMENT 'extension',
`geo_city_id` bigint COMMENT 'geohash城市ID',
`idfa` string COMMENT 'idfa',
`imei` string COMMENT 'imei',
`ip_location_city_id` bigint COMMENT 'ip城市ID',
`is_native` int COMMENT 'is_nativesdk上报类型',
`os` string COMMENT 'os',
`page_city_id` bigint COMMENT '页面城市id',
`page_identifier` string COMMENT '页面cid',
`performance_id` bigint COMMENT '演出ID-项目ID',
`refer_page_identifier` string COMMENT 'refer_page_identifier',
`sequence` bigint COMMENT 'session内的事件序号(同一union_id，session内唯一)',
`session_id` string COMMENT 'session_id',
`stat_time` string COMMENT 'stat_time',
`union_id` string COMMENT '设备ID',
`user_id` bigint COMMENT '用户id',
`uv_src` string COMMENT '页面来源',
`order_id` string COMMENT 'order_id',
`item_index` bigint COMMENT '控件内的位置',
`geodpcity_id` bigint COMMENT '定位城市id-点评',
`pagedpcity_id` bigint COMMENT '页面城市id-点评',
`event_name_lv1` string COMMENT '一级模块名',
`event_name_lv2` string COMMENT '二级模块名',
`page_name_my` string COMMENT '页面名称',
`category_id` bigint COMMENT '类别ID',
`city_id` bigint COMMENT '项目城市ID',
`province_id` bigint COMMENT '项目省份ID',
`shop_id` bigint COMMENT '点评场馆ID'
) COMMENT '演出页面流量宽表'
PARTITIONED BY (
    partition_date    string  COMMENT '日志生成日期'
) STORED AS ORC;
