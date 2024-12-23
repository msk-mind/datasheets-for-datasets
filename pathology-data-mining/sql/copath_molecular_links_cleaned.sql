WITH
  t1 as 
  ( -- Filter out rows not containing structured data. This is split into two steps. 
    -- First, check to see if there are matches on keywords inside parenthases 
    -- that indicate precense of a valid accession
        select 
        specnum_formatted,
        part_type, 
        part_description, 
        REGEXP_extract(part_description, '.*\(\s*InternalVal|InternalVal|ExternalVal|Outisde|Oustide|Outside|MSK: MSK: |MSKp:|MSK;|MSK:|MSKS|MKS|MSK:MSK|MSK|MSk|msk|MS|MS|MS.+\)$', 0) as matched
        from "hobbit-poc"."molecular_cases"
  ),
  t2a as 
  ( -- If there is not a match on one of the the primary keywords, then check to see if there is
    -- still an accession present that doesn't have a valid prefix
        select specnum_formatted, part_type, part_description, matched, 
        REGEXP_extract(part_description,  '.*\(\s*MS|C\d+|S\d+|M\d+|CD\d+|NY\d+|A\d+|80\-|MS.+\)$', 0) as _t2a_matched,
        REGEXP_split(part_description, '.*\(\s*MS|C\d+|S\d+|M\d+|CD\d+|NY\d+|A\d+|80\-|MS.+\)$', 'FIRST', -1) as _t2a_parsed,
        _t2a_matched || ARRAY_TO_STRING(SUBLIST(_t2a_parsed, 2, 1),',') as parsed
        from t1 where matched = ''
  ),
  t2b as
  ( -- Match on the primary keywords
        select specnum_formatted, part_type, part_description, matched, 
        REGEXP_split(part_description, '.*\(\s*InternalVal|InternalVal|ExternalVal|Outisde|Oustide|Outside|MSK: MSK: |MSKp:|MSK;|MSK:|MSKS|MKS|MSK:MSK|MSK|MSk|msk|MS|MS.+\)$', 'FIRST', -1) as _t2a_parsed,
        ARRAY_TO_STRING(SUBLIST(_t2a_parsed, 2, 1),',') as parsed from t1 where matched <> '' 
  ),
  t3 as
  ( -- Union the two previous steps so that all of the specnums that have valid into parsed column
        select specnum_formatted, part_type, part_description, matched, parsed from t2b
        union all
        select specnum_formatted, part_type, part_description, matched, parsed from t2a
  ),
  t4 as 
  ( -- Trim trailing characters
        select specnum_formatted, part_description, matched, 
        COALESCE(NULLIF(trim(
        trim(trailing ')' from 
            trim(leading ':' from 
            parsed))), ''),'') as structured_portion
            
        from t3
  ),
  t5 as 
  ( -- Extracts number adjacent to either H&E or USS labels. 
    -- In rare cases, these numbers are swapped (ie 20 H&E, 1 USS), but more often there is no count for either value. 
        select specnum_formatted, part_description, structured_portion, matched,
        REGEXP_Extract(structured_portion, '(\d+)\s*(H&E|H/E)') as hne_count,
        REGEXP_Extract(structured_portion, '(\d+)\s*(USS|US|unstained|uss|uSS|and)') as uss_count from t4
  ),
  t6 as 
  (-- Extract date of procedure based on looking at dates adjacent to DOP character. 
   -- Not all specnums have a DOP, and not all DOPs are prefixed correctly. 
        select specnum_formatted, part_description, structured_portion, uss_count, hne_count, matched, 
        REGEXP_EXTRACT(structured_portion, 'DOP:?\s*(\d{1,2}/\d{1,2}/\d{2,4})') as dop
        from t5
  ),
  t7 as 
  ( -- Extract binary variable on 'matched', which indicates if a specnum has only an external sample  
    --not where it has both an external and internal sample)            
        select specnum_formatted, part_description, structured_portion, uss_count, hne_count, matched, dop,
        case matched
            when 'ExternalVal' then True
            when 'Outside' then True
            when 'Oustide' then TRUE
            when 'Outisde' then True
            else False
        end as has_only_external_s_number
        from t6
  ),
  t8 as 
  (-- Extracts surgical part designator from the accession by taking all characters to the right of the first comma or space in the structured_portion.
        select specnum_formatted, part_description, structured_portion, uss_count, hne_count, matched, has_only_external_s_number, dop,
        TRIM(
            TRIM(leading '"' from 
            TRIM(leading ':' from 
            TRIM(leading 'l:' from 
            regexp_extract(structured_portion, '^(.*?)(?:,|\s|$)'))))) as surg_part_desig from t7
  ),
  t9 as 
  ( -- Parses out the part and block portions of the surg_part_desig, which is everything to the left of the first / 
    -- In some cases, internal and external accessions cannot be separated. 
        select specnum_formatted, part_description, structured_portion, uss_count, hne_count, matched, has_only_external_s_number, surg_part_desig, dop,
        regexp_extract(surg_part_desig, '^(.*?)(?=/|$)') as s_number,
        regexp_extract(surg_part_desig, '\/(.*)$') as part_block_desig
        from t8
  ),
  t10 as 
  ( -- Separate part and block from part_block deisgnator on the - character 
        select specnum_formatted, part_description, structured_portion, uss_count, hne_count, matched, has_only_external_s_number, dop,
        surg_part_desig, s_number, part_block_desig, regexp_extract(part_block_desig, '^(.*?)(?:,|\s|$)') as part_number,
        regexp_extract(part_block_desig, '-(.*)$') as s_blk_desig_label from t9
  ),
  t11 as 
  ( -- Binary variable checked against the entire structured_portion field that indicates if the sample has an external surgical part designator
        select specnum_formatted, part_description, structured_portion, uss_count, hne_count, matched, has_only_external_s_number, 
        surg_part_desig, s_number, part_block_desig, part_number, s_blk_desig_label, dop,
        case 
            when structured_portion LIKE '%ExternalVal%' then True
            when structured_portion LIKE '%Outside%' then True
            when structured_portion LIKE '%Oustide%' then True
            when structured_portion LIKE '%Outisde%' then True
            else False
        end as has_external_s_number
        from t10
  )
select specnum_formatted, part_description, s_number, part_number, s_blk_desig_label, uss_count, hne_count, has_only_external_s_number from t11