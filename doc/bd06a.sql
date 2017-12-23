select substr(ssp.paytime,1,10) dt,
       area_1_level_name,
              area_2_level_name,
                     province_name,
                            sum(ssp.totalprice) totalprice,
                                   sum(ssp.grossprofit) grossprofit
                                     from origindb.dp_myshow__s_settlementpayment ssp
                                       join origindb.dp_myshow__s_order so
                                           on ssp.orderid=so.orderid
                                             join mart_movie.dim_myshow_city dc
                                                 on dc.city_id=so.dpcityid
                                                  where ssp.paytime is not null
                                                     and ssp.paytime>='2017-12-08'
                                                        and ssp.paytime<'2017-12-15'
                                                           and dc.area_1_level_name='东部'
                                                            group by 1,2,3,4
