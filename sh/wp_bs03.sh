#!/bin/bash
#--------------------猫眼演出readme-------------------
#*************************api1.0*******************
# 优化输出方式,优化函数处理
#*************************bs31/wp_bs03_1.0*******************
#关于业务描述和重点风险证明材料收集准备需求-演出票务
#数据口径-项目最早上架时间
#维度-月、业务、城市、项目数
#统计城市、业务方计数
path="/Users/fannian/Documents/my_code/"
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

ib=`fun item_balance.sql` 
pub=`fun item_pubon.sql`

file="bs31"
lim=";"
attach="${path}doc/${file}.sql"

echo "
SELECT
	left(a.time,7) '上架时间',
	a.city_name '城市名称',
	b.business_name '客户名称',
	count(distinct a.id) '项目数'
FROM
	(
		SELECT
			i.id,
i.business_id,
			c.city_name,
			a.time
		FROM
			(
				SELECT
					a.item_id,
					a.business_id,
					FROM_UNIXTIME(LEFT(a.pubon_time, 10)) 'time'
				FROM
					item_pubon a
				UNION ALL
					SELECT
						b.item_id,
						b.business_id,
						FROM_UNIXTIME(LEFT(b.pubon_time, 10)) 'time'
					FROM
						item_puboff b
			) a,
			item_info i,
			city c,
			app_access l,
			item_match_channel m
		WHERE
			a.item_id = i.id
		AND i.city_id = c.city_id
		AND l.id = m.app_access_id
		AND m.item_id = i.id
		AND LEFT (a.time, 10) >= '2017-03-01'
		AND LEFT (a.time, 10) < '2018-01-01'
		AND l.order_sourcce NOT IN (1, 5, 6)
		AND (
			i.title_cn NOT LIKE "%测试%"
			AND i.title_cn NOT LIKE "%调试%"
			AND i.title_cn NOT LIKE "%勿动%"
			AND i.title_cn NOT LIKE "%test%"
			AND i.title_cn NOT LIKE "%废%"
			AND i.title_cn NOT LIKE "%ceshi%"
		)
	) a
LEFT JOIN business_base_info b ON a.business_id = b.business_id
GROUP BY
	1,2,3
$lim">${attach}

echo "succuess!"
echo ${attach}
if [ ${1}r == pr ]
#加上任意字符，如r 避免空值报错
then
cat ${attach}
#命令行参数为p时，打印输出文件
fi


