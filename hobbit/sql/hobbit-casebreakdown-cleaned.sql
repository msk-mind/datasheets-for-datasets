-- This assumes that if two rows have the same image_id but different values in any other column, those rows and those image_ids are garbage and are being discarded
-- For example there can be two rows with the only difference being stain_type 
select * from (select DISTINCT * from "hobbit-poc"."case_breakdown") where image_id not in 
 (select image_id from (select DISTINCT * from "hobbit-poc"."case_breakdown") GROUP BY image_id having count(image_id) <> 1)