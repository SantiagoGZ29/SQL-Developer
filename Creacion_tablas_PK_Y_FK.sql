-- Creamos la tabla cliente junto con las restricciones 
CREATE TABLE CLIENTE (
    id_cliente     NUMBER(5) GENERATED ALWAYS AS IDENTITY,
    primer_nombre  VARCHAR2(25) NOT NULL,
    segundo_nombre VARCHAR2(25),
    apell_paterno  VARCHAR2(25) NOT NULL,
    apell_materno  VARCHAR2(25) NOT NULL,
    direccion      VARCHAR2(30) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (id_cliente)
);

-- Creamos la tabla empleado junto con las restricciones
CREATE TABLE EMPLEADO (
    id_empleado    NUMBER(6) GENERATED ALWAYS AS IDENTITY,
    primer_nombre  VARCHAR2(25) NOT NULL,
    segundo_nombre VARCHAR2(25),
    apell_paterno  VARCHAR2(25) NOT NULL,
    apell_materno  VARCHAR2(25) NOT NULL,
    fecha_contrato DATE DEFAULT SYSDATE,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (id_empleado)
);

-- Creamos la tabla pedido junto con las restricciones
CREATE TABLE PEDIDO (
    nro_pedido    NUMBER(6) GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENT BY 10,
    fecha_pedido  DATE NOT NULL,
    fecha_entrega DATE NOT NULL,
    id_empleado   NUMBER(6) NOT NULL,
    id_cliente    NUMBER(5) NOT NULL,
    CONSTRAINT PK_PEDIDO PRIMARY KEY (nro_pedido),
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (id_cliente)REFERENCES cliente ( id_cliente ),
    CONSTRAINT FK_PEDIDO_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES empleado ( id_empleado )     
);


