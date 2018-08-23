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
    'table': 'dim_myshow_salesplan', ##-- 单引号中填写目标表名
}

##Extract##
##-- Extract节点, 这里填写一个能在source.db上执行的sql

##Preload##
##-- Preload节点, 这里填写一个在load到目标表之前target.db上执行的sql(可以留空)

##Load##
##-- Load节点, (可以留空)
insert OVERWRITE TABLE `$target.table`
select
    salesplan_id,
    agent_type,
    tpshowid,
    tpsalesplanid,
    salesplan_name,
    maxbuylimit,
    ticket_price,
    supplier_price,
    sell_price,
    salesplan_offtime,
    ticket_status,
    islimited,
    current_amount,
    salesplan_createtime,
    salesplan_editstatus,
    tpticketclassid,
    sellpricelist,
    activity_salesplan_id,
    minbuylimit,
    salesplan_ontime,
    show_id,
    activity_show_id,
    show_name,
    show_starttime,
    show_endtime,
    show_isthrough,
    show_type,
    show_seattype,
    show_editstatus,
    show_createtime,
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
    ticketclass_id,
    activity_ticketclassid,
    setnumber,
    isset,
    ticketclass_description,
    ticketclass_editstatus,
    ticketclass_createtime,
    project_id,
    contract_id,
    bd_userid,
    bd_name,
    customer_id,
    customer_code,
    customer_name,
    customer_shortname,
    customer_type_id,
    customer_type_name,
    customer_lvl1_id,
    customer_lvl1_name,
    case when to_date(salesplan_offtime)<='$now.date' then 3
    when ticket_status in (2,3)
        and salesplan_editstatus=1
        and ticketclass_online_flag=1
        and show_online_flag=1
        and performance_online_flag<>0 
        then (
            case when performance_online_flag=2 then 1
            when (performance_online_flag=1
                    and islimited=0
                    and current_amount<=0) then 2
            else 0 end
            )
    else 3 end as salesplan_sellout_flag,
    stockoutregister,
    onsaletime,
    needremind,
    countdowntime,
    from_unixtime(unix_timestamp(),'yyyy-MM-dd HH:mm:ss') AS etl_time
from (
select
    ssp.salesplanid as salesplan_id,
    ssp.agenttype as agent_type,
    ssp.tpshowid,
    ssp.tpsalesplanid,
    ssp.name as salesplan_name,
    ssp.maxbuylimit,
    ssp.ticketprice as ticket_price,
    ssp.supplierprice as supplier_price,
    ssp.sellprice as sell_price,
    case when ssp.offtime is null then ds.show_offtime 
    when ssp.offtime<'2016-01-01' then ds.show_offtime 
    else ssp.offtime end as salesplan_offtime,
    ssp.tpticketstatus as ticket_status,
    ssp.islimited,
    ssp.currentamount as current_amount,
    ssp.createtime as salesplan_createtime,
    ssp.editstatus as salesplan_editstatus,
    ssp.tpticketclassid,
    ssp.sellpricelist,
    ssp.bssalesplanid as activity_salesplan_id,
    ssp.minbuylimit,
    case when ssp.ontime is null then ssp.createtime
    when ssp.ontime<'2016-01-01' then ssp.createtime
    else ssp.ontime end as salesplan_ontime,
    ds.show_id,
    ds.activity_show_id,
    ds.show_name,
    ds.show_starttime,
    ds.show_endtime,
    ds.show_isthrough,
    ds.show_type,
    ds.show_seattype,
    ds.show_online_flag,
    ds.show_offtime,
    dpe.performance_id,
    dpe.activity_id,
    dpe.performance_name,
    dpe.performance_shortname,
    dpe.category_id,
    dpe.category_name,
    dpe.city_id,
    dpe.city_name,
    dpe.province_id,
    dpe.province_name,
    dpe.area_1_level_id,
    dpe.area_1_level_name,
    dpe.area_2_level_id,
    dpe.area_2_level_name,
    dpe.shop_id,
    dpe.shop_name,
    ds.show_editstatus,
    dpe.performance_ticketstatus,
    dpe.performance_editstatus,
    dpe.performance_online_flag,
    ds.show_createtime,
    dt.ticketclass_id,
    dt.activity_ticketclassid,
    dt.setnumber,
    dt.isset,
    dt.ticketclass_description,
    dt.ticketclass_editstatus,
    dt.ticketclass_createtime,
    dt.ticketclass_online_flag,
    ssp.ProjectID as project_id,
    ssp.ContractID as contract_id,
    ssp.BDUserID as bd_userid,
    ssp.bdusername as bd_name,
    dc.customer_id,
    dc.customer_code,
    dc.customer_name,
    dc.customer_shortname,
    dc.customer_type_id,
    dc.customer_type_name,
    dc.customer_lvl1_id,
    dc.customer_lvl1_name,
    dpe.stockoutregister,
    dpe.onsaletime,
    dpe.needremind,
    dpe.countdowntime
from origindb.dp_myshow__s_salesplan as ssp
  left join mart_movie.dim_myshow_customer dc
    on ssp.tpid=dc.customer_id
  left join mart_movie.dim_myshow_show as ds
    on ssp.showid=ds.show_id
  left join mart_movie.dim_myshow_performance as dpe
    on ds.performance_id=dpe.performance_id
  left join mart_movie.dim_myshow_ticketclass as dt
    on ssp.ticketclassid=dt.ticketclass_id
   ) as ss
   
