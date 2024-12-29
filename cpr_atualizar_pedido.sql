/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 24/12/2024
   #  Descricao: Script para criação da procedure responsável por alterar um pedido 
   #             e atualizar a quantidade de estoque do produto
   #  Servidor: xxx Banco: xxxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

CREATE OR REPLACE PROCEDURE atualizar_pedido (
  v_id_pedido  pedidos.id%type,
  v_id_produto pedidos.id_produto%type,
  v_qtd_prod   pedidos.qtd_prod%type,
  v_dt_pedido  pedidos.dt_pedido%type) 
IS
  v_EXCEPTION EXCEPTION;
  v_error_msg           varchar2(1000);
  v_fl_error            int;
  v_qtd_estoque         produtos.qtd_estoque%type;
  v_nome_produto        produtos.nome_produto%type;
  v_preco               produtos.preco%type;
  v_n                   integer;
  v_id_produto_anterior pedidos.id_produto%type;
  v_qtd_prod_anterior   pedidos.qtd_prod%type;
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
        if v_id_produto is not null then
            select 2 into v_n from produtos where id = v_id_produto; -- Testando se produto existe na base, no_data_found excep 
        end if;    
    end if;   

    -- Busca e guarda informacoes anteriores do pedido:
    select id_produto, qtd_prod 
      into v_id_produto_anterior, v_qtd_prod_anterior from pedidos where id = v_id_pedido;  
    
    if (v_qtd_prod is null) then
        v_error_msg := v_error_msg || ' - Quantidade do produto deve ser informado';
        v_fl_error := 1; 
    else 
        if(v_qtd_prod) < 0 then
            v_error_msg := v_error_msg || ' - Quantidade do produto não pode ser negativa';
            v_fl_error := 1;    
        end if;    
    end if;
    
    if (v_dt_pedido is null) then
        v_error_msg := v_error_msg || ' - Data do pedido deve ser informada';
        v_fl_error := 1; 
    end if;    

    if (((v_id_produto_anterior = v_id_produto) or v_id_produto is null) and v_qtd_prod_anterior = v_qtd_prod) then
        v_error_msg := v_error_msg || ' - Não houve alteração no pedido';
        v_fl_error := 1; 
    end if;
    
    if v_fl_error != 0 then
        v_error_msg := 'pr_atualizar_pedido - 01 - Erro na entrada de valores: ' || v_error_msg;
        Raise v_EXCEPTION;    
    end if;

    

    if v_id_produto != v_id_produto_anterior then
        select qtd_estoque, nome_produto, preco into -- Busca informacoes do estoque atual
               v_qtd_estoque, v_nome_produto, v_preco
        from produtos where id = v_id_produto; 

        if v_qtd_estoque < v_qtd_prod then 
            v_error_msg := 'pr_atualizar_pedido - 02 - Quantidade em Estoque inferior à solicitada no pedido, favor refazer o pedido com no máximo ' || to_char (v_qtd_estoque) || ' unidades do produto ' || v_nome_produto;
            Raise v_EXCEPTION;
        else
            update produtos set qtd_estoque = qtd_estoque + v_qtd_prod_anterior where id = v_id_produto_anterior; -- Atualiza o estoque do produto anterior

            update pedidos set id_produto = v_id_produto, dt_pedido = v_dt_pedido, qtd_prod = v_qtd_prod, status_pedido = 'Pedido Atualizado', vlr_pedido = v_preco * v_qtd_prod
                where id = v_id_pedido;

            update produtos set qtd_estoque = qtd_estoque - v_qtd_prod where id = v_id_produto; -- Atualiza o estoque do produto novo
            commit;     
        end if;    
    else
        select qtd_estoque, nome_produto, preco into -- Busca informacoes do estoque atual
           v_qtd_estoque, v_nome_produto, v_preco
        from produtos where id = v_id_produto_anterior; 

        if v_qtd_estoque < (v_qtd_prod - v_qtd_prod_anterior) then 
            v_error_msg := 'pr_atualizar_pedido - 02 - Quantidade em Estoque inferior à solicitada no pedido, favor refazer o pedido com no máximo ' || to_char (v_qtd_estoque + v_qtd_prod_anterior) || ' unidades do produto ' || v_nome_produto;
            Raise v_EXCEPTION;
        else
            update pedidos set dt_pedido = v_dt_pedido, qtd_prod = v_qtd_prod, status_pedido = 'Pedido Atualizado', vlr_pedido = v_preco * v_qtd_prod
                    where id = v_id_pedido;
            update produtos set qtd_estoque = (qtd_estoque - (v_qtd_prod - v_qtd_prod_anterior)) where id = v_id_produto_anterior; -- Atualiza o estoque, vai funcionar mesmo se estiver entrando produtos no estoque
            commit;
        end if;
               
    end if;      

    DBMS_OUTPUT.PUT_LINE ('Pedido atualizado com sucesso: Produto: ' || v_nome_produto || '- Quantidade: ' || to_char (v_qtd_prod) || ' - Valor do pedido: ' || to_char (v_preco * v_qtd_prod) ); 

    EXCEPTION
      When NO_DATA_FOUND then
        Begin
            if v_n = 0 then
              DBMS_OUTPUT.PUT_LINE('Não foi encontrado o pedido informado, favor informar um Id_pedido válido' || v_error_msg);
            end if;
  
            if v_n = 1 then
              DBMS_OUTPUT.PUT_LINE('Não foi encontrado o produto informado, favor informar um Id_produto válido' || v_error_msg);
            end if;
            Return;
        End;  
      when others then
            Begin
            DBMS_OUTPUT.PUT_LINE(v_error_msg);
            RETURN;
        End;

END;    