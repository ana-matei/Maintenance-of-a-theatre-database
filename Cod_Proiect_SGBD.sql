CREATE OR REPLACE PROCEDURE update_salaries (v_id IN NUMBER)
IS
v_salary NUMBER;
BEGIN
  SELECT salary INTO v_salary 
  FROM ZEmployees
  WHERE employee_id = v_id;
  DBMS_OUTPUT.PUT_LINE('The salary before the update is: ' || v_salary);
  UPDATE ZEmployees
  SET salary = CASE
    WHEN salary BETWEEN 3500 AND 4000 THEN salary * 1.2
    WHEN salary BETWEEN 4000 AND 4500 THEN salary * 1.15
    WHEN salary BETWEEN 4500 AND 5000 THEN salary * 1.05
    ELSE salary
  END 
  WHERE employee_id = v_id;
  SELECT salary INTO v_salary 
  FROM ZEmployees
  WHERE employee_id = v_id;
  DBMS_OUTPUT.PUT_LINE('Salaries updated successfully to: ' || v_salary );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error updating salaries, no data was found: ' || SQLERRM);
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error updating salaries: ' || SQLERRM);
END;
/







BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE ZActive_actors ADD (gender VARCHAR2(20))';
  DBMS_OUTPUT.PUT_LINE('Column "gendre" added successfully.');
END;
/











SET SERVEROUTPUT ON
DECLARE
  v_max_salary NUMBER;
  v_job VARCHAR2(30);
BEGIN
  SELECT MAX(salary) INTO v_max_salary FROM ZEmployees;
  
  SELECT UPPER(job_name) INTO v_job
  FROM ZEmployees
  WHERE salary = v_max_salary;
  
  DBMS_OUTPUT.PUT_LINE('Maximum Salary: ' || v_max_salary);
  DBMS_OUTPUT.PUT_LINE('Job (Uppercase): ' || v_job);
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Error: Too many rows returned.');
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: No data found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/




SET SERVEROUTPUT ON
DECLARE
  j NUMBER := 0;
  CURSOR c_theatres IS
    SELECT theatre_id, theatre_name
    FROM ZTheatres;
  
  CURSOR c_employees (p_theatre_id NUMBER) IS
    SELECT *
    FROM ZEmployees
    WHERE theatre_id = p_theatre_id;
  
  v_theatre_id ZTheatres.theatre_id%TYPE;
  v_theatre_name ZTheatres.theatre_name%TYPE;
  v_employee ZEmployees%ROWTYPE;
BEGIN
  OPEN c_theatres;
  
  LOOP
    FETCH c_theatres INTO v_theatre_id, v_theatre_name;
    EXIT WHEN c_theatres%NOTFOUND;
    j:=0;
    
    -- Display employees for the current theater
    DBMS_OUTPUT.PUT_LINE( 'Theatre ID: ' || v_theatre_id || ' Theatre name: ' || v_theatre_name);
    DBMS_OUTPUT.PUT_LINE(' ');
    
    OPEN c_employees(v_theatre_id);
    
    LOOP
    j:=j+1;
      FETCH c_employees INTO v_employee;
      IF c_employees%NOTFOUND AND j=1 THEN
      DBMS_OUTPUT.PUT_LINE('There are no employees');
       DBMS_OUTPUT.PUT_LINE(' ');
      END IF;
      EXIT WHEN c_employees%NOTFOUND;
      
      DBMS_OUTPUT.PUT_LINE( j || ' ' || 'Employee ID: ' || v_employee.employee_ID || ' Name: ' || v_employee.first_name || ' ' || v_employee.last_name ||
      ' Job Name: ' || v_employee.job_name);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(' ');
    
    CLOSE c_employees;
  END LOOP;
  
   
  
  CLOSE c_theatres;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/




SET SERVEROUTPUT ON
DECLARE
  TYPE play_info IS TABLE OF VARCHAR(500) INDEX BY PLS_INTEGER;
  v_play_names play_info;
  v_play_durations play_info;
BEGIN
  -- Populate the index-by tables
  FOR rec IN (SELECT play_id, name, duration_minutes FROM ZPlays)
  LOOP
    v_play_names(rec.play_id) := rec.name;
    v_play_durations(rec.play_id) := rec.duration_minutes;
  END LOOP;
  
  -- Display play names and durations
  FOR i IN v_play_names.FIRST..v_play_names.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE('Play ID: ' || i);
    DBMS_OUTPUT.PUT_LINE('Play Name: ' || v_play_names(i));
    DBMS_OUTPUT.PUT_LINE('Duration (minutes): ' || v_play_durations(i));
    DBMS_OUTPUT.PUT_LINE('---------------------------');
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


