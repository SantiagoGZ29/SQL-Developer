/*
PARTE I:
La primera modificaci�n, para el m�dulo de gesti�n de clientes, 
es mantener actualizado el resumen del total de clientes por profesi�n que se 
encuentra guardado en la tabla RESUMEN_PROFESION. La idea es que cuando se inserta
un nuevo cliente, o cuando se cambie el c�digo de la profesi�n de un cliente, se mantiene
de manera consistente lo almacenado en la tabla RESUMEN_PROFESION.
*/

CREATE OR REPLACE TRIGGER trg_actualiza_profesion
AFTER INSERT OR UPDATE OF cod_prof_ofic ON cliente
FOR EACH ROW
DECLARE 
    v_existe NUMBER := 0;
    v_nombre_profesion PROFESION_OFICIO.NOMBRE_PROF_OFIC%TYPE;
BEGIN
    -- Verificar si ya existe esa profesi�n en el resumen
    SELECT COUNT(*) INTO v_existe
    FROM resumen_profesion
    WHERE id_profesion = :NEW.cod_prof_ofic;

    -- Obtener el nombre de la profesi�n desde la tabla de referencia
    SELECT nombre_prof_ofic INTO v_nombre_profesion
    FROM profesion_oficio
    WHERE cod_prof_ofic = :NEW.cod_prof_ofic;

    IF v_existe > 0 THEN
        IF INSERTING THEN
            UPDATE resumen_profesion
            SET total_clientes = total_clientes + 1
            WHERE id_profesion = :NEW.cod_prof_ofic;
        ELSIF UPDATING THEN
            -- Restar a la profesi�n anterior y sumar a la nueva si cambi� el c�digo
            IF :OLD.cod_prof_ofic != :NEW.cod_prof_ofic THEN
                UPDATE resumen_profesion
                SET total_clientes = total_clientes - 1
                WHERE id_profesion = :OLD.cod_prof_ofic;

                UPDATE resumen_profesion
                SET total_clientes = total_clientes + 1
                WHERE id_profesion = :NEW.cod_prof_ofic;
            END IF;
        END IF;
    ELSE
        -- Insertar nueva profesi�n en el resumen
        INSERT INTO resumen_profesion (id_profesion, nombre_profesion, total_clientes)
        VALUES (:NEW.cod_prof_ofic, v_nombre_profesion, 1);
    END IF;
END trg_actualiza_profesion;

-- Probar el Trigger
UPDATE cliente
SET cod_prof_ofic = 19
WHERE nro_cliente = 16;

INSERT INTO cliente (
    nro_cliente,
    numrun,
    dvrun,
    pnombre,
    snombre,
    appaterno,
    apmaterno,
    fecha_nacimiento,
    fecha_inscripcion,
    correo,
    fono_contacto,
    direccion,
    cod_region,
    cod_provincia,
    cod_comuna,
    cod_prof_ofic,
    cod_tipo_cliente
) VALUES (
    131,
    6016402,
    '9',
    'MARIO',
    NULL,
    'MONDACA',
    'BERRIOS',
    TO_DATE('19/12/1957', 'DD/MM/YYYY'),
    TO_DATE('29/03/1987', 'DD/MM/YYYY'),
    NULL,
    NULL,
    'Avda. presidente Riesco 234',
    13,
    1,
    14,
    20,
    2
);

/*
PARTE II
Se requiere generar un informe resumen de los clientes considerando la 
cantidad de productos de inversi�n que han contratado; considerando esta 
cantidad se establece un rango de inversi�n que ya ha sido definido y se 
encuentra almacenado en la base de datos (ver reglas de negocio)
Es requerimiento que la generaci�n del informe se ejecute sin problemas 
las veces que sea necesario y considerando una determinada regi�n; esto se 
debe manejar como una constante dentro del package (ver requerimiento de dise�o 
de la construcci�n).
*/

/*
•	Construir una FUNCIÓN ALMACENADA que, dado el mes de inscripción 
de un cliente, retorne el mensaje asociado que se deberá guardar en la
 tabla RESUMEN_CLIENTE.
*/


