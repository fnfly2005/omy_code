creator='fannian@maoyan.com'
'db': META['hmart_movie'],
'db': META['hmart_movie'],
'table': 'aggr_myshow2mt_salesreport',

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)
#if $isRELOAD
drop table `$target.table`
#end if 

##Load##
##-- Load节点, (可以留空)
drop table if EXISTS mart_movie_test.aggr_myshow2mt_salesreport_temp;
create table mart_movie_test.aggr_myshow2mt_salesreport_temp as
select
	so.performance_id,
	cit.mt_city_id as city_id,
	cit.mt_city_name as city_name,
	cit.mt_city_rank as city_rank,
	per.category_id,
	per.category_name,
	performance_name,
	celebrityList,
	performance_ticketstatus,
	firstshowtime,
	lastshowtime,
    minprice,
    maxprice,
	click_num_oneday,
	click_num_threeday,
	click_num_weekday,
	order_num_oneday,
	order_num_three,
	order_num_week,
    shop_id
from (
    select
        performance_id,
        count(distinct case when partition_date='$now.date' 
            then order_id end) as order_num_oneday,
        count(distinct case when partition_date>='$now.delta(2).date' 
            then order_id end) as order_num_three,
        count(distinct order_id) as order_num_week,
        collect_set(celebrityname) as celebrityList
    from (
        select
            partition_date,
            performance_id,
            order_id
        from 
            mart_movie.detail_myshow_salepayorder
        where
            partition_date>='$now.delta(6).date'
            and partition_date<='$now.date'
        ) spo
        left join
            origindb.dp_myshow__s_celebrityperformancerelation sce
        on spo.performance_id=sce.performanceid
    group by
        performance_id
    ) as so
    join (
        select
            performance_id,
            performance_name,
            category_id,
            category_name,
            city_id,
            shop_id,
            firstshowtime,
            lastshowtime,
            minprice,
            maxprice,
            performance_ticketstatus
        from
            mart_movie.dim_myshow_performance
        where
            performance_online_flag=1
        ) as per
    on so.performance_id=per.performance_id
    left join (
        select
            case when page_identifier='c_b5okwrne' 
                then custom['dramaId']
            when page_identifier='packages/show/pages/detail/index'
                then custom['id']
            when page_identifier='c_Q7wY4'
                then custom['performance_id']
            else 0 end as performance_id,
            count(case when partition_date='$now.date'
                then 1 end) as click_num_oneday,
            count(case when partition_date>='$now.delta(2).date'
                then 1 end) as click_num_threeday,
            count(1) as click_num_weekday
        from
            mart_flow.detail_flow_pv_wide_report
        where
            partition_date>='$now.delta(6).date'
            and partition_date<='$now.date'
            and partition_log_channel='movie'
            and partition_app in (
                'movie',
                'dianping_nova',
                'other_app',
                'dp_m',
                'group'
                )
            and page_identifier in (
                'packages/show/pages/detail/index',
                'c_b5okwrne',
                'c_Q7wY4'
                )
        group by
            case when page_identifier='c_b5okwrne' 
                then custom['dramaId']
            when page_identifier='packages/show/pages/detail/index'
                then custom['id']
            when page_identifier='c_Q7wY4'
                then custom['performance_id']
            else 0 end
        ) as pv
    on so.performance_id=pv.performance_id
    left join (
        select
            city_id,
            mt_city_id
        from
            mart_movie.dim_myshow_city
        where
            dp_flag=0
        ) dc
    on per.city_id=dc.city_id
    left join 
        dw.dim_mt_city cit
    on cit.mt_city_id=dc.mt_city_id
