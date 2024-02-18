-- Construiti o clasa care sa permita crearea de obiecte de tip "student".
-- Adaugati un constructor implicit si unul explicit.
-- Adaugati o metoda de comparare - cu MAP sau ORDER - pentru media generala a studentului respectiv.
-- Inserati o serie de obiecte intr-o tabela; ordonati tabela utilizand metoda de comparare.
-- Construiti un bloc anonim pentru a afisa rezultatele obtinute.


DROP TYPE student FORCE; /
CREATE OR REPLACE TYPE student AS OBJECT (
    id NUMBER,
    nume VARCHAR2(50),
    prenume VARCHAR2(50),
    media NUMBER,

    CONSTRUCTOR FUNCTION student(id NUMBER, nume VARCHAR2, prenume VARCHAR2) RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION student RETURN SELF AS RESULT,
    
    MAP MEMBER FUNCTION compare_media RETURN NUMBER,
    
    MEMBER PROCEDURE calculate_media
);
/

CREATE OR REPLACE TYPE BODY student AS
    -- Implicit constructor
    CONSTRUCTOR FUNCTION student RETURN SELF AS RESULT IS
    BEGIN
        SELF.id := NULL;
        SELF.nume := NULL;
        SELF.prenume := NULL;
        SELF.media := NULL;
        RETURN;
    END;
  
    -- Explicit constructor
    CONSTRUCTOR FUNCTION student(id NUMBER, nume VARCHAR2, prenume VARCHAR2) RETURN SELF AS RESULT IS
        BEGIN
        SELF.id := id;
        SELF.nume := nume;
        SELF.prenume := prenume;
        SELF.calculate_media;
        RETURN;
    END;
  
    MAP MEMBER FUNCTION compare_media RETURN NUMBER IS
    BEGIN
        RETURN -media;
    END;
  
    MEMBER PROCEDURE calculate_media IS
        CURSOR c_medie IS
            SELECT TRUNC(AVG(valoare),2) AS medie 
            FROM note
            WHERE id_student = self.id
            GROUP BY id_student
            ORDER BY medie DESC;
        v_medie NUMBER;
        BEGIN
        OPEN c_medie;
            FETCH c_medie into v_medie;
            self.media := v_medie;
        CLOSE c_medie;
    END;
END;
/

DROP TABLE students;
/

CREATE TABLE students (
    obiect STUDENT
);

INSERT INTO students VALUES (STUDENT(24, 'Jecu', 'Denise'));
INSERT INTO students VALUES (STUDENT(29, 'Agape', 'Aurelian'));
INSERT INTO students VALUES (STUDENT(30, 'Galatianu', 'Laura'));

DECLARE
rec_student students.obiect%TYPE;
BEGIN
    FOR rec_student IN (
        SELECT obiect
        FROM students
        ORDER BY obiect.compare_media()
    )LOOP
    DBMS_OUTPUT.PUT_LINE('Nume: ' || rec_student.obiect.nume || ', Prenume, ' || rec_student.obiect.prenume || ', Average Grade: ' || rec_student.obiect.media);
    END LOOP;
END;
