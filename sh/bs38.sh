#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
path=""
fun() {
    if [ $2x == dx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '/where/,$'d`
    elif [ $2x == ux ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed '1,/from/'d | sed '1s/^/from/'`
    elif [ $2x == tx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g"`
    elif [ $2x == utx ];then
        echo `cat ${path}sql/${1} | grep -iv "/\*" | sed "s/begindate/today{-1d}/g;s/enddate/today{-0d}/g" | sed '1,/from/'d | sed '1s/^/from/'`
    else
        echo `cat ${path}sql/${1} | grep -iv "/\*"`
    fi
}

cit=`fun dim_myshow_city.sql u`
ci=`fun dim_myshow_city.sql`
dmm=`fun dim_myshow_movieuser.sql d`
dma=`fun dim_myshow_movieusera.sql d`
mm=`fun mobile_info.sql`


file="bs38"
lim=";"
attach="${path}doc/${file}.sql"

echo "
select
	city_name,
	n_num
from (
	select
		city_id,
		count(distinct m.mobile) n_num
	from (
		select distinct
			mobile
		from (
			$dmm
			where
				city_id in (
					select
						mt_city_id
					$cit
						and province_name='海南'
						and dp_flag=0
					)
			union all	
			$dma
			where
				city_id in (
					select
						mt_city_id
					$cit
						and province_name='海南'
						and dp_flag=0
					)
			) as tm
		) as m
		left join (
		$mm
		) mm
		on substr(m.mobile,1,7)=mm.mobile
	group by
		1
	) as cm
	left join (
		$ci
		) ci
	on cm.city_id=ci.city_id
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


