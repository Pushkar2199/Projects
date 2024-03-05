use fmgc_9;



/*	Metrics  */
select    
  concat( round(sum(quantity_sold_before_promo)/1000000,2) , ' M') as quantity_sold_before_promo , 
  concat( round(sum(quantity_sold_after_promo)/1000000,2) , ' M') as quantity_sold_after_promo , 
  concat(round(sum(revenue_before_promo)/1000000,2), ' M') as revenue_before_promo , 
  concat(round(sum(revenue_after_promo)/1000000,2), ' M') as revenue_after_promo , 
  concat(round(sum(isu)/1000000,2), ' M') as isu,
  concat(round(sum(ir)/1000000,2), ' M') as ir,
  round(sum(ir)*100/sum(revenue_before_promo),2) as ir_pct   , 
  round(sum(isu)*100/sum(quantity_sold_before_promo),2) as isu_pct
 from fact_events_new;
 
 
 
 /**----------------------------------Business Requests --------------------------------/

/*
1) 
Provide a list of products with a base price greater than $500 and that are 
featured in promo type of 'BOGOF' (Buy One Get One Free). This information 
will help us identify high-value products that are currently being heavily discounted, 
which can be useful for evaluating our pricing and promotion strategies.
*/


select   distinct product_name,  promo_type , base_price 
from  fact_events_new as fe
join dim_products as dp on dp.product_code = fe.product_code
where base_price >= 500   and promo_type = 'BOGOF'; 



/*  
2)  
Generate a report that provides an overview of the number of stores in each city.

The results will be sent in ascending order of store counts, allowing us to identify 
the cities with the highest store presence. The report includes two essential fields: 
city and store count, which will assist in optimizing our retail operations.
*/

select city , count(*) as stores 
from dim_stores
group by city  order by stores desc;



/*
3) 
Generate a report that displays each campaign along with 
the total revenue generated before and after the campaign.

The report includes three key fields:
campaign name
total revenue before promotion
total revenue after promotion
*/

select  dc.campaign_name,
	    concat(round(sum(revenue_before_promo)/1000000,2), ' M')  as revenue_before_promo , 
        concat(round(sum(revenue_after_promo)/1000000,2), ' M') as revenue_after_promo 
from fact_events_new as fe 
 join dim_campaigns as dc 
  on dc.campaign_id = fe.campaign_id
group by  dc.campaign_name
order by revenue_after_promo desc  ; 



/*
4) 
Produce a report that calculates the Incremental Sold Quantity (ISU%) for each
category during the Diwali campaign. Additionally, provide rankings for the
categories based on their ISU%. The report will include three key fields:
category, isu%, and rank order. 
*/ 


with
cte as ( 
select   dp.category,
		sum(isu) as isu , 
	    sum(quantity_sold_before_promo)  as quantity_sold_before_promo 
  from fact_events_new  as fe 
  join dim_products as dp on dp.product_code = fe.product_code
  join dim_campaigns as dc on dc.campaign_id = fe.campaign_id 
where campaign_name = 'Diwali' 
group by dp.category   ) 

select category , 
	   concat( round( (isu)*100/quantity_sold_before_promo ,2 ) , ' %') as ISU_pct , 
       rank() over (order by round( (isu)*100/quantity_sold_before_promo ,2 ) desc) as rnk
from cte 
order by rnk   
;



 /*
 5
 Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%),
 across all campaigns. The report will provide essential information including product name, 
 category, and IR%. This analysis helps identify the most successful products in terms of 
 incremental revenue across our campaigns, assisting in product optimization.
 */
 
 /*
 IR% = ((quantity_sold(after_promo) * base_price) - (quantity_sold(before_promo) * base_price)) / (quantity_sold(before_promo) * base_price) * 100
 */
 
WITH cte AS (
  SELECT   dm.campaign_name,  dp.category ,  dp.product_name,
         round(sum(ir)*100/sum(revenue_before_promo),2) as ir_pct,
         ROW_NUMBER() OVER ( partition by dm.campaign_name   order by  sum(ir)*100/sum(revenue_before_promo   ) desc )  AS rnk
  FROM fact_events_new AS fe
  JOIN dim_products AS dp ON dp.product_code = fe.product_code
  JOIN dim_campaigns AS dm ON dm.campaign_id = fe.campaign_id
  GROUP BY  dm.campaign_name ,  dp.category, dp.product_name
)
SELECT *
FROM cte
WHERE rnk <= 5  order by ir_pct desc ,  rnk  asc ;



 
WITH cte AS (
  SELECT   dp.category ,  dp.product_name,
         concat(round(sum(ir)*100/sum(revenue_before_promo),2), ' %') as ir_pct ,
		dense_rank() OVER (order by   sum(ir)*100/sum(revenue_before_promo    ) desc )  AS rnk
  FROM fact_events_new AS fe
  JOIN dim_products AS dp ON dp.product_code = fe.product_code
  JOIN dim_campaigns AS dm ON dm.campaign_id = fe.campaign_id
  GROUP BY    dp.category, dp.product_name
)
SELECT *
FROM cte
WHERE rnk <= 5  order by ir_pct desc ;







