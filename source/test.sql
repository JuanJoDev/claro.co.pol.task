--1;2;3;4;5;6;7;E;H;M;LC;O;SA;R;X;Y;Z;PR;3U;EU;OU;R4;NBO;+;%;=;
BEGIN
    BEGIN
        SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') 
        INTO :v_result 
        FROM DUAL;
    EXCEPTION
        WHEN OTHERS THEN
            :v_result := 'Exception: ' || SUBSTR(SQLERRM, 1, 4000);
    END;
END;
