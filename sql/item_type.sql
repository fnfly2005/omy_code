/*项目类目表*/
SELECT
	it2.name as c_name,
    it1.id
FROM
	item_type it1
	JOIN item_type it2 
    ON it1.pid = it2.id
