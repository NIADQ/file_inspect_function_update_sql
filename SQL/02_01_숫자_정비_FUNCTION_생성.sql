CREATE OR REPLACE FUNCTION FN_NUMBER_CLEANSING(I_VAL VARCHAR2, I_STD_FORMAT VARCHAR2, I_PATTERN VARCHAR2)

RETURN VARCHAR2

IS 

V_PRE_VAL VARCHAR2(4000);
V_VAL VARCHAR2(4000);

BEGIN

    
    IF (TRIM(I_PATTERN) LIKE '%M') THEN 

        V_PRE_VAL := TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(I_VAL, '천억', '00000000000'), '백억', '0000000000'), '십억', '000000000'), '억', '00000000'), '천만', '0000000'), '백만', '000000'), '십만', '00000'), '만', '0000'), '천', '000'), '백', '00'));
        
    ELSE
    
        V_PRE_VAL := TRIM(I_VAL);
    
    END IF;
    
    
    IF (V_PRE_VAL LIKE '%.%') THEN 
    
        
        V_VAL := REPLACE(REPLACE(REGEXP_REPLACE(REPLACE(V_PRE_VAL, '.', 'REALDOT'), '[[:punct:]]', ''), 'REALDOT', '.'), ' ','');

    ELSE
    
        V_VAL := REPLACE(REGEXP_REPLACE(V_PRE_VAL, '[^[:digit:]]', ''),' ','');
    
    END IF;
    
    IF(V_PRE_VAL LIKE '-%') THEN 
            
        V_VAL := '-' || V_VAL;
            
    END IF;
    
   
    IF(V_PRE_VAL LIKE '%.') THEN 
            
        V_VAL := SUBSTR(V_VAL,1,LENGTH(V_VAL)-1);
            
    END IF;

    RETURN V_VAL;
    
END;