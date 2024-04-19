-- # Scripts

-- ## Inicialização
-- NOTE: Ordem de deleção inversa à de criação

DROP TABLE tb_voos;
DROP TABLE tb_passagem;
DROP TABLE tb_passageiro;
DROP TABLE tb_estadia;
DROP TABLE tb_hotel;

-- DROP TABLE passagens_lista;
-- DROP TABLE estadias_lista;
DROP TABLE reserva_lista;

DROP TYPE tp_reserva;
DROP TYPE tp_voos;
DROP TYPE tp_passagem;
DROP TYPE tp_passageiro_maior;
DROP TYPE tp_passageiro_menor;
DROP TYPE tp_passageiro;
DROP TYPE tp_estadia;
DROP TYPE tp_hotel;
DROP TYPE tp_varr_telefones;
DROP TYPE tp_varr_telefone;

DROP TYPE tp_rel_referese_passagens_nt;
DROP TYPE tp_rel_referese_passagens;
DROP TYPE tp_rel_registrada_estadias_nt;
DROP TYPE tp_rel_registrada_estadias;
DROP TYPE tp_rel_comprar_nt;
DROP TYPE tp_rel_comprar;

DROP TYPE tp_endereco;


-- ## Tipos auxiliares

CREATE OR REPLACE TYPE tp_endereco AS OBJECT(
    complemento         VARCHAR2(50),
    cidade              VARCHAR2(50),
    estado              VARCHAR2(50),
    pais                VARCHAR2(50),
    cep                 VARCHAR2(10)
);

CREATE OR REPLACE TYPE tp_varr_telefone AS OBJECT(
    -- ddi                 VARCHAR(3),
    ddd                 VARCHAR(2),
    numero              VARCHAR(9)
);

CREATE OR REPLACE TYPE tp_varr_telefones AS VARRAY(3) OF tp_varr_telefone;


-- ## Tipos de Entidades

CREATE OR REPLACE TYPE tp_hotel AS OBJECT(
    cod_hotel           NUMBER,
    nome                VARCHAR2(100),
    endereco            tp_endereco
);

CREATE OR REPLACE TYPE tp_estadia AS OBJECT(
    cod_estadia         NUMBER,
    valor_estadia       NUMBER(10, 2),
    data_checkin        DATE,
    data_checkout       DATE
);

CREATE OR REPLACE TYPE tp_passageiro AS OBJECT(
    cpf                 NUMBER,
    nome                VARCHAR2(100),
    sexo                CHAR,
    endereco            tp_endereco,
    data_nascimento     DATE
) NOT FINAL;

CREATE OR REPLACE TYPE tp_passageiro_menor UNDER tp_passageiro(
    telefone_emergencia     tp_varr_telefones,
    responsavel_telefone    VARCHAR2(100),
    autorizacao_viagem      BOOLEAN
);

CREATE OR REPLACE TYPE tp_passageiro_maior UNDER tp_passageiro(
    telefone                tp_varr_telefones,
    email                   VARCHAR2(50)
);

CREATE OR REPLACE TYPE tp_passagem AS OBJECT(
    num_passagem        NUMBER,
    data_ida            DATE,
    data_volta          DATE,
    -- data_voo            DATE,
    valor_passagem      NUMBER(10, 2)
);

CREATE OR REPLACE TYPE tp_voos AS OBJECT(
    num_voo             NUMBER,
    origem              VARCHAR2(3),
    destino             VARCHAR2(3),
    hora_embarque       DATE,
    hora_desembarque    DATE
);


-- ## Relacionamentos

-- ### Relacionamentos : Entidade associativa

CREATE OR REPLACE TYPE tp_reserva AS OBJECT(
    -- compra_id           REF  tp_rel_comprar,
    passageiro          REF  tp_passageiro,
    passagem            REF  tp_passagem,
    data_compra         DATE,
    localizador         VARCHAR2(50),
    tipo_passageiro     CHAR
);


-- ### Relacionamentos : Refere-se

CREATE OR REPLACE TYPE tp_rel_referese_passagens AS OBJECT(
    passagem            REF tp_passagem
    -- criado_em           DATE
) NOT FINAL;

CREATE OR REPLACE TYPE tp_rel_referese_passagens_nt AS TABLE OF tp_rel_referese_passagens;

ALTER TYPE tp_voos ADD ATTRIBUTE(
    Passagens           tp_rel_referese_passagens_nt
) CASCADE;


-- ### Relacionamentos : Registrada

CREATE OR REPLACE TYPE tp_rel_registrada_estadias AS OBJECT(
    estadia             REF tp_estadia
    -- criado_em           DATE
) NOT FINAL;

CREATE OR REPLACE TYPE tp_rel_registrada_estadias_nt AS TABLE OF tp_rel_registrada_estadias;

ALTER TYPE tp_hotel ADD ATTRIBUTE(
    Estadias            tp_rel_registrada_estadias_nt
) CASCADE;


-- ### Relacionamentos : Comprar

CREATE OR REPLACE TYPE tp_rel_comprar AS OBJECT(
    estadia             REF tp_estadia,
    reserva             REF tp_reserva
    -- criado_em           DATE
);

CREATE OR REPLACE TYPE tp_rel_comprar_nt AS TABLE OF tp_rel_comprar;

ALTER TYPE tp_reserva ADD ATTRIBUTE(
    compra_id           REF  tp_rel_comprar
) CASCADE;


-- ## Criação das tabelas

CREATE TABLE tb_hotel OF tp_hotel(
    cod_hotel           PRIMARY KEY
)
NESTED TABLE Estadias STORE AS estadias_lista;

CREATE TABLE tb_estadia OF tp_estadia(
    cod_estadia         PRIMARY KEY
);

CREATE TABLE tb_passageiro OF tp_passageiro(
    cpf                 PRIMARY KEY
);

CREATE TABLE tb_passagem OF tp_passagem(
    num_passagem        PRIMARY KEY
);

CREATE TABLE tb_voos OF tp_voos(
    num_voo             PRIMARY KEY
)
NESTED TABLE Passagens STORE AS passagens_lista;

CREATE TABLE reserva_lista OF tp_reserva;
