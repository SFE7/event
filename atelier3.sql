--ex 1.1 Permuter les salaires des employés 120 et 122
DECLARE
    v_sal_120 employees.salary%TYPE;
    v_sal_122 employees.salary%TYPE;
BEGIN
    SELECT salary INTO v_sal_120 FROM employees WHERE employee_id = 120;
    SELECT salary INTO v_sal_122 FROM employees WHERE employee_id = 122;

    UPDATE employees SET salary = v_sal_122 WHERE employee_id = 120;
    UPDATE employees SET salary = v_sal_120 WHERE employee_id = 122;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salaires des employés 120 et 122 permutés avec succès.');
END;
/

--ex 1.2 Augmenter le salaire de l'employé 115 (CASE)
DECLARE
    v_experience NUMBER;
BEGIN
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date) / 12)
    INTO v_experience
    FROM employees
    WHERE employee_id = 115;

    UPDATE employees
    SET salary = salary * CASE
        WHEN v_experience > 10 THEN 1.20
        WHEN v_experience > 5  THEN 1.10
        ELSE 1.05
    END
    WHERE employee_id = 115;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salaire de l''employé 115 mis à jour (expérience : ' || v_experience || ' ans).');
END;
/

--ex 1.3 Changer le pourcentage de commission de l'employé 150 (IF)
DECLARE
    v_salary     employees.salary%TYPE;
    v_experience NUMBER;
BEGIN
    SELECT salary, FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date) / 12)
    INTO v_salary, v_experience
    FROM employees
    WHERE employee_id = 150;

    IF v_salary > 10000 THEN
        UPDATE employees SET commission_pct = 0.40 WHERE employee_id = 150;
        DBMS_OUTPUT.PUT_LINE('Commission fixée à 40%.');
    ELSIF v_salary < 10000 AND v_experience > 10 THEN
        UPDATE employees SET commission_pct = 0.35 WHERE employee_id = 150;
        DBMS_OUTPUT.PUT_LINE('Commission fixée à 35%.');
    ELSE
        UPDATE employees SET commission_pct = 0.15 WHERE employee_id = 150;
        DBMS_OUTPUT.PUT_LINE('Commission fixée à 15%.');
    END IF;

    COMMIT;
END;
/

--ex 1.4 Trouver le nom de l'employé et le nom du département du manager de l'employé 103
DECLARE
    v_emp_name  VARCHAR2(100);
    v_dept_name departments.department_name%TYPE;
BEGIN
    SELECT e.first_name || ' ' || e.last_name, d.department_name
    INTO v_emp_name, v_dept_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.employee_id = (
        SELECT manager_id FROM employees WHERE employee_id = 103
    );

    DBMS_OUTPUT.PUT_LINE('Manager : ' || v_emp_name);
    DBMS_OUTPUT.PUT_LINE('Département : ' || v_dept_name);
END;
/

--ex 2.1 Max quantité en stock et mise à jour du prix de l'article 1
DECLARE
    v_max_qty  Articles.Qte_Stock%TYPE;
    v_qty_art1 Articles.Qte_Stock%TYPE;
    v_prix     Articles.Prix_Unitaire%TYPE;
BEGIN
    SELECT MAX(Qte_Stock) INTO v_max_qty  FROM Articles;
    SELECT Qte_Stock      INTO v_qty_art1 FROM Articles WHERE Num_Article = 1;

    DBMS_OUTPUT.PUT_LINE('Quantité maximale en stock : ' || v_max_qty);

    IF v_max_qty > v_qty_art1 THEN
        UPDATE Articles SET Prix_Unitaire = Prix_Unitaire * 0.90 WHERE Num_Article = 1;
        DBMS_OUTPUT.PUT_LINE('Prix de l''article 1 diminué de 10%.');
    ELSE
        UPDATE Articles SET Prix_Unitaire = Prix_Unitaire * 1.20 WHERE Num_Article = 1;
        DBMS_OUTPUT.PUT_LINE('Prix de l''article 1 augmenté de 20%.');
    END IF;

    COMMIT;

    -- Vérification
    SELECT Prix_Unitaire INTO v_prix FROM Articles WHERE Num_Article = 1;
    DBMS_OUTPUT.PUT_LINE('Nouveau prix de l''article 1 : ' || v_prix);
END;
/

--ex 2.2 Afficher la désignation de l'article 10 avec gestion d'exception
DECLARE
    v_designation Articles.Designation%TYPE;
BEGIN
    SELECT Designation INTO v_designation FROM Articles WHERE Num_Article = 10;
    DBMS_OUTPUT.PUT_LINE('Désignation : ' || v_designation);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('cet article n''est pas enregistré');
END;
/

--ex 2.3 Modifications sur le produit numéro 3
DECLARE
    v_qty Articles.Qte_Stock%TYPE;
BEGIN
    SELECT Qte_Stock INTO v_qty FROM Articles WHERE Num_Article = 3;

    IF v_qty >= 10 THEN
        UPDATE Articles SET Prix_Unitaire = Prix_Unitaire * 2 WHERE Num_Article = 3;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Prix unitaire du produits N : 3 est multiplié par deux');
    ELSE
        DELETE FROM Articles WHERE Num_Article = 3;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Le produit N : 3 est supprimé');
    END IF;
END;
/

--ex 3 Calculer le max des prix avec une boucle While
DECLARE
    v_num      NUMBER := 1;
    v_prix     Articles.Prix_Unitaire%TYPE;
    v_max_prix Articles.Prix_Unitaire%TYPE := 0;
    v_count    NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Articles;

    WHILE v_num <= v_count LOOP
        SELECT Prix_Unitaire INTO v_prix FROM Articles WHERE Num_Article = v_num;
        IF v_prix > v_max_prix THEN
            v_max_prix := v_prix;
        END IF;
        v_num := v_num + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Prix maximum des articles : ' || v_max_prix);