##TargetDDL##
##-- 目标表表结构
CREATE TABLE IF NOT EXISTS `$target.table`
(
`salesplan_id` bigint COMMENT '销售计划ID',
`agent_type` int COMMENT '代理第三方类型 1:总代理 2:分销商',
`tpshowid` string COMMENT '第三方场次ID',
`tpsalesplanid` string COMMENT '第三方销售计划ID',
`salesplan_name` string COMMENT '销售计划名称',
`maxbuylimit` bigint COMMENT '最大购买上限',
`ticket_price` double COMMENT '票面价',
`supplier_price` double COMMENT '采购价',
`sell_price` double COMMENT '售价',
`salesplan_offtime` string COMMENT '下架时间',
`ticket_status` int COMMENT '售票状态 1:停售 2:预售 3:在售',
`islimited` int COMMENT '是否限量: 无限库存0  限量库存1',
`current_amount` bigint COMMENT '当前剩余库存总量',
`salesplan_createtime` string COMMENT '销售计划添加时间',
`salesplan_editstatus` bigint COMMENT '编辑状态 0下架 1上架',
`tpticketclassid` string COMMENT '第三方票档id',
`sellpricelist` string COMMENT '售价数组json',
`activity_salesplan_id` bigint COMMENT '后台数据库销售计划id',
`minbuylimit` bigint COMMENT '最小购买份数',
`salesplan_ontime` string COMMENT '上架时间',
`show_id` bigint COMMENT '场次ID',
`activity_show_id` bigint COMMENT '后台场次id',
`show_name` string COMMENT '场次名称',
`show_starttime` string COMMENT '场次开始时间',
`show_endtime` string COMMENT '场次结束时间',
`show_isthrough` int COMMENT '是否为特殊场次 通票 ',
`show_type` int COMMENT '场次类型：1为单场票 2为通票 3为连票 ',
`show_seattype` int COMMENT '场次座位类型 0:非选座 1:选座',
`show_editstatus` int COMMENT '0下架 1上架',
`show_createtime` string COMMENT '创建时间',
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
`shop_id` bigint COMMENT '商铺ID',
`shop_name` string COMMENT '商铺名称',
`performance_ticketstatus` int COMMENT '售票状态1 停售 2 预售 3 在售中 4 已售罄 5 已结束',
`performance_editstatus` int COMMENT '0下架 1上架',
`ticketclass_id` int COMMENT '票类ID 票档ID',
`activity_ticketclassid` int COMMENT '后台票类ID',
`setnumber` int COMMENT '票数量 如果是套票 ',
`isset` int COMMENT '是否是套票',
`ticketclass_description` string COMMENT '票类描述',
`ticketclass_editstatus` int COMMENT '0下架 1上架',
`ticketclass_createtime` string COMMENT '票档创建时间',
`project_id` bigint COMMENT '第三方系统ID-商品ID',
`contract_id` string COMMENT '合同ID',
`bd_userid` bigint COMMENT '销售用户id',
`bd_name` string COMMENT '销售姓名',
`customer_id` bigint COMMENT '客户ID',
`customer_code` bigint COMMENT '客户编号',
`customer_name` string COMMENT '客户名称',
`customer_shortname` string COMMENT '客户简称',
`customer_type_id` int COMMENT '客户类型ID',
`customer_type_name` string COMMENT '客户类型名称',
`customer_lvl1_id` int COMMENT '客户1级分类ID',
`customer_lvl1_name` string COMMENT '客户1级分类名称',
`salesplan_sellout_flag` int COMMENT '售罄标志 0:在售 1:项目售罄 2:SKU售罄 3:停售',
`stockoutregister` int COMMENT '是否缺货登记项目0不是1是',
`onsaletime` string COMMENT '开售时间',
`needremind` int COMMENT '是否设置开售提醒',
`countdowntime` string COMMENT '开始倒计时的时间',
`etl_time` string COMMENT '更新时间'
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
stored as orc
