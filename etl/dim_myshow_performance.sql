##-- 这个是sqlweaver(美团自主研发的ETL工具)的编辑模板
##-- 本模板内容均以 ##-- 开始,完成编辑后请删除
##-- ##xxxx## 型的是ETL专属文档节点标志, 每个节点标志到下一个节点标志为本节点内容
##-- 流程应该命名成: 目标表meta名(库名).表名

##Description##
##--

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
    'table': 'dim_myshow_performance', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)

##Load##
##-- Load节点, (可以留空)
insert OVERWRITE TABLE `$target.table`
select 
        sp.PerformanceID as performance_id,
        sp.BSPerformanceID as activity_id,
        sp.Name as performance_name,
        sp.ShortName as performance_shortname,
        ca.category_id,
        ca.category_name,
        ci.city_id,
        ci.city_name,
        ci.province_id,
        ci.province_name,
        ci.area_1_level_id,
        ci.area_1_level_name,
        ci.area_2_level_id,
        ci.area_2_level_name,
        ds.shop_id,
        ds.shop_name,
        sp.TicketStatus as performance_ticketstatus,
        sp.EditStatus as performance_editstatus,
        case when sp.editstatus=1 and sp.iscomplete=1 then 
            (case when sp.ticketstatus in (2,3) then 1
            when sp.ticketstatus=4 then 2
            else 0 end)
        else 0 end as performance_online_flag,
        sp.CreateTime as performance_createtime,
        sp.firstshowtime,
        sp.lastshowtime,
        sp.minprice,
        sp.maxprice,
        sp.premiumstatus,
        sp.seattype as performance_seattype,
        sp.iscomplete,
        sp.StockOutRegister,
        sp.NeedAnswer,
        sp.QuestionBankId,
        sp.QuestionHint,
        pes.OnSaleTime,
        pes.NeedRemind,
        pes.CountdownTime,
        from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
  from origindb.dp_myshow__s_performance sp
  left join mart_movie.dim_myshow_city ci
    on sp.cityid=ci.city_id
  left join mart_movie.dim_myshow_category ca
    on sp.CategoryID=ca.category_id
  left join mart_movie.dim_myshow_shop ds
    on sp.ShopID=ds.shop_id
  left join (
    select
        Performanceid,
        OnSaleTime,
        NeedRemind,
        CountdownTime
    from (
        select
            max(SaleRemindID) as saleremindid
        from
            origindb.dp_myshow__s_performancesaleremind
        where
            status=1
        group by
            performanceid
        ) as pe1
        left join origindb.dp_myshow__s_performancesaleremind pe2
        on pe1.saleremindid=pe2.saleremindid
    ) as pes
    on sp.PerformanceID=pes.Performanceid
    

##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`performance_id` bigint COMMENT '演出ID-项目ID',
`activity_id` bigint COMMENT '后台演出ID',
`performance_name` string COMMENT '演出名称',
`performance_shortname` string COMMENT '演出短标题',
`category_id` bigint COMMENT '类别ID',
`category_name` string COMMENT '类别名称',
`city_id` bigint COMMENT '城市ID',
`city_name` string COMMENT '城市名称',
`province_id` int COMMENT '省份ID',
`province_name` string COMMENT '省份名称',
`area_1_level_id` int COMMENT '战区ID',
`area_1_level_name` string COMMENT '战区名称',
`area_2_level_id` int COMMENT '分区ID',
`area_2_level_name` string COMMENT '分区名称',
`shop_id` bigint COMMENT '场馆ID',
`shop_name` string COMMENT '场馆名称',
`performance_ticketstatus` int COMMENT '售票状态 1:未上线 2:预售 3:在售中 4:已售罄 5:已结束',
`performance_editstatus` int COMMENT '编辑状态 0:下架,1:上架',
`performance_online_flag` int COMMENT '在线标志 0:停售 1:在线 2:售罄',
`performance_createtime` string COMMENT '创建时间',
`firstshowtime` string COMMENT '首场时间',
`lastshowtime` string COMMENT '末场时间',
`minprice` double COMMENT '最低票价',
`maxprice` double COMMENT '最高票价',
`premiumstatus` int COMMENT '溢价状态 1:未知 2:溢价 3:没有溢价',
`performance_seattype` int COMMENT '场次座位类型 0:非选座 1:选座 2:既有选座也有非选座',
`iscomplete` int COMMENT '用于校验完整性 0:不完整 1:完整',
`stockoutregister` int COMMENT '是否缺货登记项目0不是1是',
`needanswer` int COMMENT '是否开启答题1是 0否',
`questionbankid` bigint COMMENT '题库ID',
`questionhint` string COMMENT '答题提示语',
`onsaletime` string COMMENT '开售时间',
`needremind` int COMMENT '是否设置开售提醒',
`countdowntime` string COMMENT '开始倒计时的时间',
`etl_time` string COMMENT '更新时间'
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
