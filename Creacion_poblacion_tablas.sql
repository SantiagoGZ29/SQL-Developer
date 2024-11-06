--Creación de tablas:

--Tabla tipo_empleado:
CREATE TABLE TIPO_EMPLEADO (
    tipo_empleado   NUMBER(2)  NOT NULL,
    desc_tipo_empleado VARCHAR2(25) NOT NULL,
    CONSTRAINT PK_TIPO_EMPLEADO PRIMARY KEY(tipo_empleado) 
);

--Tabla empleado:
CREATE TABLE EMPLEADO (
    id_empleado                 NUMBER(5)  NOT NULL,
    num_rut                     NUMBER(10) NOT NULL,
    dv_rut                      VARCHAR2(1)NOT NULL,
    pnombre                     VARCHAR2(20) NOT NULL,
    snombre                     VARCHAR2(20),
    appaterno                   VARCHAR2(20) NOT NULL,
    apmaterno                   VARCHAR2(20) NOT NULL,
    fecha_contrato              DATE NOT NULL,
    tipo_empleado               NUMBER(2) NOT NULL,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY(id_empleado),
    CONSTRAINT FK_EMPLEADO_TIPO_EMPLEADO FOREIGN KEY (tipo_empleado) REFERENCES TIPO_EMPLEADO (tipo_empleado)
);

--Tabla venta:
CREATE TABLE VENTA (
    nro_boleta           NUMBER(8) NOT NULL,
    fecha_boleta         DATE NOT NULL,
    monto_total          NUMBER (8) NOT NULL,
    id_empleado          NUMBER (5) NOT NULL,
    CONSTRAINT PK_VENTA PRIMARY KEY (nro_boleta),
    CONSTRAINT FK_VENTA_ID_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado)
);
-- Tabla de comision_venta
CREATE TABLE COMISION_VENTA (
    monto_comision   NUMBER (8) NOT NULL,
    nro_boleta       NUMBER (8) NOT NULL,
    CONSTRAINT PK_COMISION_VENTA PRIMARY KEY (nro_boleta),
    CONSTRAINT FK_COMISION_VENTA_VENTA FOREIGN KEY(nro_boleta) REFERENCES VENTA (nro_boleta)
    
);

--Poblar las tablas con datos:
-- tipo_empleado:
INSERT INTO TIPO_EMPLEADO(tipo_empleado,desc_tipo_empleado)
VALUES (1,'Administrativo');

INSERT INTO TIPO_EMPLEADO(tipo_empleado,desc_tipo_empleado)
VALUES (2,'Cocinero');

INSERT INTO TIPO_EMPLEADO(tipo_empleado,desc_tipo_empleado)
VALUES (3,'Vendedor');

INSERT INTO TIPO_EMPLEADO(tipo_empleado,desc_tipo_empleado)
VALUES (4,'Repartidor');

--Empleado:
INSERT INTO EMPLEADO(id_empleado,num_rut, dv_rut,pnombre,snombre,appaterno, apmaterno, fecha_contrato,tipo_empleado)
VALUES (4,5555555,5,'MARIA','Null','ROMERO','ROJAS','01-08-12',1);

INSERT INTO EMPLEADO(id_empleado,num_rut, dv_rut,pnombre,snombre,appaterno, apmaterno, fecha_contrato,tipo_empleado)
VALUES (5,6666666,6,'SONIA','EUGENIA','TAPIA','VEGA','01-08-12',2);

INSERT INTO EMPLEADO(id_empleado,num_rut, dv_rut,pnombre,snombre,appaterno, apmaterno, fecha_contrato,tipo_empleado)
VALUES (1,2222222,2,'PABLO','Null','PEREZ','SOTO','01-03-10',3);

INSERT INTO EMPLEADO(id_empleado,num_rut, dv_rut,pnombre,snombre,appaterno, apmaterno, fecha_contrato,tipo_empleado)
VALUES (2,3333333,3,'PEDRO','JOSE','TORRES','TRONCOSO','14-03-11',3);

INSERT INTO EMPLEADO(id_empleado,num_rut, dv_rut,pnombre,snombre,appaterno, apmaterno, fecha_contrato,tipo_empleado)
VALUES (3,4444444,4,'FRANCISCO','ALEJANDRO','AGUILAR','TAPIA','01-06-11',3);

--Ventas:
INSERT INTO VENTA (nro_boleta,id_empleado,fecha_boleta,monto_total)
VALUES (100,1,'01-03-2014',200000)

INSERT INTO VENTA (nro_boleta,id_empleado,fecha_boleta,monto_total)
VALUES (101,1,'02-03-2014',100000)

INSERT INTO VENTA (nro_boleta,id_empleado,fecha_boleta,monto_total)
VALUES (102,1,'02-03-2014',75000) 

INSERT INTO VENTA (nro_boleta,id_empleado,fecha_boleta,monto_total)
VALUES (103,3,'02-03-2014',45200) 

INSERT INTO VENTA (nro_boleta,id_empleado,fecha_boleta,monto_total)
VALUES (90,3,'02-02-2014',75000)



--COMISION_VENTA

INSERT INTO COMISION_VENTA (nro_boleta,monto_comision)
VALUES (100,26000)

INSERT INTO COMISION_VENTA (nro_boleta,monto_comision)
VALUES (101,13000)

INSERT INTO COMISION_VENTA (nro_boleta,monto_comision)
VALUES (102,9750)

INSERT INTO COMISION_VENTA (nro_boleta,monto_comision)
VALUES (103,5876)

INSERT INTO COMISION_VENTA (nro_boleta,monto_comision)
VALUES (90,9750)