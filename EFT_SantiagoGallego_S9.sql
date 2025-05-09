/*
Evaluacion final transversal

PROCESO 1:
Implementar un trigger para que cada vez que se cambie el sueldo 
de un vendedor este cambio se vea reflejado, de forma automática, en 
la tabla que lleva la bitácora de los cambios.
*/
CREATE OR REPLACE TRIGGER trg_sueldo_vendedor
AFTER UPDATE OF sueldo_base ON vendedor
FOR EACH ROW
BEGIN
    INSERT INTO bitacora 
    (id_bitacora, rutvendedor, anterior, actual,variacion)
    VALUES 
    (SEQ_BITACORA.NEXTVAL,:OLD.rutvendedor, :OLD.sueldo_base, :NEW.sueldo_base, :NEW.sueldo_base - :OLD.sueldo_base);
    
END trg_sueldo_vendedor;

/*
Probar el trigger:
•	Cambiar el sueldo del empleado con RUT 10656569-K a $500.000
•	Cambiar el sueldo del empleado con RUT 12456778-1 a $450.000
*/

UPDATE 
    vendedor SET sueldo_base = 500000 WHERE rutvendedor = '10656569-K';
UPDATE 
    vendedor SET sueldo_base = 450000 WHERE rutvendedor = '12456778-1';


/*
PROCESO 2:
a.	Construir un package que contenga una función pública, 
un procedimiento público y 3 variables públicas. 
•	Una función pública que permita, dado el RUT del vendedor, 
retornar el monto de ventas en boletas del vendedor del año en proceso. 
•	Un procedimiento público que permita administrar e insertar los
 errores ocurridos durante el proceso principal y en cada subrutina 
 del proceso. Utilizar Native Dynamic SQL para poblar la tabla: 
 ERROR_PROCESOS_MENSUALES.  
•	Las variables públicas las define usted considerando que UNA DE 
ELLAS debe almacenar el año en proceso. 
*/

CREATE OR REPLACE PACKAGE pkg_ventas_vendedor AS
    -- Variables públicas
    v_anio_proceso NUMBER := 2022; -- Año en proceso
    v_rut_vendedor VARCHAR2(20); -- RUT del vendedor
    v_monto_ventas NUMBER; -- Monto de ventas en boletas

    -- Función pública para obtener el monto de ventas en boletas del vendedor
    FUNCTION fn_monto_ventas(p_rutvendedor IN VARCHAR2) RETURN NUMBER;

    -- Procedimiento público para administrar e insertar errores
    PROCEDURE sp_administrar_error(p_rutina IN VARCHAR2, p_error_msg IN VARCHAR2);
END pkg_ventas_vendedor;

-- Body del package
CREATE OR REPLACE PACKAGE BODY pkg_ventas_vendedor AS

    -- Función pública para obtener el monto de ventas en boletas del vendedor
    FUNCTION fn_monto_ventas(p_rutvendedor IN VARCHAR2) RETURN NUMBER IS
        v_monto NUMBER;
    BEGIN
        SELECT SUM(total) INTO v_monto
        FROM boleta
        WHERE rutvendedor = p_rutvendedor 
          AND EXTRACT(YEAR FROM fecha) = v_anio_proceso;
        
        RETURN NVL(v_monto, 0); -- Retorna 0 si no hay ventas
    END fn_monto_ventas;

    -- Procedimiento para registrar errores con SQL dinámico
    PROCEDURE sp_administrar_error(p_rutina IN VARCHAR2, p_error_msg IN VARCHAR2) IS
        v_sql VARCHAR2(1000);
    BEGIN
        v_sql := 
            'INSERT INTO ERROR_PROCESOS_MENSUALES (correl_error, rutina_error, descrip_error) ' ||
            'VALUES (SEQ_ERROR.NEXTVAL, :1, :2)';

        EXECUTE IMMEDIATE v_sql USING p_rutina, p_error_msg;

    END sp_administrar_error;

END pkg_ventas_vendedor;

