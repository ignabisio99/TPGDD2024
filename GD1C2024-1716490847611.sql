
CREATE TABLE DETALLE_POR_PROMOCION
(
  DETALLE_TICKET_ID INTEGER       NOT NULL,
  PROMO_CODIGO      INTEGER       NOT NULL,
  PROMO_TOTAL       DECIMAL(18,2) NULL    ,
  PROMO_CODIGO      DECIMAL       NOT NULL,
  PRODUCTO_ID       INTEGER       NOT NULL,
  PRIMARY KEY (DETALLE_TICKET_ID, PROMO_CODIGO)
);

CREATE TABLE PRODUCTO
(
  PRODUCTO_ID               INTEGER       NOT NULL AUTO_INCREMENT,
  PRODUCTO_SUB_CATEGORIA_ID INTEGER       NOT NULL,
  PRODUCTO_CATEGORIA_ID     INTEGER       NOT NULL,
  PRODUCTO_NOMBRE           VARCHAR(255)  NULL    ,
  PRODUCTO_DESCRIPCION      VARCHAR(255)  NULL    ,
  PRODUCTO_PRECIO           DECIMAL(18,2) NULL    ,
  PRODUCTO_MARCA            VARCHAR(255)  NULL    ,
  PRIMARY KEY (PRODUCTO_ID)
);

ALTER TABLE PRODUCTO
  ADD CONSTRAINT UQ_PRODUCTO_ID UNIQUE (PRODUCTO_ID);

CREATE TABLE PRODUCTO_CATEGORIA
(
  PRODUCTO_CATEGORIA_ID INTEGER      NOT NULL AUTO_INCREMENT,
  PRODUCTO_CATEGORIA    VARCHAR(255) NOT NULL,
  PRIMARY KEY (PRODUCTO_CATEGORIA_ID)
);

ALTER TABLE PRODUCTO_CATEGORIA
  ADD CONSTRAINT UQ_PRODUCTO_CATEGORIA_ID UNIQUE (PRODUCTO_CATEGORIA_ID);

CREATE TABLE PRODUCTO_SUB_CATEGORIA
(
  PRODUCTO_SUB_CATEGORIA_ID INTEGER      NOT NULL AUTO_INCREMENT,
  PRODUCTO_CATEGORIA_ID     INTEGER      NOT NULL,
  PRODUCTO_CATEGORIA_ID     INTEGER      NOT NULL,
  PRODUCTO_SUB_CATEGORIA    VARCHAR(255) NULL    ,
  PRIMARY KEY (PRODUCTO_SUB_CATEGORIA_ID)
);

ALTER TABLE PRODUCTO_SUB_CATEGORIA
  ADD CONSTRAINT UQ_PRODUCTO_SUB_CATEGORIA_ID UNIQUE (PRODUCTO_SUB_CATEGORIA_ID);

CREATE TABLE PROMOCION
(
  PROMO_CODIGO       DECIMAL(18,0) NOT NULL AUTO_INCREMENT,
  PROMO_DESCRIPCION  VARCHAR(255)  NULL    ,
  PROMO_FECHA_INICIO DATETIME      NULL    ,
  PROMO_FECHA_FIN    DATETIME      NULL    ,
  PRIMARY KEY (PROMO_CODIGO)
);

ALTER TABLE PROMOCION
  ADD CONSTRAINT UQ_PROMO_CODIGO UNIQUE (PROMO_CODIGO);

CREATE TABLE REGLA_PROMOCION
(
  REGLA_PROMOCION_ID                 INTEGER       NOT NULL AUTO_INCREMENT,
  PROMO_CODIGO                       DECIMAL(18,0) NOT NULL,
  REGLA_PROMO_CODIGO                 DECIMAL(18,0) NOT NULL,
  REGLA_DESCRIPCION                  VARCHAR(255)  NULL    ,
  REGLA_DESCUENTO_APLICABLE          DECIMAL(18,2) NULL    ,
  REGLA_CANTIDAD_APLICABLE           DECIMAL(18,0) NULL    ,
  REGLA_CANTIDAD_APLICABLE_DESCUENTO DECIMAL(18,0) NULL    ,
  REGLA_CANTIDAD_MAXIMA              DECIMAL(18,0) NULL    ,
  REGLA_APLICA_MISMA_MARCA           DECIMAL(18,0) NULL    ,
  REGLA_APLICA_MISMO_PRODUCTO        DECIMAL(18,0) NULL    ,
  PRIMARY KEY (REGLA_PROMOCION_ID)
);

ALTER TABLE REGLA_PROMOCION
  ADD CONSTRAINT UQ_REGLA_PROMOCION_ID UNIQUE (REGLA_PROMOCION_ID);

CREATE TABLE REGLA_PROMOCION_PRODUCTO
(
  PROMO_CODIGO              DECIMAL       NOT NULL,
  PRODUCTO_ID               INTEGER       NOT NULL,
  PRODUCTO_ID               INTEGER       NOT NULL,
  PRODUCTO_SUB_CATEGORIA_ID INTEGER       NOT NULL,
  PROMO_CODIGO              DECIMAL(18,0) NOT NULL,
  PRIMARY KEY (PROMO_CODIGO, PRODUCTO_ID)
);

ALTER TABLE REGLA_PROMOCION_PRODUCTO
  ADD CONSTRAINT FK_PRODUCTO_TO_REGLA_PROMOCION_PRODUCTO
    FOREIGN KEY (PRODUCTO_ID, PRODUCTO_SUB_CATEGORIA_ID)
    REFERENCES PRODUCTO (PRODUCTO_ID);

ALTER TABLE REGLA_PROMOCION_PRODUCTO
  ADD CONSTRAINT FK_PROMOCION_TO_REGLA_PROMOCION_PRODUCTO
    FOREIGN KEY (PROMO_CODIGO)
    REFERENCES PROMOCION (PROMO_CODIGO);

ALTER TABLE REGLA_PROMOCION
  ADD CONSTRAINT FK_PROMOCION_TO_REGLA_PROMOCION
    FOREIGN KEY (PROMO_CODIGO)
    REFERENCES PROMOCION (PROMO_CODIGO);

ALTER TABLE PRODUCTO_SUB_CATEGORIA
  ADD CONSTRAINT FK_PRODUCTO_CATEGORIA_TO_PRODUCTO_SUB_CATEGORIA
    FOREIGN KEY (PRODUCTO_CATEGORIA_ID)
    REFERENCES PRODUCTO_CATEGORIA (PRODUCTO_CATEGORIA_ID);

ALTER TABLE PRODUCTO
  ADD CONSTRAINT FK_PRODUCTO_SUB_CATEGORIA_TO_PRODUCTO
    FOREIGN KEY (PRODUCTO_SUB_CATEGORIA_ID, PRODUCTO_CATEGORIA_ID)
    REFERENCES PRODUCTO_SUB_CATEGORIA (PRODUCTO_SUB_CATEGORIA_ID, PRODUCTO_CATEGORIA_ID);

ALTER TABLE DETALLE_POR_PROMOCION
  ADD CONSTRAINT FK_REGLA_PROMOCION_PRODUCTO_TO_DETALLE_POR_PROMOCION
    FOREIGN KEY (PROMO_CODIGO, PRODUCTO_ID)
    REFERENCES REGLA_PROMOCION_PRODUCTO (PROMO_CODIGO, PRODUCTO_ID);
