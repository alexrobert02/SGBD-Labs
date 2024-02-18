-- Intr-un cod PLSQL, sa se realizeze statistici la nivel de utilizator despre tabele, proceduri si functii utilizand dictionarul de date. 
-- Se vor afisa pentru fiecare tip in parte ce obiecte a creat utilizatorul, si pentru fiecare obiect in parte se vor afisa informatii specifice. 
-- Ex: pentru un tabel se vor afisa numele, cate inregistrari are, daca are constrangeri, indecsi si care sunt acestia, tipul de constrangere si coloanele implicate, daca este nested table, lar pentru o functie/procedura, de exemplu, numele, numarul de linii de cod, daca este determinista.


SET SERVEROUTPUT ON;

DECLARE
    v_owner VARCHAR2(30) := 'STUDENT';
    v_lines NUMBER;
BEGIN
    -- Display table information
    FOR t IN (SELECT table_name, num_rows, nested
              FROM all_tables
              WHERE owner = v_owner) LOOP
        DBMS_OUTPUT.PUT_LINE('Table: ' || t.table_name);
        DBMS_OUTPUT.PUT_LINE('Number of Rows: ' || t.num_rows);
        IF t.nested = 'YES' THEN
            DBMS_OUTPUT.PUT_LINE('Nested Table: Yes');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nested Table: No');
        END IF;

        -- Check constraints
        FOR c IN (SELECT constraint_name, constraint_type, search_condition
                  FROM all_constraints
                  WHERE owner = v_owner AND table_name = t.table_name) LOOP
            DBMS_OUTPUT.PUT_LINE('Constraint: ' || c.constraint_name);
            DBMS_OUTPUT.PUT_LINE('Type: ' || c.constraint_type);
            IF c.search_condition IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('Condition: ' || c.search_condition);
            END IF;
        END LOOP;

        -- Check indexes
        FOR i IN (SELECT index_name, index_type
                  FROM all_indexes
                  WHERE owner = v_owner AND table_name = t.table_name) LOOP
            DBMS_OUTPUT.PUT_LINE('Index: ' || i.index_name);
            DBMS_OUTPUT.PUT_LINE('Type: ' || i.index_type);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    END LOOP;

    -- Display procedure/function information
    FOR p IN (SELECT name, type
              FROM all_source
              WHERE owner = v_owner AND type = 'PROCEDURE'
              GROUP BY name, type) LOOP
        v_lines := 0;
        SELECT COUNT(DISTINCT line) INTO v_lines
        FROM all_source
        WHERE type = p.type AND name = p.name;

        DBMS_OUTPUT.PUT_LINE(p.type || ': ' || p.name);
        DBMS_OUTPUT.PUT_LINE('Number of Lines: ' || v_lines);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    END LOOP;

    FOR p IN (SELECT object_name, object_type, deterministic
              FROM user_procedures
              WHERE object_type = 'FUNCTION') LOOP
        v_lines := 0;

        FOR line IN (SELECT line
                     FROM all_source
                     WHERE owner = v_owner AND name = p.object_name AND type = p.object_type
                     ORDER BY line) LOOP
            v_lines := v_lines + 1;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(p.object_type || ': ' || p.object_name);
        DBMS_OUTPUT.PUT_LINE('Number of lines: ' || v_lines);
        DBMS_OUTPUT.PUT_LINE('Is deterministic? ' || p.deterministic);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    END LOOP;
END;
