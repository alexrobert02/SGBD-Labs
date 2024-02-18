-- Afisati notele, materia si media pentru primii 10 cei mai buni studenti in ordinea mediilor. 
-- Numerotati studentii la afisare.


-- prima metoda

SET SERVEROUTPUT ON;
DECLARE
    CURSOR c1 IS
        SELECT n.id_student, s.nume, s.prenume, TRUNC(AVG(n.valoare),2) AS media 
        FROM studenti s JOIN note n ON s.id = n.id_student 
        GROUP BY n.id_student, nume, prenume 
        ORDER BY media DESC;
        
    CURSOR c2 (stud_id_student note.id_student%TYPE) IS
        SELECT n.valoare, c.titlu_curs 
        FROM note n 
        JOIN cursuri c ON c.id=n.id_curs 
        WHERE n.id_student = stud_id_student
        ORDER BY n.valoare DESC;
    v_std_linie c2%ROWTYPE;
        
BEGIN
    FOR each_stud IN c1 LOOP
        EXIT WHEN c1%rowcount = 11;
        DBMS_OUTPUT.PUT_LINE(each_stud.nume||' '||each_stud.prenume||' are media '||each_stud.media||' si notele:');
        OPEN c2 (each_stud.id_student);
        LOOP
            FETCH c2 INTO v_std_linie;
            EXIT WHEN c2%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_std_linie.valoare||' la '||v_std_linie.titlu_curs);
        END LOOP;
        CLOSE c2;
    END LOOP;
END;


-- a doua metoda

SET SERVEROUTPUT ON;
DECLARE
    CURSOR c1 IS
        SELECT n.id_student, s.nume, s.prenume, AVG(n.valoare) AS media
        FROM studenti s JOIN note n ON s.id = n.id_student
        GROUP BY s.nume, s.prenume, n.id_student
        ORDER BY media DESC;
    
    CURSOR c2(stud_id_student note.id_student%TYPE) IS 
        SELECT n.valoare, c.titlu_curs 
        FROM note n JOIN cursuri c ON n.id_curs=c.id
        WHERE n.id_student = stud_id_student 
        ORDER BY n.valoare DESC;

BEGIN
    FOR each_stud IN c1 LOOP
        EXIT WHEN c1%ROWCOUNT = 11;
        DBMS_OUTPUT.PUT_LINE(each_stud.id_student||' '|| each_stud.nume||' '||each_stud.prenume||' are media ' ||each_stud.media|| ' si notele:' );
        FOR nota IN c2(each_stud.id_student) LOOP
            DBMS_OUTPUT.PUT_LINE(nota.valoare||' la ' || nota.titlu_curs);
        END LOOP;
    END LOOP;
END;
