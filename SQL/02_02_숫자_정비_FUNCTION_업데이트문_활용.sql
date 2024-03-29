/* 
   FUNCTION 사용법
   FN_DATE_CLEANSING(값, 리턴형식, 값패턴)
   * 리턴형식 9(숫자)만 지원
*/
SELECT FN_NUMBER_CLEANSING(VAL, '9', REGEXP_REPLACE(REGEXP_REPLACE(A.VAL, '[[:alpha:]]', 'M'), '[[:digit:]]', '9'))
  FROM (
        SELECT '11,211.123123' AS VAL
          FROM DUAL
       ) A
;

/* 
   업데이트 활용
*/
UPDATE 업데이트대상테이블
   SET 업데이트대상컬럼 = FN_NUMBER_CLEANSING(업데이트대상컬럼, '9', REGEXP_REPLACE(REGEXP_REPLACE(A.업데이트대상컬럼, '[[:alpha:]]', 'M'), '[[:digit:]]', '9'))
 WHERE 1=1
   AND 업데이트대상데이터조건
;
