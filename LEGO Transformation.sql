create or replace table "a_sets_bricks" as
with "inventories_last_versions" as (     -- we get only last versions of lego sets
        select * 
        from (
            select last_value("id") over (partition by "set_num" order by "version")    as "inventory_id"
                , "set_num"                                                             as "set_num"
            from "inventories" as T1
            order by "version" desc
            )
        group by 1, 2
        ),
"inventory_parts_corr" as (             -- table with LEGO parts arranged in schema for union
        select 
             T1."id"::int                                       as "inventory_id"
            , T1."set_num"::varchar                             as "set_num"
            , NULL::varchar                                     as "set_in_set_num"
            , T4."name"::varchar                                as "set_name"
            , T4."img_url"                                      as "set_img_url"
            , T4."year"::int                                    as "set_year"
            , nullif(T5."set_theme_group"::varchar, '')         as "theme_group"
            , nullif(T5."set_theme"::varchar, '')               as "theme"
            , nullif(T5."set_subtheme"::varchar, '')            as "sub_theme"
            , T3."part_num"::varchar                            as "part_num"
            , 'part'::varchar(255)                              as "part_category"
            , T3."img_url"                                      as "part_img_url"
            , T3."quantity"::int                                as "quantity"
            , T3."is_spare"::varchar                            as "is_spare"
            , T3."color_id"::int                                as "color_id"
        from "inventories" as T1
        join "inventories_last_versions" as T2          on T2."inventory_id" = T1."id"
        left join "inventory_parts" as T3               on T3."inventory_id" = T1."id"
        left join "sets" as T4                          on T4."set_num" = T1."set_num"
        left join "themes_prices" as T5                 on T5."set_id" = T1."set_num"
        where T3."inventory_id" is not null
          and T1."set_num" not like '%fig%'
          //and T3."is_spare" = 'f'
        ),
"inventory_parts_setsinsets" as (       -- table with LEGO parts from sets that are embeded in sets arranged in schema for union
        select 
            T0."inventory_id"::int                              as "inventory_id"
            , T2a."set_num"::varchar                            as "set_num"
            , T0."set_num"::varchar                             as "set_in_set_num"
            , T4."name"::varchar                                as "set_name"
            , T4."img_url"                                      as "set_img_url"
            , T4."year"::int                                    as "set_year"
            , nullif(T5."set_theme_group"::varchar, '')         as "theme_group"
            , nullif(T5."set_theme"::varchar, '')               as "theme"
            , nullif(T5."set_subtheme"::varchar, '')            as "sub_theme"
            , T3."part_num"::varchar                            as "part_num"
            , 'part'::varchar(255)                              as "part_category"
            , T3."img_url"                                      as "part_img_url"
            , T3."quantity"::int                                as "quantity"
            , T3."is_spare"::varchar                            as "is_spare"
            , T3."color_id"::int                                as "color_id"
        from "inventory_sets"  T0
        join "inventories_last_versions" as T1          on T1."inventory_id" = T0."inventory_id"
        left join "inventories" T2a                     on T2a."id" = T0."inventory_id"
        left join "inventories" T2b                     on T0."set_num" = T2b."set_num"
        left join "inventory_parts" T3                  on T3."inventory_id" = T2b."id"
        left join "sets" as T4                          on T4."set_num" = T2a."set_num"
        left join "themes_prices" as T5                 on T5."set_id" = T2a."set_num"
        where "part_num" is not null
        //and T3."is_spare" = 'f'
        ),
"inventory_minifigs_corr" as (                  -- table with LEGO minifigures arranged in schema for union
        select  
             T1."id"::int                                   as "inventory_id"
            , T1."set_num"::varchar                         as "set_num"
            , NULL::varchar                                 as "set_in_set_num"
            , T4."name"::varchar                            as "set_name"
            , T4."img_url"                                  as "set_img_url"
            , T4."year"::int                                as "set_year"
            , nullif(T5."set_theme_group"::varchar, '')     as "theme_group"
            , nullif(T5."set_theme"::varchar, '')           as "theme"
            , nullif(T5."set_subtheme"::varchar, '')        as "sub_theme"
            , T3."fig_num"::varchar                         as "part_num"
            , 'minifig'::varchar(255)                       as "part_category"
            , T6."img_url"                                  as "part_img_url"
            , T3."quantity"::int                            as "quantity"
            , NULL::varchar                                 as "is_spare"
            , NULL::int                                     as "color_id"
        from "inventories" as T1
        left join "inventories_last_versions" as T2             on T2."inventory_id" = T1."id"
        left join "inventory_minifigs" as T3                    on T1."id" = T3."inventory_id"
        left join "sets" as T4                                  on T1."set_num" = T4."set_num"
        left join "themes_prices" as T5                         on T5."set_id" = T1."set_num"
        left join "minifigs" as T6                              on T6."fig_num" = T3."fig_num"
        where T3."inventory_id" is not null
        ),
