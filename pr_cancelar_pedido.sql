/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 25/12/2024
   #  Descricao: Script para criação da procedure responsável por cancelar um pedido 
   #             e atualizar a quantidade de estoque do produto
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

CREATE OR REPLACE PROCEDURE cancelar_pedido (v_id_pedido  in pedidos.id%type) 
IS
  v_EXCEPTION EXCEPTION;
  v_error_msg varchar2(1000);
  v_fl_error int;
  v_n integer;
  v_id_produto_anterior pedidos.id_produto%type;
  v_qtd_prod_anterior   pedidos.qtd_prod%type;
  v_status_pedido       pedidos.status_pedido%type;
BEGIN
    v_error_msg := null; 
    v_fl_error := 0;
    v_n := 0;

    -- validando entradas
    if (v_id_pedido is null) then
        v_error_msg := ' - Id_pedido deve ser informado'; 
        v_fl_error := 1;
    else 
        select 1 into v_n from pedidos where id = v_id_pedido; -- Testando se pedido existe na base, no_data_found excep     
    end if;   

    -- Busca e guarda informacoes anteriores do pedido:
    select id_produto, qtd_prod, status_pedido 
      into v_id_produto_anterior, v_qtd_prod_anterior, v_status_pedido from pedidos where id = v_id_pedido;    
    
    if v_fl_error != 0 then
        v_error_msg := 'pr_cancelar_pedido - 01 - Erro na entrada de valores: ' || v_error_msg;
        Raise v_EXCEPTION;    
    end if;

    if (v_status_pedido = 'Cancelado') then -- Testa se o pedido já está cancelado
        v_error_msg := 'pr_cancelar_pedido - 02 - Pedido Id: ' || to_char(v_id_pedido) || ' já está cancelado, favor informar um Id_pedido válido';
        Raise v_EXCEPTION;    
    end if;

    update pedidos set status_pedido = 'Cancelado' where id = v_id_pedido;

    update produtos set qtd_estoque = (qtd_estoque +  v_qtd_prod_anterior) where id = v_id_produto_anterior; -- Atualiza o estoque
    commit;    

    DBMS_OUTPUT.PUT_LINE ('Pedido ID: '|| to_char(v_id_pedido) ||' Cancelado com sucesso!'); 

    EXCEPTION
      When NO_DATA_FOUND then
        Begin
          if v_n = 0 then
            DBMS_OUTPUT.PUT_LINE('Não foi encontrado o pedido informado, favor informar um Id_pedido válido' || v_error_msg);
          end if;
        End;  

          Return;
      when others then
        DBMS_OUTPUT.PUT_LINE(v_error_msg);
        Begin
            RETURN;
        End;    

END;    