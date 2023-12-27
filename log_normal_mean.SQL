

#########################
#### example_ln_mean ####
#########################

-- https://jse.amstat.org/v13n1/olsson.html


WITH test_cte as ( 
Select 
    2.02 * SQRT((1.01/40)
                + (power(1.01, 2) / (2*(40-1)))
                  ) as interval
    ,(5.127 + (1.01 / 2)) -     2.02 * SQRT((1.01/40)
                                        + (power(1.01, 2) / (2*(40-1)))
                                        ) as lower_bound_ln
    ,(5.127 + (1.01 / 2)) +     2.02 * SQRT((1.01/40)
                                        + (power(1.01, 2) / (2*(40-1)))
                                        ) as upper_bound_ln  
)  

Select 
     exp(5.127 + (1.01/2) ) as mean 
    ,exp(lower_bound_ln) as lower_bound
    ,exp(upper_bound_ln) as upper_bound
    from test_cte


Select 914.9 as example_data
Union 
Select 1568.3
Union 
Select 50.5
Union 
Select 94.1
Union 
Select 199.5
Union 
Select 23.8
Union 
Select 70.5
Union 
Select 213.1
Union 
Select 44.1
Union 
Select 331.7
Union 
Select 139.3
Union 
Select 115.6
Union 
Select 38.4
Union 
Select 357.1
Union 
Select 725.9
Union 
Select 253.2
Union 
Select 905.6
Union 
Select 155.4
Union 
Select 138.1
Union 
Select 95.2
Union 
Select 75.2
Union 
Select 275.0
Union 
Select 401.1
Union 
Select 653.8
Union 
Select 390.8
Union 
Select 483.5
Union 
Select 62.6
Union 
Select 128.5
Union 
Select 81.5
Union 
Select 218.5
Union 
Select 308.2
Union 
Select 41.2
Union 
Select 60.3
Union 
Select 506.9
Union 
Select 221.8
Union 
Select 112.5
Union 
Select 93.7
Union 
Select 199.3
Union 
Select 210.6
Union 
Select 39.2



-- prep_cte
-- WITH prep_cte as ( 
Select 
     avg(example_data) as avg_example_data,
     STDDEV(example_data) as stddev_example_data,

     avg(ln(example_data)) as avg_log_example_data,
     STDDEV(ln(example_data)) as sd_log_example_data,

    exp(avg(ln(example_data))) as geo_mean

    -- ,POWER(avg(ln(example_data)), 2) as sigma_sqrd
    ,count(example_data) as sample_size 
    From example_data_cte
-- )



-- normal_mean_and_CIs
-- since max_event_num is more log normal, this is a bad expected value 
 Select 
      avg_example_data
     ,avg_example_data - (1.96 * SQRT(POWER(stddev_example_data, 2) / sample_size)) as lower_bound 
     ,avg_example_data + (1.96 * SQRT(POWER(stddev_example_data, 2) / sample_size)) as upper_bound 
     ,1.96 * SQRT(POWER(stddev_example_data, 2) / sample_size) as confid_interval
     From prep_cte


naive_method_geo_mean
Select 
     exp(avg_log_example_data) as geo_mean,
     exp(avg_log_example_data - (2.02 * SQRT((1.010 / sample_size)))) as lower_bound,
     exp(avg_log_example_data + (2.02 * SQRT((1.010 / sample_size)))) as upper_bound
    From prep_cte


-- Cox_Method
WITH test_cte_n as ( 
Select 
     avg_log_example_data
    ,sd_log_example_data
    ,1.96 * SQRT((sd_log_example_data / sample_size)
                + (power(sd_log_example_data, 2) / (2*(sample_size-1)))
                  ) as interval

--NOTE: there is an error in the example with 1.010 used for the lg standard deviation so my use of the variable is a bit off. the actual sd in the example is 1.004
--      this is shown correctly in the table at the top, maybe the same dataset was changed a bit? 
    ,(avg_log_example_data + (sd_log_example_data / 2)) - 1.96 * SQRT((sd_log_example_data / sample_size)
                                        + (power(sd_log_example_data, 2) / (2*(sample_size-1)))
                                        ) as lower_bound_ln

    ,(avg_log_example_data + (sd_log_example_data / 2)) + 1.96 * SQRT((sd_log_example_data / sample_size)
                                        + (power(sd_log_example_data, 2) / (2*(sample_size-1)))
                                        ) as upper_bound_ln  
    From prep_cte
) 

Select 
     exp(avg_log_example_data + (sd_log_example_data / 2) ) as mean 
    ,exp(lower_bound_ln) as lower_bound
    ,exp(upper_bound_ln) as upper_bound
    from test_cte_n









