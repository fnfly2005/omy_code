/*微格历史数据*/
select UserMobileNo
  from Gewara_Order
 where categoryname in (
    'concert',
    'liveclub',
    '流行',
    '摇滚',
    '音乐节',
    '小型现场',
    '摇滚',
    '美声',
    '民族'
    )
   and ordercity in (
   '上海',
   '杭州',
   '宁波',
   '金华',
   '绍兴',
   '台州',
   '温州',
   '衢州',
   '丽水',
   '嘉兴',
   '舟山',
   '杭州市',
   '宁波市',
   '金华市',
   '绍兴市',
   '台州市',
   '温州市',
   '衢州市',
   '丽水市',
   '嘉兴市',
   '舟山市',
   '苏州市'
    )
limit 100000