END;
/

--ex 4.1 Nombre total de voitures, voitures rouges et pourcentage avec exceptions
DECLARE
    v_total       NUMBER;
    v_rouge       NUMBER;
    v_pourcentage NUMBER;
    e_no_cars     EXCEPTION;
    e_no_red_cars EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_total FROM voitures;

    IF v_total = 0 THEN
        RAISE e_no_cars;
    END IF;

    SELECT COUNT(*) INTO v_rouge FROM voitures WHERE couleur = 'rouge';

    IF v_rouge = 0 THEN
        RAISE e_no_red_cars;
    END IF;

    v_pourcentage := ROUND((v_rouge / v_total) * 100, 2);

    DBMS_OUTPUT.PUT_LINE('Nombre total de voitures : ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Nombre de voitures rouges : ' || v_rouge);
    DBMS_OUTPUT.PUT_LINE('Pourcentage de voitures rouges : ' || v_pourcentage || '%');
EXCEPTION
    WHEN e_no_cars THEN
        DBMS_OUTPUT.PUT_LINE('La base de données ne contient aucune voiture.');
    WHEN e_no_red_cars THEN
        DBMS_OUTPUT.PUT_LINE('La base de données ne contient aucune voiture de couleur rouge.');
END;
/

--ex 4.2 Procédure qui affiche le pourcentage de voitures d'une couleur donnée
CREATE OR REPLACE PROCEDURE pourcentage_couleur(p_couleur IN VARCHAR2) IS
    v_total       NUMBER;
    v_count       NUMBER;
    v_pourcentage NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM voitures;
    SELECT COUNT(*) INTO v_count FROM voitures WHERE couleur = p_couleur;

    IF v_total = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucune voiture dans la base de données.');
    ELSE
        v_pourcentage := ROUND((v_count / v_total) * 100, 2);
        DBMS_OUTPUT.PUT_LINE('Pourcentage de voitures de couleur ' || p_couleur || ' : ' || v_pourcentage || '%');
    END IF;
END;
/

--ex 5.1 Année avec le maximum de recrutements et détail par mois
DECLARE
    v_year NUMBER;
    CURSOR c_months IS
        SELECT TO_NUMBER(TO_CHAR(hire_date, 'MM')) AS mois,
               COUNT(*) AS nb_employes
        FROM employees
        WHERE TO_NUMBER(TO_CHAR(hire_date, 'YYYY')) = v_year
        GROUP BY TO_CHAR(hire_date, 'MM')
        ORDER BY mois;
BEGIN
    SELECT TO_NUMBER(TO_CHAR(hire_date, 'YYYY'))
    INTO v_year
    FROM employees
    GROUP BY TO_CHAR(hire_date, 'YYYY')
    HAVING COUNT(*) = (
        SELECT MAX(COUNT(*)) FROM employees GROUP BY TO_CHAR(hire_date, 'YYYY')
    );

    DBMS_OUTPUT.PUT_LINE('Année avec le maximum de recrutements : ' || v_year);

    FOR rec IN c_months LOOP
        DBMS_OUTPUT.PUT_LINE('Mois ' || rec.mois || ' : ' || rec.nb_employes || ' employé(s) recrutés.');
    END LOOP;
END;
/

--ex 5.2 Changer le salaire de l'employé 130 par le salaire de l'employé prénommé 'Ali'
DECLARE
    v_count  NUMBER;
    v_salary employees.salary%TYPE;
BEGIN
    SELECT COUNT(*) INTO v_count FROM employees WHERE first_name = 'Ali';

    IF v_count = 0 THEN
        SELECT AVG(salary) INTO v_salary FROM employees;
        DBMS_OUTPUT.PUT_LINE('Aucun employé Ali, utilisation de la moyenne : ' || v_salary);
    ELSIF v_count > 1 THEN
        SELECT MIN(salary) INTO v_salary FROM employees WHERE first_name = 'Ali';
        DBMS_OUTPUT.PUT_LINE('Plusieurs employés Ali, utilisation du salaire minimum : ' || v_salary);
    ELSE
        SELECT salary INTO v_salary FROM employees WHERE first_name = 'Ali';
        DBMS_OUTPUT.PUT_LINE('Salaire de Ali : ' || v_salary);
    END IF;

    UPDATE employees SET salary = v_salary WHERE employee_id = 130;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salaire de l''employé 130 mis à jour : ' || v_salary);
END;
/

--ex 5.3 Fonction retournant le nom du manager d'un département
CREATE OR REPLACE FUNCTION get_manager_name(p_dept_id IN NUMBER) RETURN VARCHAR2 IS
    v_manager_name VARCHAR2(100);
BEGIN
    SELECT e.first_name || ' ' || e.last_name
    INTO v_manager_name
    FROM employees e
    JOIN departments d ON e.employee_id = d.manager_id
    WHERE d.department_id = p_dept_id;

    RETURN v_manager_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Aucun manager trouvé pour ce département';
END;
/

--ex 5.4 Fonction retournant le nombre de métiers exercés par un employé (Job_History)
CREATE OR REPLACE FUNCTION get_nb_jobs(p_emp_id IN NUMBER) RETURN NUMBER IS
    v_nb NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_nb FROM job_history WHERE employee_id = p_emp_id;
    RETURN v_nb;
END;
/
