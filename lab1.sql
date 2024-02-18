-- Avand la dispozitie tabela studenti, definiti un bloc anonim care sa permita citirea de la tastatura a campurilor dintr-o astfel de tabela si inserarea valorilor citite in tabela respectiva.


SET SERVEROUTPUT ON;
DECLARE
    v_id NUMBER(4) := &i_id;
    v_nr_matricol CHAR(6) := '&i_nr_matricol';
    v_nume VARCHAR2(10) := '&i_nume';
    v_prenume VARCHAR2(10) := '&i_prenume';
    v_an NUMBER(1) := &i_an;
    v_grupa CHAR(2) := '&i_grupa';
    v_bursa NUMBER(6,2) := &i_bursa;
    v_data_nastere DATE := TO_DATE('&i_data_nastere', 'DD-MON-YY');
BEGIN
    INSERT INTO studenti(id, nr_matricol, nume, prenume, an, grupa, bursa, data_nastere)
    VALUES (v_id, v_nr_matricol, v_nume, v_prenume, v_an, v_grupa, v_bursa, v_data_nastere);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Data inserted successfully.');
END;
