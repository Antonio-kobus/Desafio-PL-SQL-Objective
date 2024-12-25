/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 24/12/2024
   #  Descricao: Script para criação da tabela de clientes, sequência 
   #             e de um trigger para gerar e inserir o id automaticamente
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

create table clientes (id number(10),
                       nome varchar2(100) not null,
                       endereco varchar2(200),
                       email varchar2(100),
                       telefone integer,
                       CONSTRAINT clientes_pk PRIMARY KEY (id));                   

CREATE SEQUENCE clientes_id_seq minvalue 1 
                                start with 1
                                increment by 1
                                cache 20;

CREATE OR REPLACE TRIGGER clientes_on_insert
  BEFORE INSERT ON clientes
  FOR EACH ROW
BEGIN
  SELECT clientes_id_seq.nextval
  INTO :new.id
  FROM dual;
END;