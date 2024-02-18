/* Creati un pachet cu numele 'preferinte';
   Acest pachet va contine:
   - procedura afiseaza_preferinta() ce ia ca paramentru id-ul unui stusdent si va afisa la ecran materiile preferate de studentul respectiv.
   - o materie este preferata de un student daca a aobtinut nota 10 la materia respectiva.
   - o functie ce ia ca parametru id-ul uni sutdent si va returna materia preferata a studentului respectiv (prima materie stocata in cursor).
   Demonstrati utilizarea procedurii si a functiei utilizandu-le intr-un bloc anonim. afisati rezultatele. */


CREATE OR REPLACE PACKAGE preferinte IS
    CURSOR c_preferinta (p_id_student note.id_student%TYPE) IS
        SELECT c.titlu_curs 
        FROM cursuri c 
        JOIN note n ON c.id = n.id_curs
        WHERE n.valoare = 10 AND p_id_student = n.id_student;
    PROCEDURE afiseaza_preferinta (p_id_student note.id_student%TYPE);
    FUNCTION materia_preferata (p_id_student note.id_student%TYPE) RETURN VARCHAR2; 
END preferinte;
/

CREATE OR REPLACE PACKAGE BODY preferinte AS

    PROCEDURE afiseaza_preferinta (p_id_student note.id_student%TYPE) IS
         v_preferinta cursuri.titlu_curs%TYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Materiile preferate ale studentului ' || p_id_student || ':');
        OPEN c_preferinta (p_id_student);
        LOOP
            FETCH c_preferinta INTO v_preferinta;
            EXIT WHEN c_preferinta%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_preferinta);
        END LOOP;
        CLOSE c_preferinta;
    END afiseaza_preferinta;

    FUNCTION materia_preferata (p_id_student note.id_student%TYPE) RETURN VARCHAR2 IS
        v_preferinta cursuri.titlu_curs%TYPE;
    BEGIN
        OPEN c_preferinta (p_id_student);
        FETCH c_preferinta INTO v_preferinta;
        CLOSE c_preferinta;
        RETURN v_preferinta;
    END materia_preferata;
END preferinte;
/

SET SERVEROUTPUT ON;
DECLARE
    student_id NUMBER := 35;
    titlu VARCHAR2(100);
BEGIN
    preferinte.afiseaza_preferinta(student_id);
    DBMS_OUTPUT.PUT_LINE('Materia preferata a studentului cu id-ul ' || student_id || ' este ' || preferinte.materia_preferata(student_id));
END;
