
--CASO 1
--DESCRIBE EMPLEADO;
CREATE TABLE INFORME_SUELDO_EMP AS
SELECT 
    NOMBRE_EMP ||' '|| APPATERNO_EMP ||' '|| APMATERNO_EMP AS "NOMBRE EMPLEADO",
    SUELDO_EMP AS "SALARIO",
    SUELDO_EMP * 0.055 AS "COLACION",
    SUELDO_EMP * 0.178 AS "MOVILIZACION",
    SUELDO_EMP * 0.078 AS "DESCUENTO SALUD",
    SUELDO_EMP * 0.065 AS "DESCUENTO AFP",
    SUELDO_EMP + (SUELDO_EMP * 0.055) + (SUELDO_EMP * 0.178) - (SUELDO_EMP * 0.078) - (SUELDO_EMP * 0.065)  AS "ALCANCE LIQUIDO"  
FROM EMPLEADO
ORDER BY APPATERNO_EMP;

--CASO 2
--DESCRIBE PROPIEDAD;

--INFORME 1
CREATE TABLE INFORME_PROP_ANNO_2019 AS
SELECT 
    NRO_PROPIEDAD AS "NUMERO PROPIEDAD",
    FECHA_ENTREGA_PROPIEDAD AS "FECHA ENTREGA PROPIEDAD",
    DIRECCION_PROPIEDAD AS "DIRECCION",
    SUPERFICIE,
    NRO_DORMITORIOS AS "CINTIDAD DE DORMITORIOS",
    NRO_BANOS AS "CANTIDAD DE BA�OS",
    VALOR_ARRIENDO AS "VALOR DEL ARRIENDO"
FROM PROPIEDAD
WHERE  
     FECHA_ENTREGA_PROPIEDAD LIKE '%24'
     --FECHA_ENTREGA_PROPIEDAD LIKE '%19'
ORDER BY FECHA_ENTREGA_PROPIEDAD;
--Estimado propesor en mi tabla los datos aparecen con fecha 24
--Dejé la otra opcion tambien 


--INFORME 2
CREATE TABLE INFORME_PROP_FEB_2010 AS
SELECT 
    NRO_PROPIEDAD AS "NUMERO PROPIEDAD",
    FECHA_ENTREGA_PROPIEDAD AS "FECHA ENTREGA PROPIEDAD",
    DIRECCION_PROPIEDAD AS "DIRECCION",
    SUPERFICIE,
    NRO_DORMITORIOS AS "CINTIDAD DE DORMITORIOS",
    NRO_BANOS AS "CANTIDAD DE BA�OS",
    VALOR_ARRIENDO AS "VALOR DEL ARRIENDO"
FROM PROPIEDAD
WHERE  
     FECHA_ENTREGA_PROPIEDAD LIKE '%02/10'
ORDER BY FECHA_ENTREGA_PROPIEDAD,NRO_PROPIEDAD;








