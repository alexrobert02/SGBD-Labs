-- Construiti o functie/procedura ce va genera catalogul unei materii: parametrul de intrare va fi un ID de materie si functia va genera o tabela avand acelasi nume cu materia; in cazul inputului format din mai multe cuvinte, se pot concatena cuvintele respective intr-unul singur.
-- Catalogul va avea campurile nota, data_notarii, numele, prenumele si numarul matricol al studentului ce a luat nota respectiva si va fi populat din tabelele existente.
-- Folositi pachetul DBMS_SQL pentru a afla tipurile tabelelor la runtime; folosirea de tipuri hardcodate se va penaliza. ! Nu folositi functia EXECUTE_IMMEDIATE.


CREATE OR REPLACE FUNCTION generate_catalog(subject_id NUMBER) RETURN BOOLEAN AS
    table_name VARCHAR2(100);
    l_cursor PLS_INTEGER;
    l_sql VARCHAR2(1000);
    l_col_cnt PLS_INTEGER;
    l_desc_tab DBMS_SQL.DESC_TAB;
    l_valoare NUMBER;
    l_data_notare DATE;
    l_nume VARCHAR2(100);
    l_prenume VARCHAR2(100);
    l_nr_matricol VARCHAR2(100);
    l_id_student NUMBER;
    v_ok INTEGER;
BEGIN

    SELECT SUBSTR(REPLACE(REPLACE(titlu_curs, ' ', ''), '.', ''), 1, 15) INTO table_name
    FROM cursuri
    WHERE id = subject_id;
  
    l_cursor := DBMS_SQL.OPEN_CURSOR;
  
    l_sql := 'CREATE TABLE ' || table_name || ' (valoare NUMBER, data_notare DATE, nume VARCHAR2(100), prenume VARCHAR2(100), nr_matricol VARCHAR2(100), id_student NUMBER)';
  
    DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  
    l_cursor := DBMS_SQL.OPEN_CURSOR;

    l_sql := 'SELECT n.valoare, n.data_notare, s.nume, s.prenume, s.nr_matricol, s.id FROM note n JOIN studenti s ON n.id_student = s.id WHERE n.id_curs = ' || subject_id;

    DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);

    DBMS_SQL.DESCRIBE_COLUMNS(l_cursor, l_col_cnt, l_desc_tab);
  
    l_sql := 'INSERT INTO ' || table_name || ' (valoare, data_notare, nume, prenume, nr_matricol, id_student) VALUES (:1, :2, :3, :4, :5, :6)';
    DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
  
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_valoare);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, l_data_notare);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 3, l_nume, 100);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 4, l_prenume, 100);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 5, l_nr_matricol, 100);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 6, l_id_student);
  
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':1', l_valoare);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':2', l_data_notare);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':3', l_nume);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':4', l_prenume);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':5', l_nr_matricol);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':6', l_id_student);
  
    v_ok := DBMS_SQL.EXECUTE(l_cursor);
    LOOP
        IF DBMS_SQL.FETCH_ROWS(l_cursor) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_valoare);
            DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_data_notare);
            DBMS_SQL.COLUMN_VALUE(l_cursor, 3, l_nume);
            DBMS_SQL.COLUMN_VALUE(l_cursor, 4, l_prenume);
            DBMS_SQL.COLUMN_VALUE(l_cursor, 5, l_nr_matricol);
            DBMS_SQL.COLUMN_VALUE(l_cursor, 6, l_id_student);
        ELSE
            EXIT;
        END IF;
    END LOOP;
  
DBMS_SQL.CLOSE_CURSOR(l_cursor);

RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        DBMS_SQL.CLOSE_CURSOR(l_cursor);
        RETURN FALSE;
END generate_catalog;
/

SET SERVEROUTPUT ON;
DECLARE
    flag BOOLEAN;
BEGIN
    flag := generate_catalog(14);
    IF flag THEN
        DBMS_OUTPUT.PUT_LINE('Catalog generated successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Catalog generation failed.');
    END IF;
END;
