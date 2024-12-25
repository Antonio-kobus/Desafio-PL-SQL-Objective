/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 24/12/2024
   #  Descricao: Script para criação da procedure responsável por criar um pedido 
   #             e atualizar a quantidade de estoque do produto
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

CREATE OR REPLACE PROCEDURE criar_pedido (
  v_id_cliente pedidos.id_cliente%type,
  v_id_produto pedidos.id_produto%type,
  v_qtd_prod   pedidos.qtd_prod%type,
  v_dt_pedido  pedidos.dt_pedido%type) 
IS
  v_EXCEPTION    EXCEPTION;
  v_error_msg    varchar2(1000);
  v_fl_error     int;
  v_qtd_estoque  produtos.qtd_estoque%type;
  v_nome_produto produtos.nome_produto%type;
  v_preco        produtos.preco%type;
  v_n            integer;
BEGIN
    v_error_msg := null; 
    v_fl_error := 0;
    v_n := 0;

    -- validando entradas
    if (v_id_cliente is null) then
        v_error_msg := ' - Id_cliente deve ser informado'; 
        v_fl_error := 1; v_n :=1;
    else 
        select 1 into v_n from clientes where id = v_id_cliente; -- Testando se cliente existe na base, no_data_found excep    
    end if;    
    
    if (v_id_produto is null)  then  
        v_error_msg := v_error_msg || ' - Id_produto deve ser informado';
        v_fl_error := 1; 
    else 
        select 2 into v_n from produtos where id = v_id_produto; -- Testando se produto existe na base, no_data_found excep      
    end if;
    
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
    
    if v_fl_error != 0 then
        v_error_msg := 'pr_criar_pedido - 01 - Erro na entrada de valores: ' || v_error_msg;
        Raise v_EXCEPTION;    
    end if;

    select qtd_estoque, nome_produto, preco into 
           v_qtd_estoque, v_nome_produto, v_preco
        from produtos where id = v_id_produto;  

    if v_qtd_estoque < v_qtd_prod then 
        v_error_msg := 'pr_criar_pedido - 02 - Quantidade em Estoque inferior à solicitada no pedido, favor refazer o pedido com no máximo ' || to_char (v_qtd_estoque) || ' unidades do produto ' || v_nome_produto;
        Raise v_EXCEPTION;
    else
        insert into pedidos values (null,v_id_cliente,v_id_produto, v_dt_pedido ,v_qtd_prod,'Pedido Realizado', v_preco * v_qtd_prod);
        update produtos set qtd_estoque = qtd_estoque - v_qtd_prod where id = v_id_produto;
        commit;    
        DBMS_OUTPUT.PUT_LINE ('Pedido realizado com sucesso: Produto: ' || v_nome_produto || '- Quantidade: ' || to_char (v_qtd_prod) || ' - Valor do pedido: ' || to_char (v_preco * v_qtd_prod) );
    end if;  

    EXCEPTION
      When NO_DATA_FOUND then
        Begin 
            if v_n = 0 then
              DBMS_OUTPUT.PUT_LINE('Id_cliente informado não está cadastrado, favor informar um Id_cliente válido' || v_error_msg);
            end if;
        
            if v_n = 1 then
              DBMS_OUTPUT.PUT_LINE('Id_produto informado não está cadastrado, favor informar um Id_produto válido' || v_error_msg);
            end if;
            Return;
        End;  
      When others then
        Begin
            DBMS_OUTPUT.PUT_LINE(v_error_msg);
            Return;
        End;
END;