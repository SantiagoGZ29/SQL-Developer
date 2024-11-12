DESCRIBE CLIENTE

-- Desafío 1
SELECT 
    TO_CHAR(NUMRUN_CLI,'99G999G999')||'-'|| DVRUN_CLI "RUN CLIENTE",
    INITCAP (APPATERNO_CLI) ||' '|| 
    SUBSTR(APMATERNO_CLI, 1, 1) ||'. '|| 
    INITCAP (PNOMBRE_CLI) ||' '||
    UPPER (SNOMBRE_CLI) "NOMBRE CLIENTE",
    DIRECCION,
    NVL(TO_CHAR(FONO_FIJO_CLI),'NO TIENE TELEFONO FIJO') "TELEFONO FIJO",
    NVL(TO_CHAR(CELULAR_CLI),'NO TIENE CELULAR') "CELULAR",
    ID_COMUNA COMUNA
FROM CLIENTE
ORDER BY &columna1 &orden1, &columna2 &orden2;


--desafio 2
DESCRIBE EMPLEADO;

SELECT
    'El empleado' ||' '|| 
    PNOMBRE_EMP ||' '||
    SNOMBRE_EMP ||' '||
    APPATERNO_EMP ||' '||
    APMATERNO_EMP ||' Estuvo de cumpleaños el '|| TO_CHAR(FECHA_NAC,'DD "de" Month"."')||'Cumplio '||
    TRUNC(MONTHS_BETWEEN(SYSDATE, FECHA_NAC) / 12) || 'años' AS "Listado cumpleaños"
FROM EMPLEADO
ORDER BY FECHA_NAC ASC;

--la ultima letra de una cadena
SELECT PNOMBRE_EMP, SUBSTR (PNOMBRE_EMP,LENGTH(PNOMBRE_EMP),1)
FROM EMPLEADO;













