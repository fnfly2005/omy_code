
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
			i.title_cn NOT LIKE %测试%
			AND i.title_cn NOT LIKE %调试%
			AND i.title_cn NOT LIKE %勿动%
			AND i.title_cn NOT LIKE %test%
			AND i.title_cn NOT LIKE %废%
			AND i.title_cn NOT LIKE %ceshi%
		)
	) a
LEFT JOIN business_base_info b ON a.business_id = b.business_id
GROUP BY
	1,2,3
;
