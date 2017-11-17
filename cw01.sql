select 
	cm.CityID,
	cm.TPCityName,
	am.TPSProjectID,
	o.tpid,
    case when CategoryID=1 then '演唱会'
    else '其他' end as sort,
	ops.PerformanceID,
	p.name,
	count(distinct o.orderid) as order_num,
	sum(o.TotalPrice) as gmv,  
	sum(o.SalesPlanSellPrice*o.SalesPlanCount) as net_gmv,
    sum(o.SalesPlanSupplyPrice*o.SalesPlanCount) as net_gmv_sp
from 
	(
	select
		tpid,
		orderid,
		totalprice,
		SalesPlanID,
      	SalesPlanCount,
     	SalesPlanSupplyPrice,
     	SalesPlanSellPrice
	from
		origindb.dp_myshow__S_Order
	where 
		PaidTime>='2017-10-01' 
		and PaidTime<'2017-11-01'
		and tpid>=6 
		and ReserveStatus in (9,7) 
      	and RefundStatus in (0,1,4)
) o
	join (
	select
		orderid,
		performanceID
	from
		origindb.dp_myshow__S_OrderSalesPlanSnapshot
	where
		PerformanceId not in (20198,20466,20467,20468,20469,20470,20471,20472,20473,20474,20475,20476,20477,20478,20479,20480,20481,20520,20826,20827,20828,20829,20830,20980,21007,21008,21009,21011,21014,21015,21016,21017,21018,21019,21020,21021,21022,21023,21024,21025,21026,21027,21028,21029,21030,21032,21060,21061,21062,21063,21064,21065,21066,21067,21068,21069,21070,21071,21072,21073,21074,21075,21076,21077,21078,21079,21080,21081,21082,21083,21084,21085,21086,21087,21088,21089,21090,21091,21092,21093,21094,21095,21096,21097,21098,21099,21100,21101,21102,21103,21104,21105,21106,21107,21108,21109,21110,21111,21112,21113,21114,21121,21122,21139,21140,21141,21142,21143,21144,21145,21146,21147,21148,21162,21164,21165,21196,21265,21633,21992,22008,22009,22010,22011,22015,22016,22017,22018,22019,22020,22022,22023,22024,22025,22026,22027,22031,22074,22075,22076,22130,22155,22156,22157,22657,22703,23194,23195,23600,23606,23884,23885,23901,23902)
		) ops on o.OrderId=ops.OrderId
	left join origindb.dp_myshow__S_Performance p on p.PerformanceID=ops.PerformanceID
    left join origindb.dp_myshow__BS_ActivityMap am on am.ActivityID=p.BSPerformanceID and am.TPID>=6
	left join (
      select
      	CityID,
      	max(TPCityName) TPCityName
      from
      		origindb.dp_myshow__S_CityMap
      GROUP BY
      	1
      ) cm on am.CityID=cm.CityID
group by 
	1,2,3,4,5,6,7