-- Probar el package
-- Obtener el monto de ventas en boletas del vendedor con RUT 10456789-4
SET SERVEROUTPUT ON;
DECLARE
    v_monto NUMBER;
BEGIN
    v_monto := pkg_ventas_vendedor.fn_monto_ventas('10456789-4');
    DBMS_OUTPUT.PUT_LINE('Monto de ventas en boletas del vendedor 10456789-4: ' || v_monto);
END;

/*
b. Construir una función almacenada que dado el año permita retornar el 
monto total de ventas realizadas (en boletas) ese año. 
*/

CREATE OR REPLACE FUNCTION fn_monto_total_ventas(p_anio IN NUMBER) RETURN NUMBER IS
    v_monto_total NUMBER;
BEGIN
    SELECT SUM(total) INTO v_monto_total
    FROM boleta
    WHERE EXTRACT(YEAR FROM fecha) = p_anio;
    
    RETURN NVL(v_monto_total, 0); -- Retorna 0 si no hay ventas
END fn_monto_total_ventas;

-- Probar la función
SET SERVEROUTPUT ON;
DECLARE
    v_monto_total NUMBER;
BEGIN
    v_monto_total := fn_monto_total_ventas(pkg_ventas_vendedor.v_anio_proceso);
    DBMS_OUTPUT.PUT_LINE('Monto total de ventas en boletas del anio 2022: ' || v_monto_total);
END;

/*
c.	Construir un procedimiento almacenado para generar el informe 
en la tabla PORCENTAJE_VENDEDOR. Este procedimiento debe integrar 
el uso de los constructores del package y la función almacenada para 
construir la solución requerida, utilizando SQL dinámico para truncar
 la tabla de errores.
*/

CREATE OR REPLACE PROCEDURE sp_generar_informe IS
    v_sql VARCHAR2(1000);
    v_total_ventas NUMBER;

    v_anio NUMBER := pkg_ventas_vendedor.v_anio_proceso;
    v_rutvendedor VARCHAR2(20);
    v_nomvendedor VARCHAR2(100);
    v_comuna VARCHAR2(60);
    v_sueldo_base NUMBER;
    v_aporte_ventas NUMBER;

    CURSOR c_vendedores IS
        SELECT v.rutvendedor, v.nombre, c.descripcion, v.sueldo_base
        FROM vendedor v
        JOIN comuna c ON v.codcomuna = c.codcomuna;
BEGIN
    -- Truncar la tabla de errores usando SQL dinámico
    v_sql := 'TRUNCATE TABLE ERROR_PROCESOS_MENSUALES';
    EXECUTE IMMEDIATE v_sql;

    -- Calcular total de ventas del año
    v_total_ventas := fn_monto_total_ventas(v_anio);

    -- Recorrer cada vendedor
    FOR r_vendedor IN c_vendedores LOOP
        BEGIN
            v_rutvendedor := r_vendedor.rutvendedor;
            v_nomvendedor := r_vendedor.nombre;
            v_comuna := r_vendedor.descripcion;
            v_sueldo_base := r_vendedor.sueldo_base;
            
            -- Calcular aporte en ventas
            v_aporte_ventas := pkg_ventas_vendedor.fn_monto_ventas(v_rutvendedor) / v_total_ventas;

            -- Insertar en la tabla de informe
            INSERT INTO porcentaje_vendedor (anio,rutvendedor, nomvendedor, comuna, sueldo_base, aporte_ventas)
            VALUES (v_anio,v_rutvendedor, v_nomvendedor, v_comuna, v_sueldo_base, v_aporte_ventas);

        EXCEPTION
            WHEN OTHERS THEN
                pkg_ventas_vendedor.sp_administrar_error('sp_generar_informe', SQLERRM);
        END;
    END LOOP;

END sp_generar_informe;

-- Bloque anonimo para ejecutar el procedimiento e insertar los datos en la tabla
BEGIN
    sp_generar_informe;
END;







    


    


    

































