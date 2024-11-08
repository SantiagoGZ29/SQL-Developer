


-- Creacion de usuario:
CREATE USER SANTIAGO123 IDENTIFIED BY "Cuenta_para_sumativa123"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";

ALTER USER SANTIAGO123 QUOTA UNLIMITED ON "DATA";

GRANT "RESOURCE" TO "SANTIAGO123";
ALTER USER "SANTIAGO123" DEFAULT ROLE "RESOURCE";

GRANT CREATE SESSION TO "SANTIAGO123";

-- Creación de tablas:
-- Tabla AUTOR:
CREATE TABLE AUTOR (
    id_autor                     NUMBER(5) NOT NULL,
    nombre_autor                 VARCHAR2(20) NOT NULL,
    ap_pat_autor                 VARCHAR2(20) NOT NULL,
    ap_mat_autor                 VARCHAR2(20) NOT NULL,
    id_nacionalidad NUMBER(3) NOT NULL,
    CONSTRAINT PK_123_id_autor PRIMARY KEY(id_autor)
);
-- Correciones de la tabla:
ALTER TABLE AUTOR
RENAME CONSTRAINT PK_123_id_autor TO PK_AUTOR;

ALTER TABLE AUTOR
MODIFY ap_mat_autor NULL;

-- Creación de tabla NACIONALIDAD:
CREATE TABLE NACIONALIDAD (
    id_nacionalidad   NUMBER(3),
    desc_nacionalidad VARCHAR2(20) NOT NULL
);
-- Correciones de la tabla:
ALTER TABLE NACIONALIDAD
ADD CONSTRAINT PK_NACIONALIDAD PRIMARY KEY (id_nacionalidad);
-- Creación de secuencia:
CREATE SEQUENCE SEQ_NACIONALIDAD
  START WITH 100
  INCREMENT BY 10;
  
-- Creación de tabla LIBRO

CREATE TABLE LIBRO (
    isbn_libro             NUMBER(13) NOT NULL,
    titulo_libro           VARCHAR2(50) NOT NULL,
    num_pag_libro          NUMBER(5) NOT NULL,
    anno_pub_libro         NUMBER(4) NOT NULL,
    id_editorial           NUMBER(5) NOT NULL,
    id_autor               NUMBER(5) NOT NULL,
    CONSTRAINT LIBRO_PK PRIMARY KEY(isbn_libro),
    CONSTRAINT LIMITE_ANNO_PUB CHECK (anno_pub_libro >= 1980),
    CONSTRAINT MIN_PAG_LIBRO CHECK (num_pag_libro >= 10)
);
-- Correciones de la tabla:

ALTER TABLE LIBRO 
MODIFY (num_pag_libro DEFAULT 10);

ALTER TABLE LIBRO
RENAME CONSTRAINT LIBRO_PK TO PK_LIBRO;

-- Creación de tabla EDITORIAL

CREATE TABLE EDITORIAL (
    id_editorial     NUMBER(5) NOT NULL,
    nombre_editorial VARCHAR2(30) NOT NULL UNIQUE,
    CONSTRAINT EDITORIAL_PK PRIMARY KEY(id_editorial)
);
-- Correciones de la tabla:

ALTER TABLE EDITORIAL
RENAME CONSTRAINT EDITORIAL_PK TO PK_EDITORIAL;

-- Creación de tabla EJEMPLAR
CREATE TABLE  EJEMPLAR (
    id_ejemplar        NUMBER(6) NOT NULL,
    ubicacion_ejemplar VARCHAR2(20) NOT NULL,
    isbn_libro   NUMBER NOT NULL,
    CONSTRAINT EJEMPLAR_PK PRIMARY KEY (id_ejemplar)
);

-- Correciones de la tabla:

ALTER TABLE EJEMPLAR
RENAME CONSTRAINT EJEMPLAR_PK TO PK_EJEMPLAR;

-- Creación de tabla DETALLE_PRESTAMO

CREATE TABLE DETALLE_PRESTAMO (
    id_ejemplar NUMBER(6) NOT NULL,
    id_prestamo NUMBER(20) NOT NULL,
    CONSTRAINT DETALLE_PRESTAMO_PK PRIMARY KEY (id_ejemplar, id_prestamo)
);

