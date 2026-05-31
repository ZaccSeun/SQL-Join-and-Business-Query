--select all the cleaned tables
select * from project.cust_info_cleaned;
select * from project.prd_info_cleaned;
select * from project.sales_details_cleaned;
select * from project.XX_CAT_G1V2_cleaned;
select * from project.LOC_A101_cleaned;
select * from project.CUST_AZ12_cleaned;

--Join table project.clean_cust_info and location table (clean_LOC_A101)
select
	c.cst_id,
	c.firstname,
	c.lastname,
	c.marital_status,
	c.customer_gender,
	c.cst_create_date,
	l.cntry
from project.cust_info_cleaned c
left join project.LOC_A101_cleaned l
on c.cst_key = l.cleaned_cid;
            
--store project.P_X_merged as view
create view project.C_L_merged as
select
	c.cst_id,
	c.firstname,
	c.lastname,
	c.marital_status,
	c.customer_gender,
	c.cst_create_date,
	l.cntry
from project.cust_info_cleaned c
left join project.LOC_A101_cleaned l
on c.cst_key = l.cleaned_cid;


--Join table project.prd_info_clean and (product details) XX_CAT_G1V2_cleaned
select
	p.prd_id,
	p.prd_key,
	p.prd_nm,
	p.pro_cost,
	p.prd_line,
	p.prd_start_dt,
	p.prd_end_date,
	x.cat,
	x.subcat,
	x.maintenance
from project.prd_info_cleaned p
left join project.XX_CAT_G1V2_cleaned x
on p.cat_id = x.id;

--store project.P_X_merged as view
create view project.P_X_merged as
select
	p.prd_id,
	p.prd_key,
	p.prd_nm,
	p.pro_cost,
	p.prd_line,
	p.prd_start_dt,
	p.prd_end_date,
	x.cat,
	x.subcat,
	x.maintenance
from project.prd_info_cleaned p
left join project.XX_CAT_G1V2_cleaned x
on p.cat_id = x.id;

--Join table project.sales_details_cleaned with project.C_L_merged and project.P_X_merged
select
	s.sls_ord_num,
	s.sls_order_dt,
	s.sls_ship_dt,
	s.sls_due_dt,
	s.sls_sales,
	s.sls_quantity,
	s.sls_price,
	c.firstname,
	c.lastname,
	c.marital_status,
	c.customer_gender,
	c.cst_create_date,
	c.cntry,
	p.prd_id,
	p.prd_nm,
	p.pro_cost,
	p.prd_line,
	p.prd_start_dt,
	p.prd_end_date,
	p.cat,
	p.subcat,
	p.maintenance
from project.sales_details_cleaned s
left join project.C_L_merged c
on s.sls_cust_id = c.cst_id
left join project.P_X_merged p
on s.sls_prd_key = p.prd_key;

--store the final (comprehensive) table as view
create view project.comprehensive_table as
select
	s.sls_ord_num,
	s.sls_order_dt,
	s.sls_ship_dt,
	s.sls_due_dt,
	s.sls_sales,
	s.sls_quantity,
	s.sls_price,
	c.firstname,
	c.lastname,
	c.marital_status,
	c.customer_gender,
	c.cst_create_date,
	c.cntry,
	p.prd_id,
	p.prd_nm,
	p.pro_cost,
	p.prd_line,
	p.prd_start_dt,
	p.prd_end_date,
	p.cat,
	p.subcat,
	p.maintenance
from project.sales_details_cleaned s
left join project.C_L_merged c
on s.sls_cust_id = c.cst_id
left join project.P_X_merged p
on s.sls_prd_key = p.prd_key;

--Generate top 20 customers based on total revenue and total quantity
select
	firstname,
	lastname,
	sum(sls_sales) as total_revenue,
	sum(sls_quantity) as total_quantity
from 
	project.comprehensive_table
group by 1,2
order by total_revenue desc
limit 20;

--Generate sales region with the top 20 customers
select 
	cntry,
	firstname,
	lastname,
	sum(sls_sales) as total_revenue
from project.comprehensive_table
group by 1,2,3
order by total_revenue desc
limit 20;

--Generate top 20 selling products based on total revenue and total quantity
select
	prd_nm,
	sum(sls_sales) as total_revenue,
	sum(sls_quantity) as total_quantity
from 
	project.comprehensive_table
group by 1
order by total_revenue desc
limit 20;

--Generate oversll best product category
select
	cat,
	sum(sls_sales) as total_revenue,
	sum(sls_quantity) as total_quantity
from 
	project.comprehensive_table
group by 1
order by total_revenue desc
limit 1;

select
	extract (year from sls_order_dt) as year,
	sum(sls_sales) as total_revenue,
	sum(sls_sales) - LAG(sum(sls_sales)) over (order by extract (year from sls_order_dt)) as YOY_Difference
from 
	project.comprehensive_table
group by 1
order by year, total_revenue;