DECLARE
  TYPE play_info IS RECORD (
    play_id NUMBER(6),
    name VARCHAR2(50),
    duration_minutes NUMBER(3),
    gendre VARCHAR2(20),
    no_actors NUMBER(2),
    ticket_price NUMBER(3),
    discount_price NUMBER(3)
  );
  TYPE plays_table IS TABLE OF play_info;
  v_plays plays_table := plays_table();
BEGIN
  -- Populate the nested table
  FOR rec IN (SELECT play_id, name, duration_minutes, gendre, no_actors, ticket_price FROM Plays)
  LOOP
    IF rec.ticket_price > 50 THEN
      v_plays.extend;
      v_plays(v_plays.count) := play_info(
        rec.play_id,
        rec.name,
        rec.duration_minutes,
        rec.gendre,
        rec.no_actors,
        rec.ticket_price,
        rec.ticket_price * 0.85 -- Apply 15% discount
      );
    END IF;
  END LOOP;
  
  -- Display plays and discount prices
  FOR i IN v_plays.FIRST..v_plays.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE('Play ID: ' || v_plays(i).play_id);
    DBMS_OUTPUT.PUT_LINE('Play Name: ' || v_plays(i).name);
    DBMS_OUTPUT.PUT_LINE('Duration (minutes): ' || v_plays(i).duration_minutes);
    DBMS_OUTPUT.PUT_LINE('Genre: ' || v_plays(i).gendre);
    DBMS_OUTPUT.PUT_LINE('Number of Actors: ' || v_plays(i).no_actors);
    DBMS_OUTPUT.PUT_LINE('Ticket Price: ' || v_plays(i).ticket_price);
    DBMS_OUTPUT.PUT_LINE('Discounted Price: ' || v_plays(i).discount_price);
    DBMS_OUTPUT.PUT_LINE('---------------------------');
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/




CREATE OR REPLACE FUNCTION IsLeadActor(p_actor_id NUMBER) 
RETURN BOOLEAN 
IS
  v_lead_actor ZActive_actors.role%TYPE;
BEGIN
  SELECT role INTO v_lead_actor
  FROM ZActive_Actors
  WHERE employee_id = p_actor_id AND role = 'lead actor';
  
  IF v_lead_actor IS NOT NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE; 
  END IF;
END;
/




CREATE OR REPLACE FUNCTION DiscountForChildren(p_play_name IN VARCHAR2)
RETURN NUMBER
IS
  v_ticket_price ZPlays.ticket_price%TYPE;
  v_discounted_price NUMBER;
BEGIN
  SELECT ticket_price INTO v_ticket_price
  FROM ZPlays
  WHERE name = p_play_name;
  
  v_discounted_price := v_ticket_price * 0.85; 
  
  RETURN v_discounted_price;
END;
/


CREATE OR REPLACE PROCEDURE DisplayAverageMinutes(p_play_name IN VARCHAR2) 
IS
  v_average_minutes NUMBER;
  v_play_minutes NUMBER;
  ex_play_too_long EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_play_too_long, -20001);
BEGIN
  SELECT AVG(duration_minutes) INTO v_average_minutes
  FROM ZPlays;

  SELECT duration_minutes INTO v_play_minutes
  FROM ZPlays
  WHERE name = p_play_name;

  DBMS_OUTPUT.PUT_LINE('The average number of minutes for plays is: ' || v_average_minutes);
  DBMS_OUTPUT.PUT_LINE('The number of minutes for play ' || p_play_name || ' is: ' || v_play_minutes);

  IF v_play_minutes > v_average_minutes THEN
    RAISE ex_play_too_long;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Play not found');
  WHEN ex_play_too_long THEN
    DBMS_OUTPUT.PUT_LINE('The play is too long for children to watch');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred');
END;
/


CREATE OR REPLACE TRIGGER ZPlays_Delete_Trigger
AFTER DELETE ON ZPlays
FOR EACH ROW
DECLARE
  v_play_name VARCHAR2(50);
BEGIN
  v_play_name := :OLD.name;
  DBMS_OUTPUT.PUT_LINE('A record with the play name "' || v_play_name || '" was deleted from ZPlays table.');
