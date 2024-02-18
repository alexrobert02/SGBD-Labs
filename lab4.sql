-- Creati un nested table in care se vor adauga mediile semetriale ale studentilor (din anul 1 sem 1, an 1 sem 2, an 2 sem 1 etc.) In functie de ce note are trecute studentul respectiv
-- Mediile semestriale le puteti calcula grupand notele stusdentului dupa anul si semestrul in care au fost tinute cursurile la care are note.
-- Hint: Construiti o functie care pentru un anumit student returneaza cate medii are trecute in coloana lista_medii"


CREATE OR REPLACE TYPE lista_medii AS TABLE OF NUMBER;

CREATE TABLE medii(
    student_id NUMBER,
    an NUMBER,
    semestru NUMBER,
    medie lista_medii
) NESTED TABLE medie STORE AS lista;

CREATE OR REPLACE FUNCTION count_averages(student_id IN NUMBER) RETURN NUMBER IS
    num_averages NUMBER;
BEGIN
    SELECT COUNT(*) INTO num_averages FROM medii WHERE student_id = student.id;
    RETURN num_averages;
END;
/

CREATE OR REPLACE PROCEDURE calcul_medii(p_student_id IN NUMBER) IS
    CURSOR cursor_medii (p_student_id NUMBER) IS
        SELECT c.an, c.semestru, AVG(VALOARE) AS medie
        FROM NOTE N 
        JOIN CURSURI C ON n.id_curs = c.id
        WHERE c.an IS NOT NULL AND c.semestru IS NOT NULL
        GROUP BY c.an, c.semestru;

    v_an NUMBER;
    v_semestru NUMBER;
    v_medie NUMBER;
BEGIN
    FOR v_std_linie IN cursor_medii(p_student_id) LOOP
        v_an := v_std_linie.an;
        v_semestru := v_std_linie.semestru;
        v_medie := v_std_linie.medie;
        INSERT INTO medii (student_id, an, semestru, medie)
        VALUES (p_student_id, v_an, v_semestru, v_medie);
    END LOOP;
END;
