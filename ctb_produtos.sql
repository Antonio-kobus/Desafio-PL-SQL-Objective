/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 24/12/2024
   #  Descricao: Script para criação da tabela de produtos, sequência 
   #             e de um trigger para gerar e inserir o id automaticamente
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

create table produtos (id number(10),
                       nome_produto varchar2(100) not null,
                       desc_produto varchar2(100),
                       preco number(12,2) not null,
                       qtd_estoque number(10) not null,
                       CONSTRAINT produtos_pk PRIMARY KEY (id));                      

CREATE SEQUENCE produtos_id_seq minvalue 1 
                                start with 1
                                increment by 1
                                cache 20;  

CREATE OR REPLACE TRIGGER produtos_on_insert
  BEFORE INSERT ON produtos
  FOR EACH ROW
BEGIN
  SELECT produtos_id_seq.nextval
  INTO :new.id
  FROM dual;
END;