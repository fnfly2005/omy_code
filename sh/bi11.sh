#!/bin/bash
#etl/detail_myshow_saleorder.sql
source ./fuc.sh

downloadsql_file $0
ery=`fun sql/dp_myshow__s_orderdelivery.sql u`
ity=`fun sql/dim_myshow_city.sql`

fus() {
    echo "
    select
        ery.city_name
    from (
        select distinct
            cityname as city_name
        $ery
            and cityname is not null
            and cityname not like '%区划'
        ) as ery
        left join (
        $ity
        ) ity
        on ity.city_name=ery.city_name
    where
        ity.city_name is null
    ${lim-;}"
}

fuc $1
