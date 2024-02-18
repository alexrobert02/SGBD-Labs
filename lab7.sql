-- Considerati tabelele studenti, note si view-ul obtinut prin joinul celor 2 tabele.
-- Construiti triggere care sa permita realizarea de operatii de tipul INSERT, UPDATE, DELETE pe view.
-- Folositi tipuri specifice de triggere pentru a permite afisarea continutului inainte si dupa executarea operatiilor respective; afisati mesaje sugestive.


CREATE OR REPLACE VIEW note_studenti AS
SELECT s.id, N.id as id_nota, s.nr_matricol, s.nume, s.prenume, n.valoare, n.id_curs
FROM studenti s
JOIN note n ON s.id = n.id_student;
/

CREATE OR REPLACE TRIGGER tr_note_studenti_insert
INSTEAD OF INSERT ON note_studenti
FOR EACH ROW
BEGIN
    
    INSERT INTO studenti (id, nr_matricol, nume, prenume) VALUES (:new.id, :new.nr_matricol, :new.nume, :new.prenume); 
    INSERT INTO note (id_student, id, valoare, id_curs) VALUES (:new.id, :new.id_nota, :new.valoare, :new.id_curs);
    
    DBMS_OUTPUT.PUT_LINE('Note for student: ' || :new.nume || ' ' || :new.prenume || ' inserted successfully.');
END;
/

CREATE OR REPLACE TRIGGER tr_note_studenti_update
INSTEAD OF UPDATE ON note_studenti
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Updating note for student: ' || :old.nume || ' ' || :old.prenume || '.');
    
    UPDATE studenti
    SET nume = :new.nume, prenume = :new.prenume, nr_matricol = :new.nr_matricol
    WHERE id = :old.id;
    
    UPDATE note
    SET valoare = :new.valoare
    WHERE id_student = :old.id;
    
    DBMS_OUTPUT.PUT_LINE('Note for student: ' || :new.nume || ' ' || :new.prenume || ' updated successfully.');
    DBMS_OUTPUT.PUT_LINE('Old nume: ' || :old.nume);
    DBMS_OUTPUT.PUT_LINE('New nume: ' || :new.nume);
    DBMS_OUTPUT.PUT_LINE('Old prenume: ' || :old.prenume);
    DBMS_OUTPUT.PUT_LINE('New prenume: ' || :new.prenume);
    DBMS_OUTPUT.PUT_LINE('Old valoare: ' || :old.valoare);
    DBMS_OUTPUT.PUT_LINE('New valoare: ' || :new.valoare);
    
END;
/

CREATE OR REPLACE TRIGGER tr_note_studenti_delete
INSTEAD OF DELETE ON note_studenti
FOR EACH ROW
BEGIN
    DELETE FROM note WHERE id_student = :old.id;
    DELETE FROM studenti WHERE id = :old.id;
    DBMS_OUTPUT.PUT_LINE('Note for student: ' || :old.nume || ' ' || :old.prenume || ' deleted successfully.');
END;
/

SET SERVEROUTPUT ON;

INSERT INTO note_studenti (id, id_nota, nr_matricol, nume, prenume, valoare, id_curs)
VALUES (80521, 90201, 'ABCDEF', 'Zaharia', 'Robert', 10, 10);

UPDATE note_studenti SET valoare = 9 WHERE id = 80521;

DELETE FROM note_studenti WHERE id=80521;
