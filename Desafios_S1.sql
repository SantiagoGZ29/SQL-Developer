
// Desafío 1
SELECT 'El empleado' ||' '|| nombre_emp ||' '|| appaterno_emp ||' '|| apmaterno_emp
||' '|| 'nacio el' ||' '|| fecnac_emp AS "listado de cumpleaños"
FROM empleado; 

// Desafío 2
SELECT 
    numrut_cli AS "NUMERO RUT", 
    dvrut_cli AS "DIGITO VERIFICADOR", 
    appaterno_cli ||' '|| apmaterno_cli ||' '|| nombre_cli AS "NOMBRE CLIENTE",
    renta_cli AS "RENTA", 
    fonofijo_cli AS "TELEFONO FIJO", 
    celular_cli AS "CELULAR" 
FROM cliente;

// Desafío 3

SELECT 
    nombre_emp ||' '|| appaterno_emp ||' '|| apmaterno_emp AS "NOMBRE EMPLEADO",
    sueldo_emp AS "SUELDO", 
    sueldo_emp*0.5 AS "BONO POR CAPACIITACION"
FROM empleado;

// Desafío 4

SELECT 
    nro_propiedad, numrut_prop AS "RUT PROPIETARIO", 
    direccion_propiedad AS "DIRECCIÓN", 
    valor_arriendo, valor_arriendo *0.054 AS "VALOR COMPENSACION"
FROM propiedad;

// Desafío 5

SELECT 
    numrut_emp ||'-'|| dvrut_emp AS "RUN EMPLEADO", 
    nombre_emp ||' '|| appaterno_emp ||' '|| apmaterno_emp AS "NOMBRE EMPLEADO",
    sueldo_emp AS "SALARIO ACTUAL",
    sueldo_emp * 1.13 AS "SALARIO_REAJUSTADO",
    (sueldo_emp * 1.13) - sueldo_emp AS "REAJUSTE"
       
FROM empleado;