-- Correciones de la tabla:
ALTER TABLE DETALLE_PRESTAMO
RENAME CONSTRAINT DETALLE_PRESTAMO_PK TO PK_DETALLE_PRESTAMO;

ALTER TABLE DETALLE_PRESTAMO
MODIFY id_prestamo NUMBER(5);

-- Creación de tabla PRESTAMO

CREATE TABLE PRESTAMO (
    id_prestamo NUMBER(20) NOT NULL,
    fecha_prestamo NUMBER(2) NOT NULL,
    fecha_devolucion DATE NOT NULL,
    run_biblio NUMBER(8) NOT NULL,
    id_usuario NUMBER(7) NOT NULL,
    CONSTRAINT PRESTAMO_PK PRIMARY KEY (id_prestamo)
);
-- Creacion de secuencia:
CREATE SEQUENCE SEQ_PRESTAMO START WITH 1 INCREMENT BY 1;

-- Correciones de la tabla:
ALTER TABLE PRESTAMO
RENAME CONSTRAINT PRESTAMO_PK TO PK_PRESTAMO;

ALTER TABLE PRESTAMO 
MODIFY fecha_prestamo DATE;

ALTER TABLE PRESTAMO
MODIFY fecha_prestamo DATE DEFAULT SYSDATE;

ALTER TABLE PRESTAMO
ADD CONSTRAINT CHECK_FECHA_DEVOLUCION CHECK (fecha_devolucion > fecha_prestamo);

ALTER TABLE PRESTAMO
MODIFY id_prestamo NUMBER(5);

-- Creación de tabla BIBLIOTECARIO

CREATE TABLE BIBLIOTECARIO (
    run_biblio        NUMBER(8) NOT NULL,
    dv_biblio         NUMBER(2),
    nombre_biblio     VARCHAR2(20) NOT NULL,
    ap_paterno_biblio VARCHAR2(20) NOT NULL,
    ap_materno_biblio VARCHAR2(20) NOT NULL,
    direc_biblio      VARCHAR2(50) NOT NULL,
    tel_biblio        VARCHAR2(15) NOT NULL,
    email_biblio      VARCHAR2(50),
    CONSTRAINT BIBLIOTECARIO_PK PRIMARY KEY (run_biblio)
);
-- Correción de la tabla:
ALTER TABLE BIBLIOTECARIO
RENAME CONSTRAINT BIBLIOTECARIO_PK TO PK_BIBLIOTECARIO;

ALTER TABLE BIBLIOTECARIO
MODIFY dv_biblio CHAR(1)NOT NULL;


-- Creción de la tabla USUARIO

CREATE TABLE USUARIO (
    id_usuario              NUMBER(7) NOT NULL,
    run_usuario             NUMBER(8) NOT NULL UNIQUE,
    dv_usuario              CHAR(1) NOT NULL,
    nombre_usuario          VARCHAR2(20) NOT NULL,
    ap_pat_usuario          DATE NOT NULL,
    ap_mat_usuario          VARCHAR2(20),
    direc_usuario           VARCHAR2(50) NOT NULL,
    tel_usuario             VARCHAR2(15) NOT NULL,
    email_usuario           VARCHAR2(50),
    id_tipo_us              NUMBER NOT NULL,
    CONSTRAINT USUARIO_PK PRIMARY KEY (id_usuario) 
);

-- Correcion de la tabla

ALTER TABLE USUARIO
RENAME CONSTRAINT USUARIO_PK TO PK_USUARIO;

ALTER TABLE USUARIO
MODIFY id_usuario NUMBER(5);

ALTER TABLE USUARIO
MODIFY ap_mat_usuario NOT NULL;

ALTER TABLE USUARIO
MODIFY id_tipo_us NUMBER(6);

ALTER TABLE USUARIO
MODIFY ap_pat_usuario VARCHAR2(20);

-- Creación de tabla TIPO_USUARIO

CREATE TABLE TIPO_USUARIO (
    id_tipo_us  NUMBER(6) NOT NULL,
    dsc_tipo_us VARCHAR2(20) NOT NULL,
    CONSTRAINT TIPO_USUARIO_PK PRIMARY KEY (id_tipo_us)
);

-- Modificación de la tabla

ALTER TABLE TIPO_USUARIO
RENAME CONSTRAINT TIPO_USUARIO_PK TO PK_TIPO_USUARIO;

-- Se agregarán las claves foráneas