EXCEPTION
  WHEN OTHERS THEN
    NULL; 
END;
/

CREATE OR REPLACE TRIGGER Salary_Update_Trigger
BEFORE UPDATE ON ZEmployees
FOR EACH ROW
DECLARE
  v_old_salary NUMBER;
BEGIN
  v_old_salary := :OLD.salary;

  IF :NEW.salary <> v_old_salary THEN
    DBMS_OUTPUT.PUT_LINE('The salary for employee with ID ' || :NEW.employee_ID || ' is being updated.');
  END IF;
END;
/


CREATE OR REPLACE TRIGGER Insert_Update_Trigger
AFTER INSERT OR UPDATE ON ZEmployees
BEGIN
  IF INSERTING THEN
    DBMS_OUTPUT.PUT_LINE('An INSERT operation was performed on ZEmployees table.');
  ELSIF UPDATING THEN
    DBMS_OUTPUT.PUT_LINE('An UPDATE operation was performed on ZEmployees table.');
  END IF;
END;
/


CREATE OR REPLACE TRIGGER Delete_from_ZTable
AFTER DELETE ON ZActive_Actors
BEGIN
  DBMS_OUTPUT.PUT_LINE('A DELETE operation was performed on ZActive_Actors table.');
END;
/


CREATE OR REPLACE FUNCTION GetTheatrePhoneNumber(
  p_theatre_name IN VARCHAR2
) RETURN NUMBER
AS
  v_phone_number NUMBER;
BEGIN
  SELECT phone_number INTO v_phone_number
  FROM ZTheatres
  WHERE theatre_name = p_theatre_name;
END;
/


CREATE OR REPLACE PROCEDURE CalculateTheatreAge(p_theatre_id IN NUMBER)
IS
  v_opening_date DATE;
  v_years_open NUMBER;
  v_exception_msg VARCHAR2(100) := 'The building is a historic monument.';
BEGIN
  SELECT opening_date INTO v_opening_date
  FROM ZTheatres
  WHERE theatre_id = p_theatre_id;

  v_years_open := TRUNC(MONTHS_BETWEEN(SYSDATE, v_opening_date) / 12);

  IF v_years_open > 30 THEN
    RAISE_APPLICATION_ERROR(-20001, v_exception_msg);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Theatre has been open for ' || v_years_open || ' years.');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Theatre with ID ' || p_theatre_id || ' does not exist.');
END;
/



CREATE OR REPLACE PACKAGE TheatreInfo
AS
  FUNCTION GetTheatrePhoneNumber(p_theatre_name IN VARCHAR2) 
  RETURN NUMBER;
  PROCEDURE CalculateTheatreAge(p_theatre_id IN NUMBER);
END;
/

CREATE OR REPLACE PACKAGE BODY TheatreInfo
AS
  FUNCTION GetTheatrePhoneNumber( p_theatre_name IN VARCHAR2) 
  RETURN NUMBER
  IS
    v_phone_number NUMBER;
  BEGIN
    SELECT phone_number INTO v_phone_number
    FROM ZTheatres
    WHERE theatre_name = p_theatre_name;
    RETURN v_phone_number;
  END;

  PROCEDURE CalculateTheatreAge(p_theatre_id IN NUMBER)
  IS
    v_opening_date DATE;
    v_years_open NUMBER;
    v_exception_msg VARCHAR2(100) := 'The building is a historic monument.';
  BEGIN
    SELECT opening_date INTO v_opening_date
    FROM ZTheatres
    WHERE theatre_id = p_theatre_id;

    v_years_open := TRUNC(MONTHS_BETWEEN(SYSDATE, v_opening_date) / 12);

    IF v_years_open > 30 THEN
      RAISE_APPLICATION_ERROR(-20001, v_exception_msg);
    ELSE
      DBMS_OUTPUT.PUT_LINE('Theatre has been open for ' || v_years_open || ' years.');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Theatre with ID ' || p_theatre_id || ' does not exist.');
  END;
END;
/

SET SERVEROUTPUT ON
DECLARE
v_phoneno NUMBER(20);
v_theatreage NUMBER(20);
BEGIN
v_phoneno:=TheatreInfo.GetTheatrePhoneNumber('Viorea');
--v_theatreage:=TheatreInfo.CalculateTheatreAge(1);
DBMS_OUTPUT.PUT_LINE(v_phoneno);
--DBMS_OUTPUT.PUT_LINE(v_theatreage);
END;
/


