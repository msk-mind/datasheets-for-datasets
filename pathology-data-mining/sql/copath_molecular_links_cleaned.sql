WITH
  t1 AS ( -- filter out rows not containing bracketed portion with structured data. these rows are typically bone marrow and normal blood samples  
SELECT 
specnum_formatted, 
part_inst, 
part_type, 
part_description, 
REGEXP_LIKE(TRIM(part_description), '.*\(\s*C\d+|S\d+|MSKS:|MKS:|MS|ms|Outside:.+\)$') as bool 
FROM "hobbit-poc"."molecular_cases" WHERE bool
  ),
  t2 AS (
      SELECT -- split free text from bracketed portion into separate array elements
specnum_formatted, 
part_inst, 
part_description,
regexp_split(part_description, '\(\s*C\d+|S\d+|MSKS:|MKS:|MS|ms|Outside', 'FIRST', -1) AS structured_data
FROM t1
  ),
  t3 AS ( 
      SELECT 
      specnum_formatted, 
      part_inst, 
      part_description,
      ARRAY_TO_STRING(SUBLIST(structured_data, 1, 1),',')as free_text_portion,
      ARRAY_TO_STRING(SUBLIST(structured_data, 2, 1),',') as structured_portion  
      FROM t2
  )
  SELECT * FROM t3 