ALTER TABLE AUTOR
    ADD CONSTRAINT FK_AUTOR_NACIONALIDAD FOREIGN KEY ( id_nacionalidad )
        REFERENCES NACIONALIDAD ( id_nacionalidad );

ALTER TABLE LIBRO
    ADD CONSTRAINT re_FK FOREIGN KEY ( id_editorial )
        REFERENCES EDITORIAL ( id_editorial );
        
-- Correción del nombre de la FK
ALTER TABLE LIBRO
RENAME CONSTRAINT re_FK TO FK_LIBRO_EDITORIAL; 

ALTER TABLE LIBRO
    ADD CONSTRAINT FK_LIBRO_AUTOR FOREIGN KEY ( id_autor )
        REFERENCES AUTOR ( id_autor );

ALTER TABLE EJEMPLAR
    ADD CONSTRAINT FK_EJEMPLAR_LIBRO FOREIGN KEY ( isbn_libro )
        REFERENCES LIBRO ( isbn_libro );

ALTER TABLE DETALLE_PRESTAMO
    ADD CONSTRAINT FK1_FK FOREIGN KEY ( id_ejemplar )
        REFERENCES EJEMPLAR ( id_ejemplar );
        
-- Correción del nombre de la FK
ALTER TABLE DETALLE_PRESTAMO
RENAME CONSTRAINT FK1_FK TO FK_EJEMPLAR_DETALLE_PRESTAMO; 

ALTER TABLE detalle_prestamo
    ADD CONSTRAINT DET_PRE_FK FOREIGN KEY ( id_prestamo )
        REFERENCES PRESTAMO ( id_prestamo );
        
-- Correción del nombre de la FK
ALTER TABLE DETALLE_PRESTAMO
RENAME CONSTRAINT DET_PRE_FK TO FK_PRESTAMO_DETALLE_PRESTAMO;  

ALTER TABLE PRESTAMO
    ADD CONSTRAINT FK_PRESTAMO_BIBLIOTECARIO FOREIGN KEY ( run_biblio )
        REFERENCES BIBLIOTECARIO ( run_biblio );

ALTER TABLE PRESTAMO
    ADD CONSTRAINT FK_PRESTAMO_USUARIO FOREIGN KEY ( id_usuario )
        REFERENCES USUARIO ( id_usuario );

ALTER TABLE USUARIO
    ADD CONSTRAINT FK_USUARIO_TIPO_USUARIO FOREIGN KEY ( id_tipo_us )
        REFERENCES TIPO_USUARIO ( id_tipo_us );

-- Vamos a poblar la base de datos:

-- Poblacion de la tabla NACIONALIDAD:

INSERT INTO NACIONALIDAD (id_nacionalidad, desc_nacionalidad)
VALUES(SEQ_NACIONALIDAD.NEXTVAL, 'CHILENA');

INSERT INTO NACIONALIDAD (id_nacionalidad, desc_nacionalidad)
VALUES (SEQ_NACIONALIDAD.NEXTVAL, 'BRITÁNICA'); 

INSERT INTO NACIONALIDAD (id_nacionalidad, desc_nacionalidad)
VALUES (SEQ_NACIONALIDAD.NEXTVAL, 'ESPAÑOLA');

INSERT INTO NACIONALIDAD (id_nacionalidad, desc_nacionalidad)
VALUES (SEQ_NACIONALIDAD.NEXTVAL, 'FRANCESA');

INSERT INTO NACIONALIDAD (id_nacionalidad, desc_nacionalidad)
VALUES (SEQ_NACIONALIDAD.NEXTVAL, 'MEXICANA'); 

-- Poblacion de la tabla AUTOR:
INSERT INTO AUTOR (id_autor, nombre_autor, ap_pat_autor, ap_mat_autor, id_nacionalidad)
VALUES (1, 'MIGUEL', 'CERVANTES', NULL, 120);

INSERT INTO AUTOR (id_autor, nombre_autor, ap_pat_autor, ap_mat_autor, id_nacionalidad)
VALUES (2, 'J. R. R.', 'TOLKIEN', NULL, 110);

INSERT INTO AUTOR (id_autor, nombre_autor, ap_pat_autor, ap_mat_autor, id_nacionalidad)
VALUES (3, 'J. K.', 'ROWLING', NULL, 110);

