-- Construiti o functie PLSQL care sa primeasca ca parametri numele si prenumele unui student si care sa returneze media si, in caz ca nu exista acel student(dat prin nume si prenume) sa arunce o exceptie definita de voi.
-- Dintr-un bloc anonim care contine intr-o structura de tip colectie mai multe nume si prenume (cel putin 2 studenti existenti si cel putin 2 care nu sunt in baza de date), apelati functia pentru studentii inregistrati in colectie.
-- Prindeti exceptia si afisati un mesaj corespunzator atunci cand studentul nu exista sau afisati valoarea returnata de functie daca studentul exista.


CREATE OR REPLACE FUNCTION get_student_avg(p_nume IN VARCHAR2, p_prenume IN VARCHAR2) RETURN NUMBER IS
    NO_STUDENT_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_STUDENT_FOUND, -20001);
    student_avg NUMBER;
BEGIN
    SELECT AVG(n.valoare) INTO student_avg
    FROM note n
    JOIN studenti s ON s.id = n.id_student
    WHERE s.nume = p_nume AND s.prenume = p_prenume;
  
    IF student_avg IS NULL THEN
        RAISE no_student_found;
    END IF;
  
    RETURN student_avg;
EXCEPTION
    WHEN no_student_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Student not found');
END get_student_avg;
/

CREATE OR REPLACE TYPE nume_list IS VARRAY(10) OF VARCHAR2(20);
/

CREATE OR REPLACE TYPE prenume_list IS VARRAY(10) OF VARCHAR2(20);
/

SET SERVEROUTPUT ON;
DECLARE
    NO_STUDENT_FOUND EXCEPTION;
    nume nume_list := nume_list('Lazar', 'Ciofu', 'Carp', 'Maties', 'Darie', 'Zaharia');
    prenume prenume_list := prenume_list('Mihaela', 'Sabin', 'Cezar', 'Delia', 'Simona', 'Robert');
    student_avg NUMBER;
BEGIN
    FOR i IN nume.FIRST .. nume.LAST LOOP
        BEGIN
            student_avg := get_student_avg(nume(i), prenume(i));
            DBMS_OUTPUT.PUT_LINE('Average grade for ' || nume(i) || ' ' || prenume(i) || ': ' || student_avg);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Student not found');
        END;
    END LOOP;
END;