/*			--------- Recommended Insights -------------------		*/


/*         ---------Store Performance Analysis----------------      */

/*
1) Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?
*/


select  ds.city ,  fe.store_id  , concat(round(sum(ir)/1000000,2), ' M') as ir 
from fact_events_new as fe
join dim_stores as ds on ds.store_id = fe.store_id  
group by  ds.city, fe.store_id
order by ir desc limit 10 ;





/*
2) Which are the bottom 10 stores
   when it comes to Incremental Sold Units (ISU) during the promotional period?
*/

select   ds.city , fe.store_id , round(sum(isu),2) as isu 
from fact_events_new as fe 
join dim_stores as ds on ds.store_id = fe.store_id 
group by ds.city , fe.store_id 
order by isu asc limit 10 ; 






/*
3) How does the performance of stores vary by city? 
   Are there any common characteristics among the 
   top-performing stores that could be leveraged across other stores?
*/



SELECT 
    ds.city,
    fe.store_id,
    round(sum(isu),2) as isu ,
    concat(round(sum(revenue_before_promo)/1000000,2), ' M') as revenue_before_promo , 
    concat(round(sum(revenue_after_promo)/1000000,2), ' M') as revenue_after_promo , 
    concat(round(sum(ir)/1000000,2), ' M') as ir
FROM 
    fact_events_new fe
JOIN 
    dim_stores ds ON fe.store_id = ds.store_id
GROUP BY 
    ds.city, fe.store_id
      ;





/*		                	Promotion Type Analysis                        */

/*	
1) What are the top 2 promotion types that resulted in the highest Incremental Revenue?
*/


select promo_type,
	   concat(round(sum(ir)/1000000,2), ' M') as ir
from fact_events_new
group by promo_type 
order by ir desc   ;



/* 
2) What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?
*/

SELECT 
    promo_type, SUM(isu) AS isu
FROM
    fact_events_new AS fe
GROUP BY promo_type
ORDER BY isu ASC
; 
 
 
 
 
 
 /*
 3) Is there a significant difference in the performance of discount-based promotions versus BOGOF (Buy One Get One Free) or cashback promotions?
 */
 
SELECT promo_type,
	sum(isu) as isu,
	round(sum(isu)*100/sum(quantity_sold_before_promo),2) as isu_pct,
	concat(round(sum(ir)/1000000,2), ' M') as ir , 
	round(sum(ir)*100/sum(revenue_before_promo),2) as ir_pct 
FROM fact_events_new 
GROUP BY promo_type order by ir_pct desc   ;
 

 


/*
 4) Which promotions strike the best balance between Incremental Sold Units and maintaining healthy margins?
 */
 

 
 
 SELECT promo_type,
	sum(isu) as isu,
	round(sum(isu)*100/sum(quantity_sold_before_promo),2) as isu_pct,
	concat(round(sum(ir)/1000000,2), ' M') as ir , 
	round(sum(ir)*100/sum(revenue_before_promo),2) as ir_pct 
FROM fact_events_new
GROUP BY promo_type order by sum(ir) desc ;

 
 
 /*
-------------------------- Product and Category Analysis -----------------------------
*/


/*
1) which product categories saw the most significant lift in sales from the promotions ?
*/

select   dp.category , dp.product_name   ,
	   sum(quantity_sold_before_promo) as sales_before_promo ,
       sum(quantity_sold_after_promo) as sales_after_promo , 
       sum(isu) as isu 
from fact_events_new as fe 
join dim_products as dp on dp.product_code = fe.product_code 
group by dp.product_name  , dp.category
order by  isu desc ; 
 
 
/*
2)  Are there any products that respond expectionally well or poorly 
to promotions
*/ 
 
  select  product_name , 
 sum(quantity_sold_after_promo)  as quantity_sold_after_promo ,
 round(sum(isu)*100/sum(quantity_sold_before_promo),2) as isu_pct
 from fact_events_new as fe 
 join dim_products as dp  using (product_code) 
 group by dp.product_name 
 order by isu_pct desc 
; 
 
 
 
 
 select  product_name , 
 sum(quantity_sold_after_promo)  as quantity_sold_after_promo ,
 round(sum(isu)*100/sum(quantity_sold_before_promo),2) as isu_pct
 from fact_events_new as fe 
 join dim_products as dp  using (product_code) 
 group by dp.product_name 
 order by isu_pct desc limit 3
; 
 


 select  product_name , 
 sum(quantity_sold_after_promo)  as quantity_sold_after_promo ,
 round(sum(isu)*100/sum(quantity_sold_before_promo),2) as isu_pct
 from fact_events_new as fe 
 join dim_products as dp  using (product_code) 
 group by dp.product_name 
 order by isu_pct asc limit 3
; 
  
  
