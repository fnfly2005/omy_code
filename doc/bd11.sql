
select distinct
    case when $online=1 then dt
    else minon_dt end as dt,
	ssp.customer_type_name,
	ssp.customer_lvl1_name,
	ssp.area_1_level_name,
	ssp.area_2_level_name,
	ssp.province_name,
	ssp.city_name,
	ssp.category_name,
	ssp.performance_id,
	ssp.performance_name,
	ssp.shop_name,
	ssp.bd_name
from (
    select salesplan_id, salesplan_name, shop_id, category_name, show_starttime, performance_id, performance_name, show_id, show_name, ticketclass_id, ticket_price, salesplan_ontime, salesplan_createtime, customer_id, customer_name, customer_type_name, customer_lvl1_name, shop_name, city_name, area_1_level_name, area_2_level_name, province_name, setnumber, bd_name from mart_movie.dim_myshow_salesplan where 1=1
    ) ssp
    left join (
        select
            partition_date as dt,
            salesplan_id
        from mart_movie.detail_myshow_salesplan where 1=1 and partition_date>='$$begindate' and partition_date<'$$enddate'
            and salesplan_sellout_flag=0
            and $online=1
        ) dms
    on ssp.salesplan_id=dms.salesplan_id
    left join (
        select
            performance_id,
            substr(min(salesplan_ontime),1,10) as minon_dt
        from mart_movie.dim_myshow_salesplan where 1=1
            and $online=0
        group by
            1
        ) ssu
    on ssp.performance_id=ssu.performance_id
    and minon_dt>='$$begindate'
    and minon_dt<'$$enddate'
where
    ($online=1 
    and dms.salesplan_id is not null)
    or ($online=0
    and ssu.performance_id is not null)
;
