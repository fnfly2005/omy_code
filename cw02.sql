select 
	p.CityID,
	cm.TPCityName,
	pd.BDID,
	pd.BDName,
	am.TPID,
	c.MYCustomerID,
	c.Name,
	p.sort,
	p.PerformanceID,
	p.name,
	pd.CreateTime
from 
	(
	select
		CityID,
		name,
		performanceID,
		BSPerformanceID,
		case when CategoryID=1 then '演唱会'
		else '其他' end as sort
	from
		S_Performance
	where
		CreateTime>='2017-10-01'
		) p
    	join BS_ActivityMap am on am.ActivityID=p.BSPerformanceID and am.TPID>=6
	join BS_ProjectDetail pd on am.TPSProjectID=pd.TPSProjectID and pd.CreateTime>='2017-10-01'
	and pd.CreateTime<'2017-11-01'
	left join S_Customer c on c.tpid=am.tpid
	left join (
      select
      	CityID,
      	max(TPCityName) TPCityName
      from
      	S_CityMap
      GROUP BY
      	1
      ) cm on p.CityID=cm.CityID
group by 
	1,2,3,4,5,6,7,8,9,10,11
Limit 10000
