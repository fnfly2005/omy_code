SELECT
    rsf.item_id,
    ii.title_cn,
    sum(total_money/100) gmv
FROM
    report_sales_flow rsf
    JOIN item_info ii ON ii.id = rsf.item_id
    JOIN item_type it ON it.id = ii.type_id
WHERE
    from_unixtime(rsf.create_time /1000,'%Y-%m-%d') >= '2017-01-01'
    AND pay_no IS NOT NULL
    and it.name='流行'
    AND order_src IN (2, 12, 15, 16, 8, 9, 10, 14, 7)
GROUP BY
    1,2
ORDER BY
    3 DESC
LIMIT 50;
select distinct
    of.openid,
    of.passport_user_mobile,
    ii.title_cn
from
    (SELECT
        item_info.id,
        item_info.title_cn,
        item_info.title_en,
        item_info.title_short
    FROM
        item_info
    WHERE
        item_info.item_no IN (
        1611219738,
        1611216166,
        1607046500
        )) ii
    join report_sales_flow rsf
    on ii.id=rsf.item_id
    join order_form of
    on rsf.order_id=of.order_id
where
    of.order_src IN (2, 12, 15, 16, 8, 9, 10, 14, 7)
    and of.order_status>=1
union all
select distinct
    of.openid,
    of.passport_user_mobile,
    ii.title_cn
from
    order_form of
    join report_sales_flow rsf
    on rsf.order_id=of.order_id
    left join item_info ii
    on ii.id=rsf.item_id
where
    of.order_src IN (2, 12, 15, 16, 8, 9, 14, 7)
    and of.order_status>=1
    and rsf.item_id in ('ff8080815a5e551b015a636ff8b130ff',
    'ff8080815c5c6b4b015c6802ce156884',
    'ff80808159c21e4e0159ca5ac3b141d0')
