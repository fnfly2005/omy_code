
select
    substr(ss1.dt,1,7) as mt,
    ss1.customer_type_name,
    ss1.customer_lvl1_name,
    avg(ss1.ap_num) as ap_num,
    avg(ss1.as_num) as as_num,
    avg(ss1.asp_num) as asp_num,
    avg(sp1.sp_num) as sp_num,
    sum(sp1.order_num) as order_num,
    sum(sp1.ticket_num) as ticket_num,
    sum(sp1.totalprice) as totalprice,
    sum(sp1.grossprofit) as grossprofit
from (
    select 
        dt,
        coalesce(customer_type_name,'全部') as customer_type_name,
        coalesce(customer_lvl1_name,'全部') as customer_lvl1_name,
        ap_num,
        as_num,
        asp_num
    from (
        select
            ss.dt,
            cus.customer_type_name,
            cus.customer_lvl1_name,
            count(distinct ss.performance_id) as ap_num,
            count(distinct ss.shop_id) as asp_num,
            count(distinct ss.salesplan_id) as as_num
        from
            (
            select partition_date as dt, performance_id, customer_id, shop_id, show_id, salesplan_sellout_flag, project_id, salesplan_id from mart_movie.detail_myshow_salesplan where salesplan_id is not null and partition_date>='$$begindate' and partition_date<'$$enddate'
            and salesplan_sellout_flag=0
            ) ss
            left join (
            select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
            ) cus
            on ss.customer_id=cus.customer_id
        group by
            ss.dt,
            cus.customer_type_name,
            cus.customer_lvl1_name
        grouping sets(
        (ss.dt,cus.customer_type_name),
        (ss.dt,cus.customer_type_name,cus.customer_lvl1_name)
        )
        ) as ss0
    ) as ss1
    left join (
        select
            dt,
            coalesce(customer_type_name,'全部') as customer_type_name,
            coalesce(customer_lvl1_name,'全部') as customer_lvl1_name,
            sp_num,
            order_num,
            ticket_num,
            totalprice,
            grossprofit
        from (
            select
                spo.dt,
                cus.customer_type_name,
                cus.customer_lvl1_name,
                count(distinct spo.performance_id) as sp_num,
                count(distinct spo.order_id) as order_num,
                sum(spo.salesplan_count*spo.setnumber) as ticket_num,
                sum(spo.totalprice) as totalprice,
                sum(spo.grossprofit) as grossprofit
            from
                (
                select partition_date as dt, order_id, sellchannel, customer_id, performance_id, meituan_userid, show_id, totalprice, grossprofit, setnumber, salesplan_count, expressfee, project_id, bill_id, salesplan_id from mart_movie.detail_myshow_salepayorder where partition_date>='$$begindate' and partition_date<'$$enddate'
                ) spo
                left join (
                select customer_id, customer_type_id, customer_type_name, customer_lvl1_name, customer_name, customer_shortname, customer_code from mart_movie.dim_myshow_customer where customer_id is not null
                ) cus
                on spo.customer_id=cus.customer_id
            group by
                spo.dt,
                cus.customer_type_name,
                cus.customer_lvl1_name
            grouping sets(
            (spo.dt,cus.customer_type_name),
            (spo.dt,cus.customer_type_name,cus.customer_lvl1_name)
            )
            ) as sp0
        ) as sp1
    on sp1.dt=ss1.dt
    and sp1.customer_type_name=ss1.customer_type_name
    and sp1.customer_lvl1_name=ss1.customer_lvl1_name
group by
    substr(ss1.dt,1,7),
    ss1.customer_type_name,
    ss1.customer_lvl1_name
;
