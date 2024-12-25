/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 25/12/2024
   #  Descricao: Script para criação da funcao responsavel por buscar e retornar todo histórico 
   #             de pedidos de um cliente em formato json.
   #
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

create or replace function historico_pedidos_cliente
(v_id_cliente in pedidos.id_cliente%type)

return clob
as
Cur_Hist_Pedidos SYS_REFCURSOR;
v_EXCEPTION EXCEPTION;
  v_error_msg varchar2(1000);
  v_fl_error int;
  v_n integer;
begin

    v_error_msg := null; 
    v_fl_error := 0;
    v_n := 0;

    -- validando entradas
    if (v_id_cliente is null) then
        v_error_msg := ' - Id_cliente deve ser informado'; 
        v_fl_error := 1;
    else 
        select 1 into v_n from pedidos where id_cliente = v_id_cliente and rownum = 1; -- Testando se existe pelo menos um pedido do cliente informado na base, no_data_found excep      
    end if;  

    if v_fl_error != 0 then
        v_error_msg := 'fn historico_pedidos_cliente - 01 - Erro na entrada de valores: ' || v_error_msg;
        Raise v_EXCEPTION;    
    end if;

    open Cur_Hist_Pedidos for Select id as "Id do Pedido", to_char(dt_pedido, 'DD-MM-YYYY HH24:MI:SS') as "Data do Pedido", status_pedido, vlr_pedido as "Valor do Pedido - R$"
                          From pedidos where id_cliente = v_id_cliente order by dt_pedido desc;
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        APEX_JSON.write('Histórico de pedidos do Id_cliente: ' || to_char(v_id_cliente) ,Cur_Hist_Pedidos);
        APEX_JSON.close_object;
        return APEX_JSON.get_clob_output;
        APEX_JSON.free_output;  

    EXCEPTION
      When NO_DATA_FOUND then
        Begin
          if v_n = 0 then
            DBMS_OUTPUT.PUT_LINE('Não foi encontrado pedidos para o cliente informado, favor informar um Id_cliente válido' || v_error_msg);
            Return null;
          end if;
        End;  
          
      when OTHERS then
        Begin
            DBMS_OUTPUT.PUT_LINE(v_error_msg);
            Return null;
        End;
        
end;
