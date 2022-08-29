#### O que é registro estruturado?
O problema com os arquivos de log é que eles são dados de texto não estruturados. Isso torna difícil consultá-los para qualquer tipo de informação útil. Como desenvolvedor, seria bom poder filtrar todos os logs por um determinado cliente # ou transação #. O objetivo do registro estruturado é resolver esses tipos de problemas e permitir análises adicionais.

Para que os arquivos de log tenham uma funcionalidade mais avançada legível por máquina, eles precisam ser escritos em um formato estruturado que possa ser facilmente analisado. Pode ser XML, JSON ou outros formatos. Mas como praticamente tudo hoje em dia é JSON, é mais provável que você veja JSON como o formato padrão para log estruturado.

#### O registro estruturado pode ser usado para alguns casos de uso diferentes:
* Processar arquivos de log para análise ou inteligência de negócios – Um bom exemplo disso seria processar logs de acesso ao servidor da Web e fazer algumas sumarizações e agregações básicas nos dados.
* Pesquisando arquivos de log – Ser capaz de pesquisar e correlacionar mensagens de log é muito valioso para as equipes de desenvolvimento durante o processo de desenvolvimento e para solucionar problemas de produção.

#### Exemplo de registro estruturado
Um exemplo simples provavelmente ajudará a esclarecer o que realmente é o registro estruturado.
Normalmente, você pode gravar em um arquivo de log como este:

```bash
log.Debug("Incoming metrics data");
```
Isso produziria uma linha como esta em seu log:
```bash
DEBUG 2017-01-27 16:17:58 – Incoming metrics data
```

Dependendo de sua estrutura de registro, o registro de alguns campos adicionais seria feito assim. Isso permite que você pesquise com facilidade nesses campos personalizados.

```bash
log.Debug("Incoming metrics data", new {clientid=54732});
```

Isso produziria uma linha como esta em seu log, agora incluindo o campo extra:
```bash
DEBUG 2017-01-27 16:17:58 – Incoming metrics data {"clientid":54732}
```

Como um exemplo separado com a biblioteca de log NLog para .NET , você pode usá-la e especificar um JsonLayout junto com os campos que deseja registrar e produzirá muito facilmente um arquivo de log JSON com cada linha parecida com esta:

```json
{ "time" : "2010-01-01 12:34:56.0000" , "level" : "ERRO" , "message" : "hello, word" }   
```

Se você estivesse usando o log estruturado e enviando-o para um sistema de gerenciamento de log, ele serializaria toda a mensagem e metadados adicionais como JSON. Isso faz parte do poder de usar logs estruturados e um sistema de gerenciamento de logs que os suporte. Aqui está um exemplo do que algo como as bibliotecas de log do Stackify carregam no Retrace para nosso sistema de gerenciamento de log.

```json
[{ "Env" : "Dev" , "ServerName" : "LAPTOP1" , "AppName" : "ConsoleApplication1.vshost.exe" , "AppLoc" : "C:\BitBucket\stackify-api-dotnet\Src\ConsoleApplication1\ bin\Debug\ConsoleApplication1.exe" , "Logger" : "StackifyLib.net" , "Platform" : ".net" , "Msgs" : [{ "Msg" : "Dados de métricas de entrada" , "data" : "{ "clientid ":54732}" , "Tópico" : "10" ,
          
          
          
          
          
          
          
                  
                  
                  
                "EpochMs" : 1485555302470 , "Level" : "DEBUG" , "id" : "0c28701b-e4de-11e6-8936-8975598968a4" } ] } ]  
```

É importante saber que não existe um padrão real para o registro estruturado e isso pode ser feito de várias maneiras diferentes. Para obter o máximo valor disso, você precisa usar uma estrutura de log (como log4net , log4j, etc) que suporte o log de propriedades adicionais e, em seguida, envie esses dados para um sistema de gerenciamento de log que possa aceitar seus campos personalizados e indexá-los.

#### Como visualizar logs estruturados
Se você estiver programando com .NET ou Java, poderá usar Prefix para visualizar o que seu código está fazendo por meio do rastreamento de transações junto com seu registro. O prefix pode até mostrar quaisquer propriedades personalizadas que estão sendo registradas como JSON. Prefix é gratuito e é o melhor visualizador de log que os desenvolvedores podem obter.

#### Como usamos o registro estruturado no Stackify
Na Stackify, usamos o registro estruturado principalmente para facilitar a pesquisa de nossos registros. Nós nos preocupamos mais com os benefícios que ele oferece aos nossos desenvolvedores a partir do nosso sistema de registro.
Quando olhamos para nossos logs, eles se parecem com isso abaixo. Você pode ver todos os campos personalizados que registramos porque eles aparecem como JSON.

Isso nos permite pesquisar muito facilmente por qualquer um desses campos por meio do nosso sistema de gerenciamento de logs .
Uma pesquisa simples como esta: “clientidNumber:54732”, nos mostra apenas esses logs, nos ajudando a diminuir rapidamente os problemas para um cliente específico. Posso pesquisar em todos os aplicativos e servidores que temos em um só lugar.

* DICA: Registre campos extras em exceções!
Um dos melhores usos do log estruturado é nas exceções. Tentar descobrir por que uma exceção aconteceu é infinitamente mais fácil se você souber mais detalhes sobre quem era o usuário, parâmetros de entrada etc.

```java
try
    {
        //do something
    }
    catch (Exception ex)
    {
        log.Error("Error trying to do something", new { clientid = 54732, user = "matt" }, ex);
    }
```

#### Considerações finais sobre sistemas de registro estruturados
Na verdade, não demora mais para registrar propriedades personalizadas à medida que você escreve seu registro. Essas propriedades extras podem fornecer mais detalhes que facilitam a solução de problemas do aplicativo. Se você estiver usando um sistema de gerenciamento de logs que suporte a pesquisa por esses campos personalizados, também poderá pesquisar seus logs por essas novas propriedades.

