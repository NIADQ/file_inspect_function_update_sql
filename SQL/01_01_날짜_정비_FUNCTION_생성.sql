
CREATE OR REPLACE FUNCTION FN_DATE_CLEANSING(I_VAL VARCHAR2, I_STD_FORMAT VARCHAR2, I_PATTERN VARCHAR2)

RETURN VARCHAR2

IS 

    V_PATTERN VARCHAR2(500);
    V_VAL VARCHAR2(4000);
    V_VAL_TOKEN VARCHAR2(200);

    V_YYYY VARCHAR2(10);
    V_MM VARCHAR2(10);
    V_DD VARCHAR2(10);
    V_HH24 VARCHAR2(10);
    V_MI VARCHAR2(10);
    V_SS VARCHAR2(10);
    
    V_91 VARCHAR2(10);
    V_92 VARCHAR2(10);
    V_93 VARCHAR2(10);    
    
    V_TOKEN VARCHAR2(200);
    V_OHU VARCHAR2(100);
    V_ORYU VARCHAR2(100);

BEGIN

    V_PATTERN := REPLACE(I_PATTERN, ' ', '');
    
    IF(V_PATTERN IN ('99/99/9999', '99.99.9999', '99-99-9999') AND I_STD_FORMAT LIKE 'YY%') THEN
        
        V_VAL := REPLACE(REPLACE(REPLACE(TRIM(I_VAL), '.', ''), '-', ''), '/', '');
        V_YYYY := SUBSTR(V_VAL, 5);
        V_MM   := SUBSTR(V_VAL, 3, 2);
        V_DD   := SUBSTR(V_VAL, 1, 2);
    END IF
