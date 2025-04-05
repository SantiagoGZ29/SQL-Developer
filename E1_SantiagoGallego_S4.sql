/*
Actividad sumativa 1:

1.Construir una funcion almacenada que permita, 
dado la cantidad de unidades vendidas 
de un producto, retornar el porcentaje asociado rescatado 
desde la tabla TRAMO_PRECIO.  
*/

CREATE OR REPLACE FUNCTION fn_porcentaje_vendido
(p_unidades_vendidas IN NUMBER)
RETURN NUMBER IS
    v_porcentaje NUMBER;
BEGIN
    SELECT porcentaje INTO v_porcentaje
    FROM TRAMO_PRECIO
    WHERE p_unidades_vendidas BETWEEN valor_minimo AND valor_maximo;
    
    RETURN v_porcentaje;
END fn_porcentaje_vendido;

/*
Segundo: Construir un procedimiento almacenado que permita, dado el código de 
un producto y un período de tiempo, retornar la cantidad de boletas en 
las que ha sido incluido el producto y el total de unidades vendidas 
del producto en el período de tiempo indicado.  
*/

CREATE OR REPLACE PROCEDURE sp_detalle_producto
(p_codproducto IN NUMBER, p_periodo IN VARCHAR2,
p_cantidad_boletas OUT NUMBER, p_total_unidades OUT NUMBER) 
IS
    v_cantidad_boletas NUMBER;
    v_total_unidades NUMBER;
BEGIN
    SELECT COUNT(DISTINCT b.numboleta), SUM(db.cantidad)
    INTO v_cantidad_boletas, v_total_unidades
    FROM boleta b
    JOIN detalle_boleta db ON b.numboleta = db.numboleta
    WHERE db.codproducto = p_codproducto
    AND TO_CHAR(b.fecha, 'MM-YYYY') = p_periodo;
    
    p_cantidad_boletas := v_cantidad_boletas;
    p_total_unidades := v_total_unidades;

END sp_detalle_producto;

/*
3.	Construir una función almacenada que permita, dado el RUT de un 
cliente y un período de tiempo, retornar la cantidad de boletas que 
han sido emitidas a su nombre durante el período de tiempo indicado.  
*/

CREATE OR REPLACE FUNCTION fn_boletas_cliente
(p_rutcliente IN VARCHAR2, p_periodo IN VARCHAR2)
RETURN NUMBER IS
    v_cantidad_boletas NUMBER;
BEGIN
    SELECT COUNT(numboleta)
    INTO v_cantidad_boletas
    FROM boleta
    WHERE rutcliente = p_rutcliente
    AND TO_CHAR(fecha, 'MM-YYYY') = p_periodo;
    
    RETURN v_cantidad_boletas;
END fn_boletas_cliente;

/*
4.	Construir una funcion almacenada que permita, dado el RUT de 
un cliente y un periodo de tiempo, retornar la cantidad de facturas que 
han sido emitidas a su nombre durante el periodo de tiempo indicado.  
*/

CREATE OR REPLACE FUNCTION fn_facturas_cliente
(p_rutcliente IN VARCHAR2, p_periodo IN VARCHAR2)
RETURN NUMBER IS
    v_cantidad_facturas NUMBER;
BEGIN   
    SELECT COUNT(numfactura)
    INTO v_cantidad_facturas
    FROM factura
    WHERE rutcliente = p_rutcliente
    AND TO_CHAR(fecha, 'MM-YYYY') = p_periodo;
    
    RETURN v_cantidad_facturas;
END fn_facturas_cliente;

/*
5.	Construir un procedimiento almacenado (principal) que dado un 
periodo de tiempo (expresado en la forma MM-YYYY) y un limite de monto 
de credito, permita generar ambos informes solicitados considerando en 
el caso del informe 1 solo a los clientes cuyo credito sea igual o 
superior al límite indicado como parametro. El periodo se utilizara para 
ambos informes.

El primer informe debera contener:  
-	RUT cliente  
-	Nombre cliente  
-	Nombre de la comuna, en caso de que no este registrada debe asignar 
    SIN COMUNA  
-	Cantidad total de documentos: boletas y facturas en el periodo en 
    proceso  
-	Monto del credito del cliente  

El segundo informe debera contener:  
-	Codigo del producto  
-	Cantidad total de boletas en las cuales ha sido incluido el producto
    durante el periodo en proceso  
-	Cantidad de unidades del producto vendidas en boletas durante el
    periodo en proceso  
-	Porcentaje aplicado de acuerdo con la regla de negocio  
-	Nuevo valor unitario calculado de acuerdo con la regla de negocio  
*/

