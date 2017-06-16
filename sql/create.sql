create temporary table if not exists __temp( ssp_id UInt64, organization_id UInt32 DEFAULT 0, site_id UInt64 );
insert into __temp values(1,2,3), (4,5,6), (7,8,9);
select * from __temp FORMAT JSON;

$.post('http://10.8.1.28:8123/', 'create table if not exists __temp( ssp_id UInt64, organization_id UInt32 DEFAULT 0, site_id UInt64 ) engine=;', console.log);
$.post('http://10.8.1.28:8123/', 'insert into __temp values(1,2,3), (4,5,6), (7,8,9);', console.log);
$.post('http://10.8.1.28:8123/', 'select * from __temp FORMAT JSON;', console.log);
$.post('http://10.8.1.28:8123/', 'select * from dspm_warehouse.dw_site LIMIT 5 FORMAT JSON', console.log);


