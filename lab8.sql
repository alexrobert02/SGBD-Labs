-- Creati un script PLSQL care sa exporte pe calculatorul vostru tabela note intr-un fisier de tip CSV si un al doilea script care plecand de la un CSV, sa recreeze tabela note.
-- Intre cele doua operatii se va executa "delete from note"
-- Exportarea / importarea se va face NUMAI utilizand UTL_FILE.


-- Pachetul UTL_FILE este definit in fisierul utlfile.sql (pe care il puteti gasi in directorul in care ati instalat Oracle, intr-o secctiune de administrare). 
-- El este executat o singura data la instalarea serverului Oracle din contul de administrare si doar administratorului i se permite accesul la functionalitatile acestuia - evident daca acesta nu permite si unui alt utilizator sa aiba acces cu ajutorul unui grant: GRANT EXECUTE ON UTL_FILE TO STUDENT; (pentru contul STUDENT).

-- Creati un director "D:\STUDENT" - el va fi asociat unui identificator pe care il veti folosi in scripturile voastre (la pasul urmator se face aceasta asociere).

-- Revenind la contul de administrare, pentru a permite access unui utilizator sa scrie pe HDD, trebuie ca acel utilizator sa poata sa isi creeze o legatura logica intre directorul fizic si un identificator. 
-- Dupa ce aceasta legatura a fost creata, utilizatorul va folosi doar identificatorul pentru a accesa continutul directorului. Tot din contul de administrare executati asadar comanda GRANT CREATE ANY DIRECTORY TO STUDENT;

-- Acum, din contul STUDENT, va trebui sa creati legatura logica de care povesteam mai inainte. Directorul vizat va fi "D:\STUDENT". 
-- Pentru aceasta, creati directorul STUDENT (case sensitive), dupa care, din contul student executati comanda CREATE OR REPLACE DIRECTORY MYDIR as 'D:\STUDENT';

-- Si ca si cum toate precautiile nu sunt inca suficiente, trebuie sa reveniti in contul de administrator si sa ii permiteti utilizatorului STUDENT sa citeasca sau sa scrie in directorul tocmai creat: GRANT READ,WRITE ON DIRECTORY MYDIR TO STUDENT;



SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE insert_in_data AS
    v_fisier UTL_FILE.FILE_TYPE;
    v_linie VARCHAR2(300);
BEGIN
    v_fisier := UTL_FILE.FOPEN('MYDIR', 'lab8_tab_note.csv', 'R');
    LOOP
        UTL_FILE.GET_LINE(v_fisier, v_linie);
        DBMS_OUTPUT.PUT_LINE(v_linie);
        INSERT INTO note VALUES(
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 1),
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 2),
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 3),
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 4),
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 5),
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 6),
            REGEXP_SUBSTR(v_linie, '[^,]+', 1, 7)
        );
    END LOOP;
    UTL_FILE.FCLOSE(v_fisier);
EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;    
END;
/

CREATE OR REPLACE PROCEDURE export_data AS
    v_fisier UTL_FILE.FILE_TYPE;
    CURSOR tab_note IS 
    SELECT * FROM note;
BEGIN
    v_fisier := UTL_FILE.FOPEN('MYDIR', 'lab8_tab_note.csv', 'W');
    FOR v_linie IN tab_note LOOP
        UTL_FILE.PUT_LINE(v_fisier, v_linie.id ||','||v_linie.id_student||','||v_linie.id_curs||','||v_linie.valoare||','||v_linie.data_notare||','||v_linie.created_at||','||v_linie.updated_at);
    END LOOP;
    UTL_FILE.FCLOSE(v_fisier);
END;
/

BEGIN
    export_data();
    DELETE FROM note;
    insert_in_data();
END;
