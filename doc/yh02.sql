
select
    sc.Name,
    count(distinct sp.PerformanceID),
    count(distinct case when ss.TicketPrice>ss.SellPrice then sp.PerformanceID end)
from
    (
    /*销售计划表*/ select TicketClassID, TicketPrice, SellPrice from S_SalesPlan where OffTime>'2017-11-24' and OnTime<='2017-11-24' and CurrentAmount>0
    ) ss
join (
    /*票类表*/ select TicketClassID, PerformanceID, Description from S_TicketClass
    ) st using(TicketClassID)
    join (
    /*演出项目信息表*/ select PerformanceID, CategoryID from S_Performance
    ) sp on sp.PerformanceID=st.PerformanceID
    join (
    /*类别表*/ select CategoryID, Name from S_Category
    ) sc on sc.CategoryID=sp.CategoryID
group by
    1
limit 100

