/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 24/12/2024
   #  Descricao: Script para criação da tabela de pedidos, sequência 
   #             e de um trigger para gerar e inserir o id automaticamente
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

create table pedidos (id number(10),
                      id_cliente number(10) not null,
                      id_produto number(10) not null,
                      dt_pedido timestamp not null,
                      qtd_prod number(10) not null,
                      status_pedido varchar2(20) not null,--(Pode ser "Em Processamento", "Entregue", "Cancelado", etc.)
                      vlr_pedido number(14,2) not null,
                      CONSTRAINT pedidos_pk PRIMARY KEY (id),
                      CONSTRAINT id_cliente_fk FOREIGN KEY (id_cliente)
                                               REFERENCES clientes(id),
                      CONSTRAINT id_produto_fk FOREIGN KEY (id_produto)
                                               REFERENCES produtos(id)              
                                               );                    

CREATE SEQUENCE pedidos_id_seq minvalue 1 
                               start with 1
                               increment by 1
                               cache 20;  

CREATE OR REPLACE TRIGGER pedidos_on_insert
  BEFORE INSERT ON pedidos
  FOR EACH ROW
BEGIN
  SELECT pedidos_id_seq.nextval
  INTO :new.id
  FROM dual;
END;

/*
insert into pedidos values (null,1,1,sysdate,200,'Teste3',400.50);

 select * from pedidos;
select to_char(dt_pedido, 'DD-MM-YYYY HH24:MI:SS') from pedidos;
*/