CREATE OR REPLACE FUNCTION fn_mensaje_inscripcion(p_mes_inscripcion IN NUMBER)
RETURN VARCHAR2 IS
    v_mensaje VARCHAR2(100);
BEGIN
    -- Comparar el mes de inscripción con el mes actual
    IF LPAD(p_mes_inscripcion, 2, '0') = TO_CHAR(SYSDATE, 'MM') THEN
        v_mensaje := 'MES ANIVERSARIO';
    ELSE
        v_mensaje := 'NO ANIVERSARIO';
    END IF;

    -- Devolver el mensaje
    RETURN v_mensaje;
END fn_mensaje_inscripcion;


-- Probar la función
SELECT fn_mensaje_inscripcion(5) AS mensaje
FROM dual;

/*
•	Construir un PACKAGE que contenga:
o	Una variable que almacene el ID de la región que va a procesar 
    el informe.
o	Una función pública que, dado el número de cliente retorne 
    el total de productos de inversión que tiene registrados en cliente.
o	Un procedimiento público que permita insertar un registro en la
     tabla RESUMEN_CLIENTE.
*/

CREATE OR REPLACE PACKAGE pkg_resumen_cliente IS
    -- Variable para almacenar el ID de la región
    v_cod_region NUMBER;

    -- Función pública que retorna el total de productos de inversión
    FUNCTION fn_total_productos_inversion(p_nro_cliente IN NUMBER) RETURN NUMBER;

    -- Procedimiento público para insertar un registro en RESUMEN_CLIENTE
    PROCEDURE sp_insertar_resumen_cliente(
        p_rut_cliente        IN VARCHAR2,
        p_region_residencia  IN VARCHAR2,
        p_mes_inscripcion    IN NUMBER,
        p_mensaje            IN VARCHAR2,
        p_nro_cliente        IN NUMBER
    );
END pkg_resumen_cliente;

CREATE OR REPLACE PACKAGE BODY pkg_resumen_cliente IS

    -- Función para contar productos de inversión usando SQL dinámico
    FUNCTION fn_total_productos_inversion(p_nro_cliente IN NUMBER) RETURN NUMBER IS
        v_total_productos NUMBER;
        v_sql VARCHAR2(1000);
    BEGIN
        v_sql := 'SELECT COUNT(cod_prod_inv) FROM producto_inversion_cliente WHERE nro_cliente = :1';
        EXECUTE IMMEDIATE v_sql INTO v_total_productos USING p_nro_cliente;
        RETURN v_total_productos;
    END fn_total_productos_inversion;

    -- Procedimiento para insertar un resumen en la tabla
    PROCEDURE sp_insertar_resumen_cliente(
        p_rut_cliente        IN VARCHAR2,
        p_region_residencia  IN VARCHAR2,
        p_mes_inscripcion    IN NUMBER,
        p_mensaje            IN VARCHAR2,
        p_nro_cliente        IN NUMBER
    ) IS
        v_sql VARCHAR2(1000);
        v_cantidad_inversiones NUMBER;
        v_rango_inversion VARCHAR2(1);
        v_error_mensaje VARCHAR2(4000);
    BEGIN
        BEGIN
            -- Obtener cantidad de inversiones
            v_cantidad_inversiones := fn_total_productos_inversion(p_nro_cliente);

            -- Determinar rango de inversión
            IF v_cantidad_inversiones > 0 AND v_cantidad_inversiones <= 3 THEN
                v_rango_inversion := 'A';
            ELSIF v_cantidad_inversiones > 3 AND v_cantidad_inversiones <= 5 THEN
                v_rango_inversion := 'B';
            ELSIF v_cantidad_inversiones > 5 AND v_cantidad_inversiones <= 7 THEN
                v_rango_inversion := 'C';
            ELSE
                RAISE NO_DATA_FOUND;  -- Rango fuera de lo esperado
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_error_mensaje := SQLERRM;
                INSERT INTO error_proceso(id_error, descripcion, mensaje_oracle)
                VALUES (seq_error.NEXTVAL, 'Imposible rescatar rango', v_error_mensaje);
                v_rango_inversion := '*';
        END;

        -- SQL dinámico para insertar en RESUMEN_CLIENTE
        v_sql := 'INSERT INTO RESUMEN_CLIENTE 
                 (rut_cliente, region_residencia, mes_inscripcion, mensaje, cantidad_inversiones, rango_inversion)
                  VALUES (:1, :2, :3, :4, :5, :6)';

        EXECUTE IMMEDIATE v_sql USING
            p_rut_cliente,
            p_region_residencia,
            p_mes_inscripcion,
            p_mensaje,
            v_cantidad_inversiones,
            v_rango_inversion;

    END sp_insertar_resumen_cliente;