;
        
        
                
                
                
    IF(V_PATTERN NOT IN ('99/99/9999', '99.99.9999', '99-99-9999') AND I_STD_FORMAT LIKE 'YY%') THEN 

        IF(V_PATTERN NOT IN ('9999-9-999:99', '9999-9-99:99')) THEN
             V_VAL := REPLACE(REPLACE(TRIM(I_VAL), ' ', ''), CHR(39), '');
        ELSE  
             V_VAL := REPLACE(TRIM(I_VAL), CHR(39), '');
        END IF;
        V_VAL := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_VAL, '년', '.'), '월', '.'), '일', '.'), '‘’', ''), CHR(39), '.'),'.', ',');
        V_OHU := CASE WHEN V_VAL LIKE '%오후%'
                      THEN 'O'
                      WHEN V_VAL LIKE '%오전%'
                      THEN 'X'
                      ELSE NULL
                  END;
        
        IF (V_VAL LIKE '%,' ) THEN 
            V_VAL := SUBSTR(V_VAL, 1, LENGTH(V_VAL)-1);
        END IF;
        IF (V_VAL LIKE ',%' ) THEN 
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
        END IF;
        IF (V_VAL LIKE '[%' ) THEN
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
        END IF;
        IF (V_VAL LIKE ']%' ) THEN
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
        END IF;
        IF (V_VAL LIKE '%]' ) THEN
            V_VAL := SUBSTR(V_VAL, 1, LENGTH(V_VAL)-1);
        END IF;
        IF (V_VAL LIKE '(%' ) THEN
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
        END IF;
        IF (V_VAL LIKE '%)' ) THEN
            V_VAL := SUBSTR(V_VAL, 1, LENGTH(V_VAL)-1);
        END IF;
        
        IF (V_VAL LIKE '''%' OR V_VAL LIKE '''%' OR V_VAL LIKE '’%' OR V_VAL LIKE '‘%' OR V_VAL LIKE '`%' OR V_VAL LIKE '′%' OR V_VAL LIKE CHR(39)||'%' ) THEN 
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
            V_VAL := CASE WHEN SUBSTR(V_VAL, 1, 2) <= 30 THEN '20'||V_VAL ELSE '19'||V_VAL END;
        END IF;

        SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(VAL2, ',,', ','), ',,', ','), ',,', ','), ',,', ','), ',,', ',') VAL3
          INTO V_VAL_TOKEN
          FROM (
                SELECT REPLACE(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(TRIM(VALUE1), '[[:alpha:]]', ''), '[^[:digit:]]', ','), ' ', ','), ' ', ',') VAL2
                  FROM (
                        SELECT V_VAL AS VALUE1
                          FROM DUAL
                       ) A
                );

        
        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;
        
        IF (V_TOKEN IS NOT NULL) THEN 
            
            IF(LENGTH(V_TOKEN) = 1) THEN
                V_YYYY := '200'||V_TOKEN ;
            ELSIF(LENGTH(V_TOKEN) = 2) THEN
                V_YYYY := CASE WHEN SUBSTR(V_TOKEN, 1, 2) <= 30 THEN '20'||V_TOKEN ELSE '19'||V_TOKEN END;
            ELSE 
                V_YYYY := SUBSTR(V_TOKEN, 1, 4);
            END IF;
            
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN)=1 THEN 1 WHEN LENGTH(V_TOKEN) = 2 THEN 2 ELSE 4 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
            
        END IF;
        
        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;
        
        IF (V_TOKEN IS NOT NULL) THEN
            IF(LENGTH(V_TOKEN) = 2 AND V_TOKEN > 12) THEN V_ORYU := 'Y'; END IF;
            V_MM := CASE WHEN LENGTH(V_TOKEN) = 2 AND V_TOKEN > 12
                         THEN LPAD(SUBSTR(V_TOKEN, 1, 1), 2, '0')
                         WHEN LENGTH(V_TOKEN) = 1 AND V_TOKEN = 0
                         THEN NULL
                         ELSE CASE WHEN LENGTH(V_TOKEN) <= 1
                                   THEN LPAD(V_TOKEN, 2, '0') 
                                   ELSE SUBSTR(V_TOKEN, 1, 2) 
                              END
                    END;
                    
            V_VAL_TOKEN := CASE WHEN LENGTH(V_TOKEN) = 2 AND V_TOKEN > 12 
                                THEN SUBSTR(V_TOKEN, 2, LENGTH(V_TOKEN)-1) 
                                WHEN LENGTH(V_TOKEN) = 1 AND V_TOKEN = 0
                                THEN NULL
                                ELSE SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN)) END;
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
            
        END IF;

        V_TOKEN := CASE WHEN V_VAL_TOKEN NOT LIKE 'ANGAK%' AND  REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_DD := CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END;
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        END IF;


        /*******************************************************************************************************************************************************************/


        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_HH24 := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_HH24 := '00';            
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NULL THEN V_VAL_TOKEN ELSE REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1)  END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_MI := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, NVL(LENGTH(V_TOKEN), 0) + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_MI := '00';
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_SS := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_SS := '00';            
        END IF;

    ELSIF(I_STD_FORMAT LIKE 'MM-DD%') THEN 


        V_VAL := TRIM(I_VAL);
        V_VAL := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_VAL, '년', '.'), '월', '.'), '일', '.'), '‘’', ''), CHR(39), '.'),'.', ',');
        


        IF (V_VAL LIKE '%,' ) THEN 
            V_VAL := SUBSTR(V_VAL, 1, LENGTH(V_VAL)-1);
        END IF;
        IF (V_VAL LIKE ',%' ) THEN 
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
        END IF;
        IF (V_VAL LIKE '(%' ) THEN
            V_VAL := SUBSTR(V_VAL, 2, LENGTH(V_VAL));
        END IF;
        IF (V_VAL LIKE '%)' ) THEN
            V_VAL := SUBSTR(V_VAL, 1, LENGTH(V_VAL)-1);
        END IF;
        
        
        
        SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(VAL2, ',,', ','), ',,', ','), ',,', ','), ',,', ','), ',,', ',') VAL3
          INTO V_VAL_TOKEN
          FROM (
                SELECT REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(TRIM(VALUE1), '[[:alpha:]]', ''), '[^[:digit:]]', ','), ' ', ',') VAL2
                  FROM (
                        SELECT V_VAL AS VALUE1
                          FROM DUAL
                       ) A
                );
                

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_MM := CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END;
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_DD := CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END;
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        END IF;
        
        /*******************************************************************************************************************************************************************/


        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_HH24 := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_HH24 := '00';            
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NULL THEN V_VAL_TOKEN ELSE REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1)  END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_MI := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, NVL(LENGTH(V_TOKEN), 0) + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_MI := '00';
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_SS := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_SS := '00';            
        END IF;


    
    ELSIF(I_STD_FORMAT LIKE 'HH%' OR I_STD_FORMAT LIKE 'MI%' OR I_STD_FORMAT LIKE 'SS%' OR I_STD_FORMAT = 'MM' OR I_STD_FORMAT = 'DD') THEN 
    
        V_VAL := TRIM(I_VAL);    
    
        SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(VAL2, ',,', ','), ',,', ','), ',,', ','), ',,', ','), ',,', ',') VAL3
          INTO V_VAL_TOKEN
          FROM (
                SELECT REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(TRIM(VALUE1), '[[:alpha:]]', ''), '[^[:digit:]]', ','), ' ', ',') VAL2
                  FROM (
                        SELECT V_VAL AS VALUE1
                          FROM DUAL
                       ) A
                );
                
        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_91 := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_91 := '00';            
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NULL THEN V_VAL_TOKEN ELSE REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_92 := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, NVL(LENGTH(V_TOKEN), 0) + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_92 := '00';
        END IF;

        V_TOKEN := CASE WHEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) IS NOT NULL THEN REGEXP_SUBSTR (V_VAL_TOKEN, '[^,]+', 1, 1) ELSE V_VAL_TOKEN END;

        IF (V_TOKEN IS NOT NULL) THEN 
            V_93 := NVL(CASE WHEN LENGTH(V_TOKEN) <= 1 THEN LPAD(V_TOKEN, 2, '0') ELSE SUBSTR(V_TOKEN, 1, 2) END, '00');
            V_VAL_TOKEN := SUBSTR(V_VAL_TOKEN, CASE WHEN LENGTH(V_TOKEN) <= 1 THEN 1 ELSE 2 END + 1, LENGTH(V_VAL_TOKEN));
            V_VAL_TOKEN := CASE WHEN V_VAL_TOKEN LIKE ',%' THEN SUBSTR(V_VAL_TOKEN, 2, LENGTH(V_VAL_TOKEN)) ELSE V_VAL_TOKEN END;
        ELSE
            V_93 := '00';            
        END IF;                
                
    END IF;

    IF (V_ORYU = 'Y') THEN V_VAL := I_VAL;
    ELSE
        IF (I_STD_FORMAT = 'YYYY-MM-DD HH24:MI:SS') THEN 
            V_VAL := V_YYYY||CASE WHEN V_MM IS NOT NULL THEN '-'||V_MM END||CASE WHEN V_DD IS NOT NULL THEN '-'||V_DD END||CASE WHEN V_OHU IS NULL THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||V_HH24 END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END||CASE WHEN V_SS IS NOT NULL THEN ':'||V_SS END
                                                                                                                                WHEN V_OHU = 'O' THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||CASE WHEN TO_NUMBER(V_HH24)+12 = 24 THEN '12' ELSE TO_CHAR(TO_NUMBER(V_HH24)+12) END END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END||CASE WHEN V_SS IS NOT NULL THEN ':'||V_SS END
                                                                                                                                WHEN V_OHU = 'X' THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||CASE WHEN V_HH24 = '12' THEN '00' ELSE V_HH24 END END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END||CASE WHEN V_SS IS NOT NULL THEN ':'||V_SS END
                                                                                                                            END;
                                                                                                                                
        ELSIF (I_STD_FORMAT = 'YYYY-MM-DD HH24:MI') THEN 
            V_VAL := V_YYYY||CASE WHEN V_MM IS NOT NULL THEN '-'||V_MM END||CASE WHEN V_DD IS NOT NULL THEN '-'||V_DD END||CASE WHEN V_OHU IS NULL THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||V_HH24 END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END
                                                                                                                                WHEN V_OHU = 'O' THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||CASE WHEN TO_NUMBER(V_HH24)+12 = 24 THEN '12' ELSE TO_CHAR(TO_NUMBER(V_HH24)+12) END END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END
                                                                                                                                WHEN V_OHU = 'X' THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||CASE WHEN V_HH24 = '12' THEN '00' ELSE V_HH24 END END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END
                                                                                                                            END;
        ELSIF (I_STD_FORMAT = 'YYYY-MM-DD HH24') THEN 
            V_VAL := V_YYYY||CASE WHEN V_MM IS NOT NULL THEN '-'||V_MM END||CASE WHEN V_DD IS NOT NULL THEN '-'||V_DD END||CASE WHEN V_OHU IS NULL THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||V_HH24 ELSE NULL END
                                                                                                                                WHEN V_OHU = 'O' THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||CASE WHEN TO_NUMBER(V_HH24)+12 = 24 THEN '12' ELSE TO_CHAR(TO_NUMBER(V_HH24)+12) END END
                                                                                                                                WHEN V_OHU = 'X' THEN CASE WHEN V_HH24 IS NOT NULL THEN ' '||CASE WHEN V_HH24 = '12' THEN '00' ELSE V_HH24 END END
                                                                                                                            END;
        ELSIF (I_STD_FORMAT = 'YYYY-MM-DD') THEN 
            V_VAL := V_YYYY||CASE WHEN V_MM IS NOT NULL THEN '-'||V_MM END||CASE WHEN V_DD IS NOT NULL THEN '-'||V_DD END;
        ELSIF (I_STD_FORMAT = 'YYYY-MM') THEN 
            V_VAL := V_YYYY||CASE WHEN V_MM IS NOT NULL THEN '-'||V_MM END;
        ELSIF (I_STD_FORMAT = 'MM-DD') THEN           
            V_VAL := V_MM||CASE WHEN V_DD IS NOT NULL THEN '-'||V_DD END;
        ELSIF (I_STD_FORMAT = 'MM-DD HH24:MI') THEN           
            V_VAL := V_MM||CASE WHEN V_DD IS NOT NULL THEN '-'||V_DD END||CASE WHEN V_HH24 IS NOT NULL THEN ' '||V_HH24 END||CASE WHEN V_MI IS NOT NULL THEN ':'||V_MI END;
        ELSIF (I_STD_FORMAT = 'YYYY') THEN 
            V_VAL := V_YYYY;


        ELSIF (I_STD_FORMAT = 'HH24:MI:SS') THEN 
            V_VAL := CASE WHEN V_OHU IS NULL THEN V_91||CASE WHEN V_92 IS NOT NULL THEN ':'||V_92 END||CASE WHEN V_93 IS NOT NULL THEN ':'||V_93 END
                          WHEN V_OHU = 'O' THEN CASE WHEN V_91 IS NOT NULL THEN CASE WHEN TO_NUMBER(V_91)+12 = 24 THEN '12' ELSE TO_CHAR(TO_NUMBER(V_91)+12) END END ||CASE WHEN V_92 IS NOT NULL THEN ':'||V_92 END||CASE WHEN V_93 IS NOT NULL THEN ':'||V_93 END
                          WHEN V_OHU = 'X' THEN CASE WHEN V_91 IS NOT NULL THEN CASE WHEN V_91 = '12' THEN '00' ELSE V_91 END END||CASE WHEN V_92 IS NOT NULL THEN ':'||V_92 END||CASE WHEN V_93 IS NOT NULL THEN ':'||V_93 END
                      END;
        ELSIF (I_STD_FORMAT IN ('HH24:MI', 'MI:SS') ) THEN 
            V_VAL := V_91||CASE WHEN V_92 IS NOT NULL THEN ':'||V_92 END;
        ELSIF (I_STD_FORMAT IN ('MM', 'DD', 'HH24', 'MI', 'SS') ) THEN 
            V_VAL := V_91;
        END IF;
    END IF;
    
    
    RETURN V_VAL; 

END;