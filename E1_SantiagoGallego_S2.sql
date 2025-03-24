
/* A. Construir un procedimiento almacenado que permita, 
 dado el RUT de un medico y el periodo en proceso, 
retornar la cantidad de atenciones registradas en ese periodo por ese medico. */

CREATE OR REPLACE PROCEDURE sp_cantidad_atenciones_medico 
   (rut_medico IN VARCHAR2, 
    periodo IN VARCHAR2, 
    cantidad OUT NUMBER)
IS
BEGIN
    SELECT COUNT(ate_id)
    INTO cantidad
    FROM atencion
    WHERE med_run = rut_medico
    AND TRUNC(fecha_atencion, 'MM') = TO_DATE(periodo, 'MM-YYYY');
END sp_cantidad_atenciones_medico;

-- Probar el procedimiento
SET SERVEROUTPUT ON;
DECLARE
    v_cantidad NUMBER;
BEGIN
    cantidad_atenciones_medico('3027750', '05-2025', v_cantidad);
    DBMS_OUTPUT.PUT_LINE('Cantidad de atenciones: ' || v_cantidad);
END;

/*B. Construir una funcion almacenada que dado el ID de una unidad 
permita retornar el promedio de los sueldos de los medicos que 
pertenecen a ese cargo. */

CREATE OR REPLACE FUNCTION fnc_promedio_sueldos_cargo 
    (unidad_id IN NUMBER)
    RETURN NUMBER
IS
    v_promedio_sueldos NUMBER;
BEGIN
    SELECT ROUND(NVL(AVG(sueldo_base), 0))
    INTO v_promedio_sueldos
    FROM medico
    WHERE uni_id = unidad_id;
    
    RETURN v_promedio_sueldos;
END fnc_promedio_sueldos_cargo;

-- Probar la funcion 
SET SERVEROUTPUT ON;

DECLARE
    v_promedio NUMBER;
BEGIN
    v_promedio := fnc_promedio_sueldos_cargo(700);
    DBMS_OUTPUT.PUT_LINE('El sueldo promedio es: ' || v_promedio);
END;

/*C. Construir una funcion almacenada que dado un periodo de tiempo 
(expresado en la forma MM-YYYY) permita retornar el costo total 
de las atenciones registradas en ese periodo.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION fnc_costo_total_atenciones 
    (periodo IN VARCHAR2)
    RETURN NUMBER
IS
    v_costo_total NUMBER;
BEGIN
    SELECT NVL(SUM(costo), 0)
    INTO v_costo_total
    FROM atencion
    WHERE TRUNC(fecha_atencion, 'MM') = TO_DATE(periodo, 'MM-YYYY');
    
    RETURN v_costo_total;
END fnc_costo_total_atenciones;

-- Probar la funcion
SET SERVEROUTPUT ON;

DECLARE
    v_costo NUMBER;
BEGIN
    v_costo := fnc_costo_total_atenciones('05-2025');
    DBMS_OUTPUT.PUT_LINE('El costo total de las atenciones es: ' || v_costo);
END;

-- Primer informe

CREATE OR REPLACE PROCEDURE sp_informe_medicos 
    (unidad_id IN NUMBER, 
     periodo IN VARCHAR2)
IS
    CURSOR c_medicos IS
        SELECT m.med_run || '-' || m.dv_run AS RUT_MEDICO, 
               TRIM(m.pnombre || ' ' || NVL(m.snombre, '') || ' ' || m.apaterno || ' ' || m.amaterno) AS NOMBRE_MEDICO,
               c.nombre AS NOMBRE_CARGO, 
               NVL(u.nombre, 'Sin unidad') AS NOMBRE_UNIDAD, 
               m.sueldo_base
        FROM medico m
        JOIN cargo c ON m.car_id = c.car_id
        LEFT JOIN unidad u ON m.uni_id = u.uni_id
        WHERE m.uni_id = unidad_id;

    v_sueldo_promedio NUMBER;
    v_diferencia NUMBER;
    v_sobre_promedio VARCHAR2(2);
BEGIN
    v_sueldo_promedio := fnc_promedio_sueldos_cargo(unidad_id);
    
    FOR r_medico IN c_medicos LOOP
        v_diferencia := r_medico.sueldo_base - v_sueldo_promedio;

        IF v_diferencia >= 0 THEN
            v_sobre_promedio := 'SI';
        ELSE
            v_sobre_promedio := 'NO';
            v_diferencia := ABS(v_diferencia);
        END IF;

        INSERT INTO resumen_medico (
            rut_medico, 
            nombre_completo, 
            nombre_cargo, 
            nombre_unidad, 
            sueldo_base, 
            diferencia_cargo, 
            sobre_promedio
        ) VALUES (
            r_medico.RUT_MEDICO, 
            r_medico.NOMBRE_MEDICO, 
            r_medico.NOMBRE_CARGO, 
            r_medico.NOMBRE_UNIDAD, 
            r_medico.sueldo_base, 
            v_diferencia, 
            v_sobre_promedio
        );
    END LOOP;
END sp_informe_medicos;

-- Insertar los datos en la tabla
BEGIN
    sp_informe_medicos(700, '202306');
END;

--Segundo informe

CREATE OR REPLACE FUNCTION fnc_costo_atenciones_medico
    (rut_medico IN VARCHAR2, 
     periodo IN VARCHAR2)
RETURN NUMBER
IS
    v_costo_medico NUMBER;
BEGIN
    SELECT NVL(SUM(costo), 0)
    INTO v_costo_medico
    FROM atencion
    WHERE med_run = rut_medico
    AND TRUNC(fecha_atencion, 'MM') = TO_DATE(periodo, 'MM/YYYY');
    
    RETURN v_costo_medico;
END fnc_costo_atenciones_medico;



CREATE OR REPLACE PROCEDURE sp_informe_atenciones 
    (unidad_id IN NUMBER, 
     periodo IN VARCHAR2)
IS
    CURSOR c_medicos IS
        SELECT m.med_run || '-' || m.dv_run AS RUT_MEDICO, 
               TRIM(m.pnombre || ' ' || NVL(m.snombre, '') || ' ' || m.apaterno || ' ' || m.amaterno) AS NOMBRE_MEDICO
        FROM medico m
        WHERE m.uni_id = unidad_id;

    v_costo_total NUMBER;
    v_proporcion NUMBER;
    v_cantidad NUMBER;
    v_costo_medico NUMBER;

BEGIN
    v_costo_total := fnc_costo_total_atenciones(periodo);

    IF v_costo_total = 0 THEN
        v_costo_total := 1;
    END IF;

    FOR r_medico IN c_medicos LOOP
        sp_cantidad_atenciones_medico(r_medico.RUT_MEDICO, periodo, v_cantidad);

        v_costo_medico := fnc_costo_atenciones_medico(r_medico.RUT_MEDICO, periodo);
        IF v_costo_total > 0 THEN
            v_proporcion := (v_costo_medico / v_costo_total) * 100;
        ELSE
            v_proporcion := 0;
        END IF;

        INSERT INTO detalle_atenciones (
            rut_medico, 
            periodo, 
            total_atenciones, 
            costo_atenciones, 
            tasa_aporte_periodo
        ) VALUES (
            r_medico.RUT_MEDICO, 
            periodo, 
            v_cantidad, 
            v_costo_medico, 
            v_proporcion
        );
    END LOOP;
END sp_informe_atenciones;













