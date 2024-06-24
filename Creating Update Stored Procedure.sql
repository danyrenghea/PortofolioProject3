/*Stages for building a Stored Procedure in order to update a table in the greecycles
data base, keeping the record history for the old and new salary of each employee
with a constraint of unicity on emp_id and update_time columns*/

--Create a transition table named employees_audit
--that keeps records of old and new salaries updated

CREATE TABLE employees_audit (
    audit_id SERIAL PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL,
    new_salary DECIMAL,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_emp_id_update_time UNIQUE (emp_id, update_time)
);

--Stored procedure for udating salaries
CREATE OR REPLACE PROCEDURE emp_salary_update()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Updating salaries for emp_id NOT IN (2, 3)
    UPDATE employees
    SET salary = salary * 1.05
    WHERE emp_id BETWEEN 1 AND 27 AND emp_id NOT IN (2, 3);

    -- Recording of the new and old salaries values for emp_id NOT IN (2, 3)
    INSERT INTO employees_audit (emp_id, old_salary, new_salary)
    SELECT emp_id, salary / 1.05, salary
    FROM employees
    WHERE emp_id BETWEEN 1 AND 27 AND emp_id NOT IN (2, 3)
    ON CONFLICT (emp_id, update_time) DO NOTHING;

    -- Updating salaries for emp_id IN (2, 3)
    UPDATE employees
    SET salary = salary * 1.10
    WHERE emp_id IN (2, 3);

    -- Recording of the new and old salaries values for emp_id IN (2, 3)
    INSERT INTO employees_audit (emp_id, old_salary, new_salary)
    SELECT emp_id, salary / 1.10, salary
    FROM employees
    WHERE emp_id IN (2, 3)
    ON CONFLICT (emp_id, update_time) DO NOTHING;
END;
$$;

--Adding constrains of foreign key
ALTER TABLE employees_audit
ADD CONSTRAINT fk_emp_id
FOREIGN KEY (emp_id)
REFERENCES employees(emp_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

--Visualizing of the updated salaries and the audit
SELECT e.emp_id, ea.audit_id, ea.new_salary, ea.old_salary 
FROM employees e
JOIN employees_audit ea ON e.emp_id = ea.emp_id
ORDER BY ea.audit_id;