INSERT INTO AUTOR (id_autor, nombre_autor, ap_pat_autor, ap_mat_autor, id_nacionalidad)
VALUES (4, 'ANTOINE', 'DE SAINT-EXUPÉRY', NULL, 130);

-- Poblacion de la tabla EDITORIAL:

INSERT INTO EDITORIAL (id_editorial, nombre_editorial)
VALUES (1,'AFAGUARA');

INSERT INTO EDITORIAL (id_editorial, nombre_editorial)
VALUES (2,'GEORGE ALLEN Y UNWIN');

INSERT INTO EDITORIAL (id_editorial, nombre_editorial)
VALUES (3,'SALAMANDRA');

INSERT INTO EDITORIAL (id_editorial, nombre_editorial)
VALUES (4,'CONTINENTAL');

-- Poblacion de la tabla LIBRO:

INSERT INTO LIBRO (isbn_libro, titulo_libro,num_pag_libro,anno_pub_libro,id_editorial,id_autor)
VALUES (9788420403021,'EL QUIJOTE',1424,2013,1,1);

INSERT INTO LIBRO (isbn_libro, titulo_libro,num_pag_libro,anno_pub_libro,id_editorial,id_autor)
VALUES (9788498380170,'HARRY POTTER Y LA PIEDRA FILOSOFAL',288,2021,3,3);

INSERT INTO LIBRO (isbn_libro, titulo_libro,num_pag_libro,anno_pub_libro,id_editorial,id_autor)
VALUES (9781937482978,'EL PRINCIPITO',117,2014,4,4);

INSERT INTO LIBRO (isbn_libro, titulo_libro,num_pag_libro,anno_pub_libro,id_editorial,id_autor)
VALUES (8445071793,'EL SEÑOR DE LOS ANILLOS',1272,1995,2,2);

-- Poblacion de la tabla BIBLIOTECARIO:

INSERT INTO BIBLIOTECARIO (run_biblio, dv_biblio, nombre_biblio, ap_paterno_biblio, ap_materno_biblio, direc_biblio, tel_biblio, email_biblio)
VALUES (9271451, 9, 'ELIZABETH GRACIANA', 'BARRERA', 'ROA', 'AV. ALMIRANTE SIPSON N 367', '92293769', 'EBARRERA@GMAIL.COM');

INSERT INTO BIBLIOTECARIO (run_biblio, dv_biblio, nombre_biblio, ap_paterno_biblio, ap_materno_biblio, direc_biblio, tel_biblio, email_biblio)
VALUES (3066256, 3, 'OLGA', 'BELMAR', 'LAMILLA', 'JORGE MONT 710', '92293770', 'OBELMAR@GMAIL.COM');

INSERT INTO BIBLIOTECARIO (run_biblio, dv_biblio, nombre_biblio, ap_paterno_biblio, ap_materno_biblio, direc_biblio, tel_biblio, email_biblio)
VALUES (5643549, 2, 'RAMON ANTONIO', 'CONTRERAS', 'TOLEDO', 'AVDA. LITORAL N° 335, ROCAS SANTO DOMINGO', '92293796', 'RCONTRERAS@GMAIL.COM');

INSERT INTO BIBLIOTECARIO (run_biblio, dv_biblio, nombre_biblio, ap_paterno_biblio, ap_materno_biblio, direc_biblio, tel_biblio, email_biblio)
VALUES (4378812, 4, 'JULIA IRIS', 'CHAVARRIA', 'GUTIERREZ', 'MATAVERI ESQUINA MANUTARA S/N', '92293797', 'JCHAVARRIA@GMAIL.COM');

-- Poblacion de la tabla TIPO_USUARIO:

INSERT INTO TIPO_USUARIO (id_tipo_us, dsc_tipo_us)
VALUES (1, 'PROFESOR');

INSERT INTO TIPO_USUARIO (id_tipo_us, dsc_tipo_us)
VALUES (2, 'ESTUDIANTE');

-- Poblacion de la tabla USUARIO:

INSERT INTO USUARIO (id_usuario, run_usuario, dv_usuario, nombre_usuario, ap_pat_usuario, ap_mat_usuario, direc_usuario, tel_usuario, email_usuario, id_tipo_us)
VALUES (1, 10214564, 'K', 'VIVIANA JACQUELINE', 'ALARCON', 'CACERES', 'SOTOMAYOR N 728', 92293759, 'VALARCON@GMAIL.COM', 2);

