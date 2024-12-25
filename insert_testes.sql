/* ############################################################################################################
   #  Autor: Antonio Kobus de Almeida || Data: 24/12/2024
   #  Descricao: Script para inserir registros de testes nas tabelas de clientes e produtos 
   #             
   #  Servidor: xxx Banco: xxx
   #  Alteracoes
   #  Data       Autor          Descricao
   #  ---------- -------------- --------------------------------------------------------------------------------  
   #############################################################################################################
*/

Begin
    insert into clientes values (null,'Antonio Kobus de Almeida2','Rua Machadinho 1065 Bairro Rio Branco Canoas RS cep 92200440','Antonio.kobus@gmail.com',51996031600);
    insert into clientes values (null,'Antonio Kobus de Almeida3','Rua Machadinho 1065 Bairro Rio Branco Canoas RS cep 92200440','Antonio.kobus@gmail.com',51996031600);
    insert into produtos values (null,'Água Mineral Fonte da Pedra','Garrafa de 500ml de Água Mineral Fonte da Pedra',1.25,5000);
    insert into produtos values (null,'Leite','Caixa de 1L de Leite Parmalat',5.25,2000);
    commit;
End;