END pkg_resumen_cliente;


-- Probar el package
BEGIN
    pkg_resumen_cliente.sp_insertar_resumen_cliente(
        p_rut_cliente       => '12345678-9',
        p_region_residencia => 'Metropolitana',
        p_mes_inscripcion   => 5,
        p_mensaje           => 'Cliente con inversiones activas',
        p_nro_cliente       => 19 -- Usa un nro_cliente válido existente
    );
END;

ROLLBACK;


/*
•	Construir un PROCEDIMIENTO ALMACENADO principal que permita,
 dado el ID de la región (guardado en la variable del package) generar 
 el resumen de los clientes. El resumen para cada cliente deben ser 
 almacenado en la tabla RESUMEN_CLIENTE.
*/

CREATE OR REPLACE PROCEDURE sp_generar_resumen_cliente (v_cod_region IN NUMBER) 
IS
    -- Cursor para obtener los clientes de la región especificada
    CURSOR c_clientes 
    IS
        SELECT  c.nro_cliente, 
                c.numrun ||'-'|| c.dvrun AS rut_cliente,
                r. nombre_region,
                TO_CHAR(c.fecha_inscripcion, 'MM') AS mes_inscripcion
        FROM cliente c
        JOIN region r ON c.cod_region = r.cod_region
        WHERE c.cod_region = v_cod_region;
    
    v_nro_cliente CLIENTE.nro_cliente%TYPE;
    v_rut_cliente VARCHAR2(20); 
    v_region_residencia REGION.nombre_region%TYPE;
    v_mes_inscripcion VARCHAR2(2);
    v_mensaje VARCHAR2(100);
    v_cantidad_inversiones NUMBER;
    v_rango_inversion VARCHAR2(1);
    v_error_mensaje VARCHAR2(4000);
BEGIN
    -- Limpiar la tabla RESUMEN_CLIENTE antes de insertar nuevos datos
    EXECUTE IMMEDIATE 'TRUNCATE TABLE RESUMEN_CLIENTE';
    -- Recorrer el cursor para procesar cada cliente
    FOR r_cliente IN c_clientes LOOP
        v_nro_cliente := r_cliente.nro_cliente;
        v_rut_cliente := r_cliente.rut_cliente;
        v_region_residencia := r_cliente.nombre_region;
        v_mes_inscripcion := r_cliente.mes_inscripcion;

    -- obtener el mensaje de inscripción
        v_mensaje := fn_mensaje_inscripcion(TO_NUMBER(v_mes_inscripcion));

        -- Llamar al procedimiento para insertar el resumen del cliente
        pkg_resumen_cliente.sp_insertar_resumen_cliente(
            p_rut_cliente        => v_rut_cliente,
            p_region_residencia  => v_region_residencia,
            p_mes_inscripcion    => TO_NUMBER(v_mes_inscripcion),
            p_mensaje            => v_mensaje,
            p_nro_cliente        => v_nro_cliente
        );

    END LOOP;
END sp_generar_resumen_cliente;

-- Probar el procedimiento
BEGIN
    sp_generar_resumen_cliente(6); 
END;


    
    
    





