INSERT INTO USUARIO (id_usuario, run_usuario, dv_usuario, nombre_usuario, ap_pat_usuario, ap_mat_usuario, direc_usuario, tel_usuario, email_usuario, id_tipo_us)
VALUES (2, 3781561, '6', 'MARIA LUCILA', 'ALARCON', 'SEPULVEDA', 'AVENIDA GRECIA N° 2030', 92293760, 'MALARCON@GMAIL.COM', 1);

INSERT INTO USUARIO (id_usuario, run_usuario, dv_usuario, nombre_usuario, ap_pat_usuario, ap_mat_usuario, direc_usuario, tel_usuario, email_usuario, id_tipo_us)
VALUES (3, 4884829, 'K', 'FLOR MARIA', 'ALVAREZ', 'CACERES', 'CALLE RANCAGUA N 499', 92293761, 'FALVAREZ@GMAIL.COM', 1);

INSERT INTO USUARIO (id_usuario, run_usuario, dv_usuario, nombre_usuario, ap_pat_usuario, ap_mat_usuario, direc_usuario, tel_usuario, email_usuario, id_tipo_us)
VALUES (4, 3758049, 'K', 'HECTOR RENE', 'ANDRADE', 'FAUNDEZ', 'CALLE BRASIL N° 366,...', 92293762, 'HANDRADE@GMAIL.COM', 1);

-- Poblacion de la tabla PRESTAMO:

INSERT INTO PRESTAMO (id_prestamo, fecha_prestamo, fecha_devolucion, run_biblio, id_usuario)
VALUES(SEQ_PRESTAMO.NEXTVAL,'11/05/20', '17/05/20', 9271451, 1);

INSERT INTO PRESTAMO (id_prestamo, fecha_prestamo, fecha_devolucion, run_biblio, id_usuario)
VALUES(SEQ_PRESTAMO.NEXTVAL,'11/06/20', '17/06/20', 3066256, 4);

INSERT INTO PRESTAMO (id_prestamo, fecha_prestamo, fecha_devolucion, run_biblio, id_usuario)
VALUES(SEQ_PRESTAMO.NEXTVAL,'10/05/20', '17/05/20', 5643549, 2);

INSERT INTO PRESTAMO (id_prestamo, fecha_prestamo, fecha_devolucion, run_biblio, id_usuario)
VALUES(SEQ_PRESTAMO.NEXTVAL,'11/06/20', '17/06/20', 4378812, 3);

-- Poblacion de la tabla EJEMPLAR:

INSERT INTO EJEMPLAR (id_ejemplar, ubicacion_ejemplar, isbn_libro)
VALUES(1, '1 005.756 C393b', 9788420403021);

INSERT INTO EJEMPLAR (id_ejemplar, ubicacion_ejemplar, isbn_libro)
VALUES (2, '2 R658.8003 S284t', 9788498380170);

INSERT INTO EJEMPLAR (id_ejemplar, ubicacion_ejemplar, isbn_libro)
VALUES  (3, '3 318.3 I43i', 9781937482978);

INSERT INTO EJEMPLAR (id_ejemplar, ubicacion_ejemplar, isbn_libro)
VALUES (4, '4 005.133SQL G113s', 8445071793);

-- Poblacion de la tabla DETALLE_PRESTAMO:
INSERT INTO DETALLE_PRESTAMO(id_ejemplar,id_prestamo)
VALUES(1,3);

INSERT INTO DETALLE_PRESTAMO(id_ejemplar,id_prestamo)
VALUES(2,3);

INSERT INTO DETALLE_PRESTAMO(id_ejemplar,id_prestamo)
VALUES(3,1);

INSERT INTO DETALLE_PRESTAMO(id_ejemplar,id_prestamo)
VALUES(3,4);

INSERT INTO DETALLE_PRESTAMO(id_ejemplar,id_prestamo)
VALUES(4,2);

-- Desnormalización 
CREATE TABLE PRESTAMOS_MENSUALES (
    usuario_id NUMBER(5) NOT NULL,
    mes NUMBER(2) NOT NULL, 
    anno NUMBER(4) NOT NULL,
    cantidad_prestamos NUMBER(4) NOT NULL,
    CONSTRAINT PK_PRESTAMOS_MENSUALES PRIMARY KEY (usuario_id, mes, anno)
);
