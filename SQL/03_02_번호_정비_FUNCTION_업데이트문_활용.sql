/* 
   FUNCTION 사용법
   FN_BUNHO_CLEANSING(값, 리턴형식, 값패턴)
   * 리턴형식 우편번호, 전화번호, 사업자번호만 가능
*/
SELECT FN_BUNHO_CLEANSING(VAL, '우편번호', REGEXP_REPLACE(REGEXP_REPLACE(A.VAL, '[[:alpha:]]', 'M'), '[[:digit:]]', '9'))
  FROM (
        SELECT '2303.04' AS VAL
          FROM DUAL
       ) A
;

/* 
   업데이트 활용
*/
UPDATE 업데이트대상테이블
   SET 업데이트대상컬럼 = FN_BUNHO_CLEANSING(업데이트대상컬럼, '우편번호', REGEXP_REPLACE(REGEXP_REPLACE(A.업데이트대상컬럼, '[[:alpha:]]', 'M'), '[[:digit:]]', '9'))
 WHERE 1=1
   AND 업데이트대상데이터조건
;
