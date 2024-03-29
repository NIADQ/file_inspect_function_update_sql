/* 
   FUNCTION 사용법
   FN_DATE_CLEANSING(값, 리턴형식, 값패턴)
   * 리턴형식 표준포멧만 지원(YYYY-MM-DD HH24:MI:SS)
*/
SELECT FN_DATE_CLEANSING(VAL, 'YYYY-MM-DD HH24:MI', REGEXP_REPLACE(REGEXP_REPLACE(A.VAL, '[[:alpha:]]', 'M'), '[[:digit:]]', '9'))
  FROM (
        SELECT '11#123123' AS VAL
          FROM DUAL
       ) A
;

/* 
   업데이트 활용
*/
UPDATE 업데이트대상테이블
   SET 업데이트대상컬럼 = FN_DATE_CLEANSING(업데이트대상컬럼, 'YYYY-MM-DD HH24:MI', REGEXP_REPLACE(REGEXP_REPLACE(A.업데이트대상컬럼, '[[:alpha:]]', 'M'), '[[:digit:]]', '9'))
 WHERE 1=1
   AND 업데이트대상데이터조건
;
