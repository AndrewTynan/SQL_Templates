
# calcs 
SUM(IF(id_count > 0 and total_session_seconds > 1, 1, 0)) as Meaningul_Sessions 

COUNT(DISTINCT cast(session_id as VARCHAR) || cast(emp_id as VARCHAR)) as Total_Sessions

COUNT_IF(next_cms_id IS NULL) AS navigation_end,

1.0 * COUNT_IF(next_cms_id IS NULL) / COUNT(*) as 

ROUND(metric * 1000.00 / population, 2) AS meric_per_1K_population 

ROUND(SUM(sess_count) * 100.00 / SUM(text_input_session_count), 2)  AS session_case_creation_pct      

AVG(CASE WHEN score = 5 THEN 1 WHEN score = 1 THEN 0 END) avg_score,

(SUM(metric) FILTER(WHERE field = 'true')) * 1.0  / (SUM(metric) FILTER(WHERE field_2 = 'value' AND field_3 = 'Urgent')) AS rate

MIN_BY(ts)   

ROUND(1. * SUM(IF(case_count > 1, case_count - 1, 0)) / SUM(case_count), 2) AS duplicate_same_case_type_case_percent,

round(1. * count / sum(count) over(), 3) as perc
round(1. * user_count / sum(user_count) over(PARTITION BY mins_since_session_start), 3) as perc 

avg(metric) - stddev(metric) as _lower_err
avg(metric) + stddev(metric) as _upper_err

sum(session_duration_seconds) / 60 as agent_minutes_worked 

APPROX_PERCENTILE(agent_minutes_worked , 0.5) as median,

(1. * total_employee_count / 1000) as fte_thousands,
fte_hourly_cost_lower * (1. * total_employee_count / 1000) * daily_sst_hours_per_1k_fte as lower_cost_daily,   



# window funcs 
100.0 * rating_count / sum(rating_count) over(PARTITION BY ds) as daily_total_rating_perc 

sum(perc) OVER(ORDER BY ssesion_minute_diff) as cumsum_perc  

SUM(atpt_question_case_count) OVER (ORDER BY a.ds rows 
                                    BETWEEN 6 PRECEDING AND CURRENT ROW
                                    ) AS atpt_case_l7

lag(session_start) OVER(PARTITION BY ds, id 
                        ORDER BY     session_start) prior_session_start, 

LEAD(TRY_CAST(JSON_EXTRACT_SCALAR(payload, '$.key') AS BIGINT)) OVER (PARTITION BY session_id
                                                                      ORDER BY ts
                                                                      ) AS next_id 

ROW_NUMBER() OVER(PARTITION BY a.ds, a.employee_id            
                  ORDER BY     session_start) session_number,   


# dates 
DOW(date(ds)) IN (1,2) -- Monday and Tuesday 
month(date(ds)) = 6 
year(date(ds)) IN (2022, 2023)            
DOW(date(ds)) IN (1,2) -- Monday and 

FROM_UNIXTIME(ts) AS event_time,

lower(date_format(date(a.status_date), '%W')) 

date_diff('minute', dt, dt_next) as ssesion_minute_diff 

date_format(date(ds), '%M') month, 
date_format(date(ds), '%W') weekday_name, 

CAST(DATE(FROM_UNIXTIME(ts)) AS VARCHAR) >= '2023-02-01'


# case when  
case when date(min(FROM_UNIXTIME(ts))) != date(max(FROM_UNIXTIME(ts))) then 'mismatch' 
     when date(min(FROM_UNIXTIME(ts))) =  date(max(FROM_UNIXTIME(ts))) then 'match'
     else 'other'
     end date_match 


# strings 
CAST(YEAR(CAST(ds AS DATE)) AS VARCHAR) || '-' || CAST(WEEK(CAST(ds AS DATE)) AS VARCHAR) AS YEAR_WEEK,

REGEXP_LIKE(JSON_EXTRACT_SCALAR(payload, '$.path'), 'string')

replace(field, '\n') 
replace(field, '.') 

split_part(field,':',1)

ANY_MATCH(to_email, e -> e LIKE '%string%') 


ELEMENT_AT(SPLIT(url_field, '/'), 4) AS L1,
ELEMENT_AT(SPLIT(url_field, '/'), 5) AS L2,

TRY_CAST(JSON_EXTRACT_SCALAR(payload, '$.key') AS BIGINT) AS cms_id,

substr(subpath, 1) 

,substr(subpath, 
         (strpos(subpath, '/', 1) + 1),  --start 
         (strpos(subpath, '/', 2) - (strpos(subpath, '/', 1) + 1)) --length 
         ) 

substr(substr(JSON_EXTRACT_SCALAR(payload, '$.subpath'), 1, strpos(JSON_EXTRACT_SCALAR(payload, '$.subpath'), '/')),
        1,
        length(substr(JSON_EXTRACT_SCALAR(payload, '$.subpath'), 1, strpos(JSON_EXTRACT_SCALAR(payload, '$.subpath'), '/')))-1) as url_root 

SUBSTR((SUBSTR(content, STRPOS(content, 'question="') + 10)), 1,
        STRPOS((SUBSTR(content, STRPOS(content, 'question="') + 10)), '">') - 1)    

LENGTH(RTRIM(LTRIM(REPLACE(string,'  ', ' ')))) - LENGTH(REPLACE(RTRIM(LTRIM(REPLACE(string, '  ', ' '))), ' ', '')) + 1 AS word_count_old 

URL_EXTRACT_PATH(JSON_EXTRACT_SCALAR(payload, '$.path')) LIKE '%string%'))

CARDINALITY(REGEXP_EXTRACT_ALL(JSON_EXTRACT_SCALAR(payload, '$.path'), '/'))
CARDINALITY(REGEXP_EXTRACT_ALL(JSON_EXTRACT_SCALAR(payload, '$.subpath'), '/'))
CARDINALITY(REGEXP_SPLIT(TRIM(people_portal_body), '\s+')) AS word_count

TRY_CAST(JSON_EXTRACT_SCALAR(payload, '$.key') AS BIGINT) 
TRIM(JSON_EXTRACT_SCALAR(payload, '$.subpath'), '/') AS subpath