"inventory_minifigs_setsinsets" as (       -- table with LEGO minifigures from sets that are embeded in sets arranged in schema for union
        select 
            T0."inventory_id"::int                          as "inventory_id"
            , T2a."set_num"::varchar                        as "set_num"
            , T0."set_num"::varchar                         as "set_in_set_num"
            , T4."name"::varchar                            as "set_name"
            , T4."img_url"                                  as "set_img_url"
            , T4."year"::int                                as "set_year"
            , nullif(T5."set_theme_group"::varchar, '')     as "theme_group"
            , nullif(T5."set_theme"::varchar, '')           as "theme"
            , nullif(T5."set_subtheme"::varchar, '')        as "sub_theme"
            , T3."fig_num"::varchar                         as "part_num"
            , 'minifig'::varchar(255)                       as "part_category"
            , T6."img_url"                                  as "part_img_url"
            , T3."quantity"::int                            as "quantity"
            , NULL::varchar                                 as "is_spare"
            , NULL::int                                     as "color_id"
        from "inventory_sets"  T0
        join "inventories_last_versions" as T1      on T1."inventory_id" = T0."inventory_id"
        left join "inventories" T2a                 on T2a."id" = T0."inventory_id"
        left join "inventories" T2b                 on T0."set_num" = T2b."set_num"
        left join "inventory_minifigs" as T3        on T3."inventory_id" = T2b."id"
        left join "sets" as T4                      on T2a."set_num" = T4."set_num"
        left join "themes_prices" as T5             on T5."set_id" = T2a."set_num"
        left join "minifigs" as T6                  on T6."fig_num" = T3."fig_num"
        where T3."fig_num" is not null
        ),
"inventory_parts_all" as (      -- union of 4 tables with LEGO parts and minifigures
        select "inventory_id", "set_num", "set_in_set_num", "set_name", "set_img_url", "theme_group", "theme", "sub_theme", "part_num", "part_category", "part_img_url", "quantity", "is_spare", "color_id"::int as     "color_id", "set_year"
        from "inventory_parts_corr"
        UNION ALL
        select "inventory_id", "set_num", "set_in_set_num", "set_name", "set_img_url", "theme_group", "theme", "sub_theme", "part_num", "part_category", "part_img_url", "quantity", "is_spare", "color_id"::int as "color_id", "set_year"
        from "inventory_parts_setsinsets"
        UNION ALL
        select "inventory_id", "set_num", "set_in_set_num", "set_name", "set_img_url", "theme_group", "theme", "sub_theme", "part_num", "part_category", "part_img_url", "quantity", "is_spare", "color_id"::int as "color_id", "set_year"
        from "inventory_minifigs_corr"
        UNION ALL
        select "inventory_id", "set_num", "set_in_set_num", "set_name", "set_img_url", "theme_group", "theme", "sub_theme", "part_num", "part_category", "part_img_url", "quantity", "is_spare", "color_id"::int as "color_id", "set_year"
        from "inventory_minifigs_setsinsets"
        ),
"theme_group_calculations" as (         -- join table with prices and calculations created
        select "set_id"
            , nullif("retail_price", '')                as "retail_price2"
            , nullif("bl_offer_avgprice_new", '')       as "offer_price_new"
            , nullif("bl_offer_avgprice_used", '')      as "offer_price_used"
            , nullif("bl_sold_avgprice_new", '')        as "sold_price_new"
            , nullif("bl_sold_avgprice_used", '')       as "sold_price_used"
            , "sold_price_new" - "offer_price_new"      as "profit_new"
            , "sold_price_used" - "offer_price_used"    as "profit_used"
            , "sold_price_new" - "retail_price2"        as "price_difference_new"
            , "sold_price_used" - "retail_price2"       as "price_difference_used"
            , case
                when "set_id" in (
                            select "set_num" 
                            from "inventory_parts_all" 
                            group by 1 
                            having count_if("part_category" = 'minifig') > 0  
                              and count_if("part_category" = 'minifig') >= count_if("part_category" = 'part')
                            ) 
                              or "set_theme" = 'Collectable Minifigures' then 'minifig_set'
                else 'set'
                end as "set_categories"   -- tag for LEGO sets that have only minifigures in the package
        from "themes_prices" 
        where 1=1
          and "set_id" in (select distinct "set_num" from "sets")
        )
        
select T1.*
    , coalesce(T2."name", T3."name")        as "part_name"
    , T2."part_material"                    as "part_material"
    , T4."name"                             as "color_name"
    , T4."rgb"                              as "color_rgb"
    , T4."is_trans"                         as "color_transparent"
    , T4."color_category"                   as "color_category"
    , T5."retail_price2"                    as "retail_price"
    , T5."offer_price_new"
    , T5."offer_price_used"
    , T5."sold_price_new"
    , T5."sold_price_used"
    , T5."profit_new"
    , T5."profit_used"
    , T5."price_difference_new"
    , T5."price_difference_used"
    , T5."set_categories"
from "inventory_parts_all" as T1
left join "parts" as T2                     on T1."part_num" = T2."part_num"
left join "minifigs" as T3                  on T1."part_num" = T3."fig_num"
left join "colors_updated" as T4            on T1."color_id" = T4."id"
left join "theme_group_calculations" as T5  on T1."set_num" = T5."set_id"
;