CREATE OR REPLACE PROCEDURE sp_informe_cliente_producto
(p_periodo IN VARCHAR2, p_credito IN NUMBER)
IS
    --Cursor primer informe
CURSOR c_clientes IS
    SELECT cli.rutcliente, cli.nombre, NVL(c.descripcion, 'SIN COMUNA') AS comuna,
           cli.credito
    FROM cliente cli
    LEFT JOIN comuna c ON cli.codcomuna = c.codcomuna 
    WHERE cli.credito >= p_credito;
    
    --Cursor segundo informe
    CURSOR c_productos IS
        SELECT codproducto, vunitario
        FROM producto;

    -- Variables primer informe
    v_rutcliente cliente.rutcliente%TYPE;
    v_nombre cliente.nombre%TYPE;
    v_comuna comuna.descripcion%TYPE;
    v_cantidad_boletas NUMBER;
    v_cantidad_facturas NUMBER;
    v_cantidad_documentos NUMBER;
    v_credito cliente.credito%TYPE;

    -- Variables segundo informe
    v_codproducto producto.codproducto%TYPE;
    v_cantidad_boletas_producto NUMBER;
    v_cantidad_unidades_producto NUMBER;
    v_valor_unitario producto.vunitario%TYPE;
    v_porcentaje_aplicado NUMBER;
    v_precio NUMBER;

BEGIN
    -- Proceso para el primer informe
    EXECUTE IMMEDIATE 'TRUNCATE TABLE resumen_cliente';
    FOR r_cliente IN c_clientes LOOP

        v_rutcliente := r_cliente.rutcliente;
        v_nombre := r_cliente.nombre;
        v_comuna := r_cliente.comuna; 
        v_credito := r_cliente.credito;

        -- Obtener la cantidad de boletas
        v_cantidad_boletas := fn_boletas_cliente(v_rutcliente, p_periodo);
        -- Obtener la cantidad de facturas
        v_cantidad_facturas := fn_facturas_cliente(v_rutcliente, p_periodo);
        -- Sumar ambas cantidades para obtener el total de documentos
        v_cantidad_documentos := v_cantidad_boletas + v_cantidad_facturas;

        -- INSERTAR LOS RESULTADOS EN LA TABLA RESUMEN_CLIENTE
        INSERT INTO resumen_cliente 
        (
            rut_cliente, 
            nombre_cliente, 
            nombre_comuna, 
            total_documentos, 
            credito
        )
        VALUES
        (
            v_rutcliente, 
            v_nombre, 
            v_comuna,  -- "SIN COMUNA" si no hay comuna
            v_cantidad_documentos, 
            v_credito
        );
    END LOOP;
    COMMIT;

    -- Proceso para el segundo informe
    EXECUTE IMMEDIATE 'TRUNCATE TABLE resumen_producto';
    FOR r_producto IN c_productos LOOP 

        v_codproducto := r_producto.codproducto;
        v_valor_unitario := r_producto.vunitario;

        /* Obtener la cantidad total de boletas y unidades en las cuales ha sido incluido el producto
        Con el procedimiento almacenado sp_detalle_producto */
        sp_detalle_producto(v_codproducto, p_periodo, v_cantidad_boletas_producto, v_cantidad_unidades_producto);

        -- Validar que la cantidad de unidades vendidas no sea NULL o 0 antes de calcular el porcentaje
        IF v_cantidad_unidades_producto IS NULL THEN
            v_cantidad_unidades_producto := 0;
        END IF;

        -- Validar que la cantidad de unidades vendidas no sea 0 antes de calcular el porcentaje
        IF v_cantidad_unidades_producto > 0 THEN
            v_porcentaje_aplicado := NVL(fn_porcentaje_vendido(v_cantidad_unidades_producto), 0);
        ELSE
            v_porcentaje_aplicado := 0;
        END IF;

        -- Calcular el nuevo valor unitario redondeado sin decimales
        v_precio := ROUND(v_valor_unitario * (1 + v_porcentaje_aplicado), 0);
    
        -- INSERTAR resultados del segundo informe en la tabla resumen_producto
        INSERT INTO resumen_producto 
        (
            cod_producto, 
            total_boletas, 
            total_unidades,
            valor_unitario, 
            porcentaje_aplicado, 
            precio
        )
        VALUES
        (
            v_codproducto, 
            v_cantidad_boletas_producto, 
            v_cantidad_unidades_producto,
            v_valor_unitario, 
            v_porcentaje_aplicado, 
            v_precio
        );
    END LOOP;
    COMMIT;

END sp_informe_cliente_producto;

-- Probar el procedimiento almacenado
BEGIN
  -- Generar los informes para marzo de 2024 y clientes con crédito >= 500000
  sp_informe_cliente_producto('03-2024', 500000);
END;