;
insert OVERWRITE TABLE `$target.table` PARTITION(partition_date='$now.date')
select
	performance_id,
	city_id,
	city_name,
	city_rank,
	category_id,
	category_name,
	1 as is_hot,
	null as quality,
    poi_id,
	poi_name,
	latitude,
	longitude,
    poi_first_cate_id,
    poi_first_cate_name,
    poi_second_cate_id,
    poi_second_cate_name,
    poi_third_cate_id,
    poi_third_cate_name,
	barea_id,
	barea_name,
	performance_name,
	celebrityList,
	performance_ticketstatus,
	firstshowtime,
	lastshowtime,
    minprice,
    maxprice,
	click_num_oneday,
	click_num_threeday,
	click_num_weekday,
	order_num_oneday,
	order_num_three,
	order_num_week
from 
    mart_movie_test.aggr_myshow2mt_salesreport_temp st
    left join (
        select
            dp_shop_id,
            mt_main_poi_id
        from
            dw.dim_dp_shop
        ) as dsh
    on dsh.dp_shop_id=st.shop_id
    left join (
        select
	        mt_poi_id as poi_id,
            mt_poi_name as poi_name,
            latitude,
            longitude,
            mt_poi_first_cate_id as poi_first_cate_id,
            mt_poi_first_cate_name as poi_first_cate_name,
            mt_poi_second_cate_id as poi_second_cate_id,
            mt_poi_second_cate_name as poi_second_cate_name,
            mt_poi_third_cate_id as poi_third_cate_id,
            mt_poi_third_cate_name as poi_third_cate_name,
            barea_id,
            business_area_name as barea_name
        from
            dw.dim_mt_poi
            ) poi
        on poi.poi_id=dsh.mt_main_poi_id

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`performance_id` bigint COMMENT '项目ID',
`city_id` bigint COMMENT '演出城市id-美团城市id ',
`city_name` string COMMENT '城市名称',
`city_rank` string COMMENT '城市分级',
`category_id` int COMMENT '演出分类-performance分为体育赛事,戏剧等 ',
`category_name` string COMMENT '演出分类-针对performance ',
`is_hot` int COMMENT '是否为热门项目-金刚区发现精彩的项目 ',
`quality` int COMMENT '质量-主要是为了区分一些高质量的演出项目,比如一些大腕的演唱会,高端的音乐会等 ',
`poi_id` bigint COMMENT '演出场馆id-美团poiid ',
`poi_name` string COMMENT '场馆名称',
`latitude` double COMMENT '经度',
`longitude` double COMMENT '纬度',
`poi_first_cate_id` string COMMENT 'POI一级品类id',
`poi_first_cate_name` string COMMENT 'POI一级品类名称',
`poi_second_cate_id` string COMMENT 'POI二级品类id',
`poi_second_cate_name` string COMMENT 'POI二级品类名称',
`poi_third_cate_id` string COMMENT 'POI 三级品类id',
`poi_third_cate_name` string COMMENT 'POI三级品类名称',
`barea_id` bigint COMMENT '商圈id',
`barea_name` string COMMENT '商圈名称',
`performance_name` string COMMENT '演出项目名称',
`celebrityList` array<string> COMMENT '演出项目关联的艺人列表-针对performance ',
`performance_ticketstatus` int COMMENT '售票状态,1 :即将开售 2 :预售 3 :在售中 4 :已售罄 5 :已结束 -针对perfomance ',
`firstShowTime` string COMMENT '演出开始时间,格式 :yyyy-MM-dd hh :mm :ss 针对performance ',
`lastShowTime` string COMMENT '演出结束时间,格式 :yyyy-MM-dd hh :mm :ss -针对performance ',
`minprice` double COMMENT '当前售票最低价格-针对performance ',
`maxprice` double COMMENT '当前售票最高价格-针对performance ',
`click_num_oneday` bigint COMMENT '前一天的点击量',
`click_num_threeday` bigint COMMENT '前三天的点击量',
`click_num_weekday` bigint COMMENT '前七天的点击量',
`order_num_oneday` bigint COMMENT '下单量-1天前 ',
`order_num_three` bigint COMMENT '下单量-三天前 ',
`order_num_week` bigint COMMENT '下单量-七天前 '
) COMMENT '美团运营区接口表'
partitioned by (partition_date string)
row format delimited
    fields terminated by '\t'
stored as orc
