
################################
########### Box Plot ###########
################################

# NOTE: the output values are labled for Daiquery's data explorer 

WITH prep as ( 
Select 
    ds,
    year(cast(ds as date)) as year,
    month(cast(ds as date)) as month,
    __metric__ as metric 
    From __table__
) 

, prep_2 as ( 
Select 
    CAST(year as VARCHAR) year,
    metric,
    NTILE(4) OVER (PARTITION BY CAST(year as VARCHAR) 
                   ORDER BY metric) AS Quartile
    From prep 
) 

Select 
    year, 
	MIN(metric) as min,
	MAX(CASE WHEN Quartile = 1 THEN metric END) as lower_quartile,
	MAX(CASE WHEN Quartile = 2 THEN metric END) as median,
	MAX(CASE WHEN Quartile = 3 THEN metric END) as upper_quartile,
	MAX(metric) as max
    From prep_2
Group by 1
order by 1


--in Presto APPROX_PERCENTILE allows a easier approach 
 APPROX_PERCENTILE(metric, .1) as first_decile
,APPROX_PERCENTILE(metric, .25) as first_quartile
,APPROX_PERCENTILE(metric, .5) as median
,APPROX_PERCENTILE(metric, .75) as third_quartile 
,APPROX_PERCENTILE(metric, .9) as ninth_decile 
,APPROX_PERCENTILE(metric, .97) as ninty_seventh_percentile


######################################
##### Mean & Confidence Interval #####
######################################

# NOTE: the output values for standard error upper and lower are labeled for Daiquery's data explorer    

# Z values: 1.65 for 90%, 1.96 for 95%, 2.33 for 98% and 2.58 for 99%  

# avg + 1.96 * (sd / SQRT(sample_size)) AS Confidence_Interval_95_perc

WITH cte as ( 
Select 
    condition, 
    avg(metric) avg,
    STDDEV(metric) sd,
    count(*) sample_size
    From atpt_question_case_per_1K_FTE 
group by 1 
) 

, cte2 as ( 
Select 
    *,     
    avg + 1.96 * (sd / SQRT(sample_size)) AS Confidence_Interval_95_perc
    from cte 
) 

Select 
    condition, 
    round(avg, 2) as avg_atpt_question_cases_per_1K_FTE, 
    round(avg - Confidence_Interval_95_perc, 2) as Lower_Confidence_Interval_95_perc, 
    round(avg + Confidence_Interval_95_perc, 2) as Upper_Confidence_Interval_95_perc
    From cte2 


-- binomial 
With prep as ( 
select
    app_name, 
    sum(tag_case_count) as sub_total, 
    sum(time_away_content_impression_count) as n, 
    1. * sum(tag_case_count)  / sum(time_away_content_impression_count) as p
from time_away_case_rate_daily_trend 
group by 1 
) 

, prep_2 as ( 
Select 
    *,
    sqrt(p * (1 - p) / n) as binomial_se
    From prep
) 

Select 
    app_name, 
    round(p, 2) as avg_time_away_case_rate, 
    round(p - binomial_se * 1.96, 2) as _lower_err,
    round(p + binomial_se * 1.96, 2) as _upper_err,
    binomial_se * 1.96 as CI, 
    binomial_se
    From prep_2


#################################
##### Mean & Standard Error #####
################################# 

With prep as ( 
Select 
    ds, 
    avg(__metric__) avg_metric,
    STDDEV(__metric__) sd_metric,
    count(*) sample_size 
    From __table__
group by 1     
) 

, prep_2 as ( 
Select 
    *,
    ROUND(sd_metric / SQRT(sample_size), 2) AS standard_error    
    From prep
) 

Select 
    ds, 
    round(avg_metric,2) as avg_page_load_time, 
    round(avg_metric - standard_error,2) as _lower_err,
    round(avg_metric + standard_error,2) as _upper_err
    From prep_2


-- Alternative method
Select 
    app_name, 
    avg(metric) avg,
    STDDEV(metric) sd,
    sqrt(percentage * (1 - percentage)/ total) as se, 
    count(*) sample_size,
    From table  
group by 1 


################################
#### Median with MAD Errors ####
################################

# MAD is median absolute difference

# NOTE: the inputs are a table with a grouping variable(s) and a metric variable 
# referring to the metric variable as __raw_metric__ 

# NOTE: the output values for standard error upper and lower are labeled for Daiquery's data explorer 

# NOTE: this example uses two grouping variables. For example one could be date and the seocnd could be region.
#       at the end the final query removes that more grnaular groupiing varable to report a higher level summary metric. 

WITH prep as ( 
Select 
    __grouping_var__1, 
    __grouping_var__2,     
    APPROX_PERCENTILE(__metric__, 0.5) as median_metric
    From __table__
group by 1,2
)

,prep_2 AS (
    SELECT
        __grouping_var__1, 
        __grouping_var__2,  
        median_metric,
        APPROX_PERCENTILE(ABS(__raw_metric__  - median_metric), 0.5) median_absolute_difference
    FROM __table__ a 
    LEFT JOIN prep b 
        on a.__grouping_var__ = b.__grouping_var__
    GROUP BY 1,2,3 
)    

SELECT
    __grouping_var__2, 
    round(median_metric,2) as __median_metric__,
    round(median_metric - median_absolute_difference,2) AS _lower_err,
    round(median_metric + median_absolute_difference,2) AS _upper_err
FROM prep_2
ORDER BY  1


##########################################
#### Geomean and Confidence Intervals ####
##########################################




#################################
#### Cumulative Sum Percent ####
#################################

WITH prep AS (
SELECT
    case_sfid,
    employee_id,
    case_created_date,
    case_closed_date,
    ays_to_close
FROM table
)

,prep_2 AS (
    SELECT
        days_to_close,
        COUNT(DISTINCT case_sfid) AS case_count
    FROM prep
    GROUP BY 1
)

, prep_3 as ( 
SELECT
    *,
    SUM(case_count) OVER(ORDER BY days_to_close ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumulative_case_count,
    SUM(case_count) OVER() AS total_case_count
FROM prep_2
) 

Select 
    days_to_close,
    ROUND(1. * cumulative_case_count / total_case_count, 3) as cumulative_percent 
    from prep_3 
    Where days_to_close IS NOT NULL -- there is one NULL



################################
#### unnest an orderedarray ####
################################

SELECT
    ds,
    nested_field AS pp_urls_visited_list 
FROM table a
CROSS JOIN UNNEST(a.nested_field)
    WITH ORDINALITY AS b (pp_url, visit_order)
ORDER BY 1,2     

