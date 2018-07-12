
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
			select user_id, mobile, city_id, movie_id, active_date from mart_movie.dim_myshow_movieuser
			where
				city_id in (
					select
						mt_city_id
					from mart_movie.dim_myshow_city where dp_flag=0
						and province_name='海南'
						and dp_flag=0
					)
			union all	
			select user_id, mobile, city_id, movie_id, active_date from mart_movie.dim_myshow_movieusera
			where
				city_id in (
					select
						mt_city_id
					from mart_movie.dim_myshow_city where dp_flag=0
						and province_name='海南'
						and dp_flag=0
					)
			) as tm
		) as m
		left join (
		select mobile, mobile_type, city_id from upload_table.mobile_info
		) mm
		on substr(m.mobile,1,7)=mm.mobile
	group by
		1
	) as cm
	left join (
		select city_id, mt_city_id, city_name, province_name, area_1_level_name, area_2_level_name from mart_movie.dim_myshow_city where dp_flag=0
		) ci
	on cm.city_id=ci.city_id
;
