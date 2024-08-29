SELECT * FROM 
"pathology-data-mining.master_slide_inventory.intermediate"."all_slides_etl" as slide_etl
INNER JOIN
"pathology-data-mining.master_slide_inventory.intermediate"."hobbit_case_breakdown" as hobbit_data
ON 
slide_etl.id = hobbit_data.image_id