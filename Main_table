-- construction of a main table with adjustments
create or replace table "a_job_postings" as 
select 
"JP"."job_posting_id" :: int as "job_posting_id",
nullif("JP"."name", '') as "name",
case 
    when "JP"."name" ilike '%data center%' then 1 
    when "JP"."name" ilike '%data centre%' then 1
    when "JP"."name" ilike '%datacentre%' then 1
    else 0
    end "exceptions",
case
    when "exceptions" = 1 then null
    when "JP"."name" ilike '%data%' or "JP"."name" ilike '%analys%' then 1
    else 0
    end "data_analyst_job",
case
    when "JP"."name" ilike '%junior%' or "JP"."name" ilike '%graduat%' then 1
    else 0
    end "junior_positions",
"JP"."company_id" :: int as "company_id",
"Com"."name" as "Company_name",
nullif("JP"."source", '') as "source", 
case 
    when "JP"."source" = 'linkedin_ie' then 'linkedin'
    when "JP"."source" = 'monster_ie' then 'monster'
    when "JP"."source" = 'monster2_ie' then 'monster'
    when "JP"."source" = 'indeed_ie' then 'indeed'
    when "JP"."source" = 'simplyhired_ie' then 'simplyhired'
    when "JP"."source" = 'glassdoor_ie' then 'glassdoor'    
    end "not_null_source",
case 
    when "not_null_source" = 'linkedin' then 'linkedin'
    when "not_null_source" = 'monster' then 'monster'
    when "not_null_source" = 'simplyhired' then 'simplyhired'
    end "da_source",
nullif("JP"."city", '') as "city",
"JP"."date_created" :: timestamp as "posting_created_timestamp",
"posting_created_timestamp" :: date as "posting_created_date",
nullif("JP"."salary_min" :: string, ''):: number(38, 2) as "salary_lower_bound",
nullif("JP"."salary_max" :: string, ''):: number(38, 2) as "salary_upper_bound",
nullif("JP"."salary_currency", '') as "salary_currency",
nullif("JP"."salary_period", '') as "salary_period",
case
    when "JP"."salary_period" = 'year' then "salary_lower_bound"
    when "JP"."salary_period" = 'month' then ("salary_lower_bound" * 12) :: number(38, 2)
    when "JP"."salary_period" = 'week' then ("salary_lower_bound" * 50) :: number(38, 2)
    when "JP"."salary_period" = 'day' then ("salary_lower_bound" * 260) :: number(38, 2)
    when "JP"."salary_period" = 'hour' then ("salary_lower_bound" * 2080) :: number(38, 2)
    end "salary_lower_bound_year",
case
    when "JP"."salary_period" = 'year' then "salary_upper_bound"
    when "JP"."salary_period" = 'month' then ("salary_upper_bound" * 12) :: number(38, 2)
    when "JP"."salary_period" = 'week' then ("salary_upper_bound" * 50) :: number(38, 2)
    when "JP"."salary_period" = 'day' then ("salary_upper_bound" * 260) :: number(38, 2)
    when "JP"."salary_period" = 'hour' then ("salary_upper_bound" * 2080) :: number(38, 2)    
    end "salary_upper_bound_year",
case
    when "salary_currency" = 'EUR' then "salary_lower_bound_year"
    else ("salary_lower_bound_year" / "rate") :: number(38, 2)
end "salary_lower_bound_year_EUR",
case
    when "salary_currency" = 'EUR' then "salary_upper_bound_year"
    else ("salary_upper_bound_year" / "rate") :: number(38, 2)
end "salary_upper_bound_year_EUR"
from "job_postings" as "JP"
join "a_companies" as "Com"
on "Com"."company_id" = "JP"."company_id"
left join "rates" as "R"
on "R"."date" = "posting_created_date" and "R"."toCurrency" = nullif("JP"."salary_currency", '')
;
