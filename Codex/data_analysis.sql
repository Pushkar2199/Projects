use codex;

-- 1. Demographic Insights (examples)

/* a. Who prefers energy drink more? (male/female/non-binary? */

select Gender,count(dim_repondents.Gender) as count from dim_repondents 
group by dim_repondents.Gender order by count desc; 


/* b. Which age group prefers energy drinks more?  */

select age, count(age) as total_respondent from dim_repondents
group by dim_repondents.Age order by Age ;


/* 3 Which type of marketing reaches the most Youth (15-30)? */

select fsr.Marketing_channels ,count(dr.Age) as count from fact_survey_responses as fsr
join dim_repondents as dr on fsr.Respondent_ID = dr.Respondent_ID 
where Age in  ('15-18', '19-30')
group by Marketing_channels 
order by count desc;



-- 2. Consumer Preferences:

/* a. What are the preferred ingredients of energy drinks among respondents*/

select fsr.Ingredients_expected , count(fsr.Ingredients_expected) as prefered_count from  fact_survey_responses as fsr
group by fsr.Ingredients_expected order by  prefered_count desc ;


/* b. What packaging preferences do respondents have for energy drinks?   */

select Packaging_preference , count(Packaging_preference) as  preference_count from fact_survey_responses
group by Packaging_preference order by  preference_count desc;



-- 3. Competition Analysis

/* a. Who are the current market leaders? */

select Current_brands , count(Current_brands) as reach  from fact_survey_responses
group by Current_brands order by reach desc;




/* b. What are the primary reasons consumers prefer those brands over ours */

select Reasons_for_choosing_brands , count(Reasons_for_choosing_brands) as count from fact_survey_responses
group by Reasons_for_choosing_brands order by count desc ;



--   leader in brand reputation 
SELECT Current_brands, Reasons_for_choosing_brands, count
FROM (
    SELECT Current_brands, Reasons_for_choosing_brands, COUNT(*) AS count,
           ROW_NUMBER() OVER (PARTITION BY Current_brands ORDER BY COUNT(*) DESC) AS rn
    FROM fact_survey_responses
    GROUP BY Current_brands, Reasons_for_choosing_brands
) AS subquery
WHERE rn = 1
ORDER BY count DESC;




-- 4. Marketing Channels and Brand Awareness


/* a. Which marketing channel can be used to reach more customers?  */

select fsr.Marketing_channels ,count(fsr.Heard_before) as reach from fact_survey_responses as fsr 
group by fsr.Marketing_channels 
order by reach desc;



/* b. How effective are different marketing strategies and channels in reaching our customers? */

select fsr.Marketing_channels ,  fsr.Current_brands ,count(fsr.Heard_before) as reach from fact_survey_responses as fsr 
where  Current_brands = 'CodeX' 
group by fsr.Marketing_channels ,Current_brands
order by reach desc;



-- 5. Brand Penetration:

/* 	a. What do people think about our brand? (overall rating) */

select Brand_perception , count(Brand_perception) as count from fact_survey_responses 
where Current_brands  = 'CodeX'
group by Brand_perception order by count desc ;


-- general perception
select General_perception , count(General_perception) as count from fact_survey_responses 
where Current_brands  = 'CodeX' 
group by General_perception order by count desc ;






/* b. Which cities do we need to focus more on? */



select dc.City, dc.Tier,count(fsr.Heard_before) as heard_count   from dim_cities  as dc
join  dim_repondents  as dr  on dc.City_ID   =  dr.City_ID
join  fact_survey_responses as fsr on dr.Respondent_ID = fsr.Respondent_ID
group by City ,Tier order by heard_count desc  ;



# unaware
select dc.City, dc.Tier,count(fsr.Heard_before) as unaware from dim_cities  as dc
join  dim_repondents  as dr  on dc.City_ID   =  dr.City_ID
join  fact_survey_responses as fsr on dr.Respondent_ID = fsr.Respondent_ID
where Heard_before = "No"
group by City ,Tier order by unaware desc  ;





-- 6. Purchase Behavior:

/* 	a. Where do respondents prefer to purchase energy drinks? */

select Purchase_location , count(Purchase_location) as count  from fact_survey_responses
group by Purchase_location ;


/*  b. What are the typical consumption situations for energy drinks among  respondents? */

select Typical_consumption_situations , count(Typical_consumption_situations) as count from fact_survey_responses
group by Typical_consumption_situations order by count desc ;


/*  c. What factors influence respondents' purchase decisions, such as price range and limited edition packaging?    */

-- limited edition packaging
select Limited_edition_packaging ,count(Limited_edition_packaging) as l_count from fact_survey_responses
group by Limited_edition_packaging order by l_count desc ;

-- price range
select Price_range,count(Price_range) as count from fact_survey_responses
group by Price_range order by count desc ;



-- 7. Product Development

/*   a. Which area of business should we focus more on our product development?  (Branding/taste/availability)   */

-- taste experience
select Taste_experience , count(Taste_experience)  as count from fact_survey_responses
where Current_brands  = 'CodeX'
group by Taste_experience order by count desc ;


-- 

select Reasons_for_choosing_brands , count(Reasons_for_choosing_brands)  as count from fact_survey_responses
where Current_brands  = 'CodeX'
group by Reasons_for_choosing_brands order by count desc ;




-- taste

SELECT Current_brands, Reasons_for_choosing_brands, count
FROM (
    SELECT Current_brands, Reasons_for_choosing_brands, COUNT(*) AS count,
           ROW_NUMBER() OVER (PARTITION BY Current_brands ORDER BY COUNT(*) DESC) AS rn
    FROM fact_survey_responses
    GROUP BY Current_brands, Reasons_for_choosing_brands
) AS subquery
WHERE rn = 2
ORDER BY count DESC;




select Current_brands, Reasons_for_choosing_brands, COUNT(*) AS count from fact_survey_responses
GROUP BY Current_brands , Reasons_for_choosing_brands;



-- taste  ranking 
select Current_brands, Reasons_for_choosing_brands, COUNT(*) AS count from fact_survey_responses
where Reasons_for_choosing_brands = 'Taste/flavor preference'
GROUP BY Current_brands;


-- 'Availability'
select Current_brands, Reasons_for_choosing_brands, COUNT(*) AS count from fact_survey_responses
where Reasons_for_choosing_brands = 'Availability'
GROUP BY Current_brands order by count desc;




