/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 25/12/2024
   #  Descricao: Script para criação da funcao responsavel por retornar o valor total do pedido.
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

CREATE OR REPLACE FUNCTION calcular_total_pedido (v_id_pedido pedidos.id%type)
  RETURN number
IS 
  v_vlr_pedido pedidos.vlr_pedido%type;
  v_EXCEPTION EXCEPTION;
  v_error_msg varchar2(1000);
  v_fl_error int;
  v_n integer;
BEGIN
    v_vlr_pedido := 0;
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

    if v_fl_error != 0 then
        v_error_msg := 'fn_calcular_total_pedido - 01 - Erro na entrada de valores: ' || v_error_msg;
        Raise v_EXCEPTION;    
    end if; 

	  select vlr_pedido into v_vlr_pedido from pedidos where id = v_id_pedido;    
    Return v_vlr_pedido;

    EXCEPTION
      When NO_DATA_FOUND then
        Begin
          if v_n = 0 then
            DBMS_OUTPUT.PUT_LINE('Não foi encontrado o pedido informado, favor informar um Id_pedido válido' || v_error_msg);
            Return null;
          end if;
        End;  
          
      when others then
        Begin
          DBMS_OUTPUT.PUT_LINE(v_error_msg);
          Return null;
        End;

END;