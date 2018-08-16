##Description##
-- 因为从pv宽表中计算dau/mau等指标数据，数据量大，需要抽取出演出业务的流量宽表数据
##TaskInfo##
creator = 'chenlong23@maoyan.com'
source = {
    'db': META['hdw'], 
}

stream = {
    'format': '',
}

target = {
    'db': META['hmart_movie'],
    'table': 'detail_myshow_pv_wide_report', 
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
INSERT OVERWRITE TABLE `$target.table` PARTITION (partition_date = '$now.date',partition_biz_bg)
select
    app_name,
    page_identifier,
    page_name_my,
    page_cat,
    uv_src,
    cast(fp1.performance_id as bigint) as performance_id,
    performance_name,
    category_id,
    category_name,
    shop_id,
    shop_name,
    city_id,
    city_name,
    province_id,
    province_name,
    union_id,
    user_id,
    os,
    is_native,
    idfa,
    imei,
    session_id,
    stat_time,
    refer_page_identifier,
    custom,
    extension,
    page_city_id,
    page_city_name,
    geo_city_id,
    geo_city_name,
    ip_location_city_id,
    ip_location_city_name,
    biz_bg as partition_biz_bg
from (
    select
        app_name,
        dmp.page_identifier,
        page_name_my,
        biz_bg,
        page_cat,
        (
        case when cid_type='h5' then custom['fromTag']
             when cid_type in ('mini_programs','pc') then utm_source
        end 
        ) as uv_src,
        (
        case when biz_bg=1 and page_cat in (2,3)
             then case when cid_type='h5' then custom['performance_id']
                  when cid_type='mini_programs' then custom['id']
                  when cid_type='native' then custom['drama_id'] end
        end
        ) as performance_id,
        union_id,
        user_id,
        os,
        is_native,
        idfa,
        imei,
        session_id,        
        stat_time,
        refer_page_identifier,
        custom,
        extension,
        page_city_id,
        page_city_name,
        geo_city_id,
        geo_city_name,
        ip_location_city_id,
        ip_location_city_name
    from (
        select page_identifier, page_name_my, cid_type, page_cat, biz_par, biz_bg from mart_movie.dim_myshow_pv where status=1
         ) dmp    -- 演出页面维表
        join 
        (
        select *
        from 
            mart_flow.detail_flow_pv_wide_report  -- 猫眼电影频道数据
        where
            partition_date='$now.date'
            and
            partition_log_channel='movie'
            and
            partition_app in ('movie', 'dianping_nova', 'other_app', 'dp_m', 'group')
        ) pv
    on dmp.page_identifier=pv.page_identifier
    ) fp1 
    left join 
        (
        select performance_id, activity_id, performance_name, category_id, category_name, area_1_level_name, area_2_level_name, province_name, province_id, city_id, city_name, shop_id, shop_name 
        from mart_movie.dim_myshow_performance where performance_id is not null
        ) per
    on fp1.performance_id=per.performance_id
;
##TargetDDL##
CREATE TABLE IF NOT EXISTS `$target.table`
(
    app_name             string    COMMENT 'APP中文描述',
    page_identifier      string    COMMENT '页面cid',  
    page_name_my         string    COMMENT '页面名称',  
    page_cat             int       COMMENT '页面分类',  
    uv_src               string    COMMENT '页面来源',  
    performance_id       bigint    COMMENT '演出ID-项目ID', 
    performance_name     string    COMMENT '演出名称',     
    category_id          bigint    COMMENT '类别ID', 
    category_name        string    COMMENT '类别名称',   
    shop_id              bigint    COMMENT '点评场馆ID',     
    shop_name            string    COMMENT '点评场馆名称',     
    city_id              bigint    COMMENT '城市ID',  
    city_name            string    COMMENT '城市名称', 
    province_id          bigint    COMMENT '省份ID',  
    province_name        string    COMMENT '省份名称',                      
    union_id             string    COMMENT '设备ID',
    user_id              bigint    COMMENT '用户id',
    os                   string    COMMENT 'os', 
    is_native            int       COMMENT 'is_native，sdk上报类型',
    idfa                 string    COMMENT 'idfa',
    imei                 string    COMMENT 'imei',    
    session_id           string    COMMENT 'session_id',     
    stat_time            string    COMMENT 'stat_time',
   refer_page_identifier string    COMMENT 'refer_page_identifier',  
    custom               map<string,string>    COMMENT 'custom',
    extension            map<string,string>    COMMENT 'extension',
    page_city_id         bigint    COMMENT '页面城市id',
    page_city_name       string    COMMENT '页面城市名称',
    geo_city_id          bigint    COMMENT 'geohash 城市ID',
    geo_city_name        string    COMMENT 'geohash 城市名称',
    ip_location_city_id  bigint    COMMENT 'ip城市ID',
    ip_location_city_name  string    COMMENT 'ip城市名称'
) COMMENT '猫眼演出业务流量宽表'
PARTITIONED BY (
    partition_date    string  COMMENT '日志生成日期',
    partition_biz_bg  string  COMMENT 'biz_bg'
) STORED AS ORC;
