-- PRIMER INFORME
DESCRIBE EMPLEADO;

SELECT 
    TO_CHAR (SYSDATE,'YYYY') "AÑO TRIBUTARIO", 
    
    TO_CHAR (NUMRUN_EMP,'99G999G999') ||'-'|| DVRUN_EMP "RUN EMPLEADO",
    
    UPPER (PNOMBRE_EMP ||' '|| SNOMBRE_EMP ||' '|| APPATERNO_EMP ||' '|| APMATERNO_EMP) "NOMBRE EMPLEADO",
    
    -- CALCULO DE MESES TRABAJADOS EN EL AÑO
    CASE 
        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
        ELSE
            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END "MESES TRABAJADOS EN EL AÑO", 
            
    FLOOR(MONTHS_BETWEEN(TRUNC (SYSDATE, 'YYYY') - 1, fecha_contrato) / 12)"AÑOS TRABAJADOS",
    
    SUELDO_BASE "SUELDO BASE MENSUAL",
    
    -- CALCULO DE BON POR AÑOS 
    ROUND(SUELDO_BASE * (CASE 
                            WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
                            ELSE
                                ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)END)) "SUELDO BASE ANUAL",
     
    --CALCULO DE BONO POR AÑOS        
    ROUND((((FLOOR(MONTHS_BETWEEN(TRUNC (SYSDATE, 'YYYY') - 1, fecha_contrato) / 12))/100)*SUELDO_BASE)*((CASE 
                                                                                                                WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
                                                                                                                ELSE
                                                                                                                    ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)END))) "BONO POR AÑOS",
                                                                
    --CALCULO DE MOVILIZACION ANUAL
    ROUND((SUELDO_BASE * 0.12) *(CASE 
                                    WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
                                    ELSE
                                        ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)END) )"MOVILIZACION ANUAL",
            
    --CALCULO DE COLACION ANUAL
    ROUND((SUELDO_BASE * 0.20) *((CASE 
                                        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
                                        ELSE
                                            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)END)) )"COLACION ANUAL",
    --CALCULO DE SUELDO BRUTO ANUAL                          
    ROUND((SUELDO_BASE * (CASE 
                                WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
                                ELSE
                                    ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END))+(ROUND((((FLOOR(MONTHS_BETWEEN(TRUNC (SYSDATE, 'YYYY') - 1, fecha_contrato) / 12))/100)*SUELDO_BASE)*(CASE 
        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
        ELSE
            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END)))
    +(ROUND((SUELDO_BASE * 0.12) *(    CASE 
        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
        ELSE
            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END) ))+(ROUND((SUELDO_BASE * 0.20) *(    CASE 
        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
        ELSE
            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END) ))) "SUELDO BRUTO ANUAL",



    --CALCULO RENTA IMPONIBLE ANUAL
    ROUND((SUELDO_BASE*(    CASE 
        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
        ELSE
            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END)) + (ROUND((((FLOOR(MONTHS_BETWEEN(TRUNC (SYSDATE, 'YYYY') - 1, fecha_contrato) / 12))/100)*SUELDO_BASE)*(    CASE 
        WHEN FECHA_CONTRATO < TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') THEN 12
        ELSE
            ROUND(MONTHS_BETWEEN(TRUNC(ADD_MONTHS(SYSDATE, -12), 'YEAR') + INTERVAL '12' MONTH,FECHA_CONTRATO),1)
            END))))"RENTA IMPONIBLE ANUAL"    
FROM EMPLEADO
ORDER BY NUMRUN_EMP;











