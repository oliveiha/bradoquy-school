Plataforma de mensageria e streaming 

Videos Youtube

https://www.youtube.com/watch?v=Bej0mMrr1nI

[Infográfico](https://whimsical.com/kafka-EbWjeGL3gDg9apxewMyGhB)

[Site oficial Apache Kafka](https://kafka.apache.org/)

[Confluent](https://www.confluent.io/)

[Confluent training](https://training.confluent.io/schedule)

# Por que vc precisa do apache-kafka? <h1>

# Events: <h3>
* Para sistemas conversar com outros sistemas
* Devices IOT
* MOnitoracao 
* Alarms

# Historico de Dados <h1>
- Armazena todos os eventos de dados


# O que é streaming de eventos? <h1>
O streaming de eventos é o equivalente digital do sistema nervoso central do corpo humano. É a base tecnológica para o mundo "sempre ativo", onde as empresas são cada vez mais definidas e automatizadas por software .
Tecnicamente falando, o streaming de eventos é a prática de capturar dados em tempo real de fontes de eventos como bancos de dados, sensores, dispositivos móveis, serviços em nuvem e aplicativos de software na forma de fluxos de eventos; armazenar esses fluxos de eventos de forma durável para recuperação posterior; manipular, processar e reagir aos fluxos de eventos em tempo real e também retrospectivamente; e rotear os fluxos de eventos para diferentes tecnologias de destino, conforme necessário. O streaming de eventos, portanto, garante um fluxo contínuo e interpretação dos dados para que as informações certas estejam no lugar certo, na hora certa.

# Para que posso usar o streaming de eventos? <h1>
O streaming de eventos é aplicado a uma ampla variedade de casos de uso em uma infinidade de setores e organizações. Seus muitos exemplos incluem:

Para processar pagamentos e transações financeiras em tempo real, como em bolsas de valores, bancos e seguros.
Para rastrear e monitorar carros, caminhões, frotas e remessas em tempo real, como na logística e na indústria automotiva.
Para capturar e analisar continuamente os dados do sensor de dispositivos IoT ou outros equipamentos, como fábricas e parques eólicos.
Para coletar e reagir imediatamente às interações e pedidos do cliente, como no varejo, no setor de hotéis e viagens e em aplicativos móveis.
Para monitorar pacientes em cuidados hospitalares e prever mudanças nas condições para garantir o tratamento oportuno em emergências.
Conectar, armazenar e disponibilizar dados produzidos por diferentes divisões de uma empresa.
Para servir como base para plataformas de dados, arquiteturas orientadas a eventos e microsserviços.

# Apache Kafka® é uma plataforma de streaming de eventos. O que isso significa? <h1>
O Kafka combina três recursos principais para que você possa implementar seus casos de uso para streaming de eventos de ponta a ponta com uma única solução testada em batalha:

* Para publicar (gravar) e assinar (ler) fluxos de eventos, incluindo importação / exportação contínua de seus dados de outros sistemas.
* Para armazenar streams de eventos de forma durável e confiável pelo tempo que você quiser.
* Para processar fluxos de eventos conforme eles ocorrem ou retrospectivamente.
E toda essa funcionalidade é fornecida de maneira distribuída, altamente escalável, elástica, tolerante a falhas e segura. O Kafka pode ser implantado em hardware bare-metal, máquinas virtuais e contêineres, e no local, bem como na nuvem. Você pode escolher entre o autogerenciamento de seus ambientes Kafka e o uso de serviços totalmente gerenciados oferecidos por diversos fornecedores.

# Como funciona o Kafka em poucas palavras? <h1>
Kafka é um sistema distribuído que consiste em servidores e clientes que se comunicam por meio de um protocolo de rede TCP de alto desempenho . Ele pode ser implantado em hardware bare-metal, máquinas virtuais e contêineres no local, bem como em ambientes de nuvem.

__Servidores__ : o Kafka é executado como um cluster de um ou mais servidores que podem abranger vários datacenters ou regiões de nuvem. Alguns desses __servidores formam a camada de armazenamento, chamados brokers__. Outros servidores executam o Kafka Connect para importar e exportar dados continuamente como fluxos de eventos para integrar o Kafka com seus sistemas existentes, como bancos de dados relacionais, bem como outros clusters Kafka. Para permitir que você implemente casos de uso de missão crítica, um cluster Kafka é altamente escalonável e tolerante a falhas: se algum de seus servidores falhar, os outros servidores assumirão seu trabalho para garantir operações contínuas sem qualquer perda de dados.

__Clientes__ : eles permitem que você escreva aplicativos e microsserviços distribuídos que leem, gravam e processam fluxos de eventos em paralelo, em escala e de maneira tolerante a falhas, mesmo no caso de problemas de rede ou de máquina. O Kafka vem com alguns desses clientes incluídos, que são aumentados por dezenas de clientes fornecidos pela comunidade Kafka: os clientes estão disponíveis para Java e Scala, incluindo a biblioteca Kafka Streams de nível superior , para Go, Python, C / C ++ e muitas outras para outras linguagens de programação, bem como APIs REST.


![Arquitetura Apache Kafka](./img01.png)

# Principais conceitos e terminologia <h1>
Um evento registra o fato de que "algo aconteceu" no mundo ou no seu negócio. Também é chamado de registro ou mensagem na documentação. Ao ler ou gravar dados no Kafka, você o faz na forma de eventos. Conceitualmente, um evento possui uma chave, valor, carimbo de data / hora e cabeçalhos de metadados opcionais. Aqui está um exemplo de evento:

Chave do evento: "Alice"
Valor do evento: "Efetuou um pagamento de $ 200 para Bob"
Data e hora do evento: "25 de junho de 2020 às 14h06"

Os __Producers__ são os aplicativos clientes que publicam (gravam) eventos no Kafka e os __consumers__ são os que assinam (lêem e processam) esses eventos. No Kafka, producers e consumers estão totalmente dissociados e agnósticos entre si, o que é um elemento chave do design para alcançar a alta escalabilidade pela qual Kafka é conhecido. Por exemplo, os producers nunca precisam esperar pelos consumers. O Kafka oferece várias garantias , como a capacidade de processar eventos exatamente uma vez.

Os eventos são organizados e armazenados de forma duradoura em __topics__ . Muito simplificado, um __topic é semelhante a uma pasta em um sistema de arquivos__, e os eventos são os arquivos dessa pasta. Um exemplo de nome de topic poderia ser "pagamentos". Os topics no Kafka são sempre __multi-producer__ e __multi-subscriber:__ um topic pode ter zero, um ou muitos producers que gravam eventos nele, bem como zero, um ou muitos consumers que assinam esses eventos. Os eventos em um topic podem ser lidos com a frequência necessária - ao contrário dos sistemas de mensagens tradicionais, os eventos não são excluídos após o consumo. Em vez disso, __você define por quanto tempo o Kafka deve reter seus eventos por meio de uma definição de configuração por topic__, após o qual os eventos antigos serão descartados. O desempenho do Kafka é efetivamente constante em relação ao tamanho dos dados, portanto, armazenar dados por um longo tempo é perfeitamente adequado.

Os topics são particionados , o que significa que __um topic é espalhado por vários "buckets"__ localizados em diferentes Kafka brokers. Esse posicionamento distribuído de seus dados é muito importante para a escalabilidade, pois permite que os aplicativos clientes leiam e gravem os dados de / para vários brokers ao mesmo tempo. Quando um novo evento é publicado em um topic, ele na verdade é anexado a uma das partições do topic. Eventos com a mesma chave de evento (por exemplo, um cliente ou ID de veículo) são gravados na mesma partição, e Kafka garante que qualquer consumers de uma determinada partição de topic sempre lerá os eventos dessa partição exatamente na mesma ordem em que foram gravados.

Para tornar seus dados tolerantes a falhas e altamente disponíveis, todos os topics podem ser replicados , mesmo em regiões geográficas ou datacenters, de modo que sempre haja vários brokers que tenham uma cópia dos dados, caso algo dê errado, você deseja fazer manutenção nos brokers e assim por diante. Uma configuração de produção comum é um fator de replicação de 3, ou seja, sempre haverá três cópias de seus dados. Essa replicação é realizada no nível das partições de topic.

# Distribuição de partições entre Brokers <h1>

## Replication Broker <h3> 

Para tornar seus dados tolerantes a falhas e altamente disponíveis, todos os tópicos podem ser replicados, mesmo em regiões geográficas ou datacenters, de modo que sempre haja vários brokers com uma cópia dos dados, caso algo dê errado, você deseja fazer manutenção nos brokers e assim por diante. Uma configuração de produção comum é um fator de replicação de 3, ou seja, sempre haverá três cópias de seus dados. Essa replicação é realizada no nível das partições de tópico.

Este primer deve ser suficiente para uma introdução. A seção Design da documentação explica os vários conceitos do Kafka em detalhes completos, se você estiver interessado.
[documentação Apache Kafka](https://kafka.apache.org/documentation/#design) 

## Delivery <h3>

Algoritmo Round Robin

Exemplo | topic com 3 partições com mensagens sem "key"

                |---> partição 1
topic Sales /_  |---> partição 2 
            \   |---> partição 3 

Mensagens com __"key"__ são gravados sempre na mesma partição

*** Importante ***
O processo de entrega de menssagens é muito complexo, se pegarmos um sistema tradicional de filas como o RabbitMQ que utiliza o FIFO (first in first out) ,ou seja, a primeira mensagem que entra é a primeira mensagem que sai. Com isso da para garantir a ordem das mensagens.
Como o Kafka trabalha com partições distribuidas, nós não conseguimos garantir a ordem de entrega das mensagens porque uma hora voce esta lendo da partição 1 outra da partição 2 e assim por diante, então nesse momento partimos do principio que as mensagens que estão chegando para mim estão desordenadas.
Porém, existem casos que precisamos que de alguma forma as mensagens estejam ordenadas e neste caso conseguimos manter a ordem das mensagens trabalhando com a mesma __"key"__
Exemplo, se enviamos uma mensagem com a key vendas e ela for gravada na partição 1, logo ela sempre será gravada na partição 1 e assim garantiremos a ordem das mensagens.


## Partition Leadership <h3>

Cada partição possui um servidor que atua como "líder" e zero ou mais servidores que atuam como "seguidores". O líder lida com todas as solicitações de leitura e gravação para a partição, enquanto os seguidores replicam passivamente o líder. Se o líder falhar, um dos seguidores se tornará automaticamente o novo líder. Cada servidor atua como um líder para algumas de suas partições e um seguidor para outras, de forma que a carga seja bem balanceada dentro do cluster.
Portanto, um líder de partição é, na verdade, o broker que atende a esse propósito e é responsável por todas as solicitações de leitura e gravação para essa partição específica.

# Observação <h1> 
`` Igualmente ao banco de dados ETCD, o kafka tambem utiliza o protocolo Raft para eleição de leaders e controle de Quorum "https://cwiki.apache.org/confluence/display/KAFKA/KIP-595%3A+A+Raft+Protocol+for+the+Metadata+Quorum" `` 

## Eleição do líder da partição <h3>

A designação de um líder para uma partição específica acontece durante um processo denominado eleição do líder da partição . Este processo acontece quando o tópico / partição é criado ou quando o líder da partição (ou seja, o corretor) não está disponível por qualquer motivo.

Além disso, você pode forçar a eleição de réplica preferencial usando a __https://cwiki.apache.org/confluence/display/KAFKA/Replication+tools#Replicationtools-1.PreferredReplicaLeaderElectionTool__

Com a replicação, cada partição pode ter várias réplicas. A lista de réplicas de uma partição é chamada de "réplicas atribuídas". A primeira réplica nesta lista é a "réplica preferida". Quando o tópico / partições são criados, Kafka garante que a "réplica preferencial" para as partições entre os tópicos seja igualmente distribuída entre os brokers em um cluster. Em um cenário ideal, o líder para uma determinada partição deve ser a "réplica preferida". Isso garante que a carga de liderança entre os brokers em um cluster seja equilibrada de maneira uniforme. No entanto, com o tempo, a carga de liderança pode ficar desequilibrada devido a desligamentos do broker (causados ​​por desligamento controlado, travamentos, falhas de máquina, etc.). 
Essa ferramenta ajuda a restaurar o equilíbrio de liderança entre os corretores do cluster.

# Producer <h1>

Delivery Process
1 - Record (vou falar qual é o Topic, qual é key, qual é o value)
2 - No meu programa (python, java etc) faço um "Send()"
3 - No kafka tem um cara chamado "Serializer" por que podemos enviar mensagens em diversos formatos e o serializer vai adequar o formato correto que ele vai serializar as mensagens
Ex
StringSerializer
ShortSerializer
IntegerSerializer
LongSerializer
DoubleSerializer
BytesSerializer
5 - Partioner "Escolhe em que partição a mensagem sera gravada"
6 - Grava a mensagem (Broker A, Topic Sales, partition 1)

Delivery guarantees (nada é tão facil assim)

[explicacão sobre garantias no Kafka](https://medium.com/@andy.bryant/processing-guarantees-in-kafka-12dd2e30be0e)

Agora que entendemos um pouco sobre como os producers trabalham, vamos discutir as __garantias semânticas que Kafka oferece__ entre producer e consumers. Claramente, existem várias garantias de entrega de mensagem possíveis que podem ser fornecidas:

__At most once__ - as mensagens podem ser perdidas, mas nunca são reenviadas.
__At least once__ - as mensagens nunca são perdidas, mas podem ser reenviadas.
__Exactly once__ - isso é o que as pessoas realmente desejam, cada mensagem é entregue uma vez e apenas uma vez.
É importante notar que isso se divide em dois problemas: __as garantias de durabilidade para publicar__ uma mensagem e as __garantias para consumir uma mensagem__.
Muitos sistemas afirmam fornecer "Exactly once" semântica de entrega, mas é importante ler as letras miúdas, a maioria dessas afirmações são enganosas (ou seja, não se traduzem no caso em que os consumidores ou produtores podem falhar, casos em que há vários processos do consumidor ou casos em que os dados gravados no disco podem ser perdidos).

A semântica de Kafka é direta. Ao publicar uma mensagem, temos uma noção da mensagem sendo "confirmada" no log. Depois que uma mensagem publicada é confirmada, ela não será perdida, contanto que um broker que replica a partição na qual a mensagem foi gravada permaneça "ativo". A definição de mensagem confirmada, partição ativa, bem como uma descrição de quais tipos de falhas tentamos tratar, serão descritos em mais detalhes na próxima seção. Por enquanto, vamos assumir um broker perfeito e sem perdas e tentar entender as garantias para o produtor e o consumidor. Se um produtor tentar publicar uma mensagem e tiver um erro de rede, não poderá ter certeza se esse erro aconteceu antes ou depois de a mensagem ter sido confirmada. Isso é semelhante à semântica de inserir em uma tabela de banco de dados com uma chave gerada automaticamente.

Antes de 0.11.0.0, se um produtor não recebesse uma resposta indicando que uma mensagem foi confirmada, ele não tinha escolha a não ser reenviar a mensagem. Isso fornece semântica de entrega pelo menos uma vez, pois a mensagem pode ser gravada no log novamente durante o reenvio se a solicitação original tiver de fato sido bem-sucedida. Desde 0.11.0.0, o produtor Kafka também suporta uma opção de __entrega__ idempotente que garante que o reenvio não resultará em entradas duplicadas no log. Para conseguir isso, o broker atribui a cada produtor um ID e desduplica mensagens usando um número de sequência que é enviado pelo produtor junto com cada mensagem. Também começando com 0.11.0.0, o produtor suporta a capacidade de enviar mensagens para múltiplas partições de tópicos usando semântica semelhante a transações: ou seja, todas as mensagens são gravadas com sucesso ou nenhuma delas. O principal caso de uso para isso é o processamento exatamente uma vez entre os tópicos do Kafka (descrito abaixo).

Nem todos os casos de uso exigem tais garantias fortes. __Para usos sensíveis à latência, permitimos que o produtor especifique o nível de durabilidade que deseja__. Se o produtor especificar que deseja aguardar a confirmação da mensagem, isso pode demorar cerca de 10 ms. No entanto, o produtor também pode especificar que deseja executar o envio de forma totalmente assíncrona ou que deseja aguardar apenas até que o líder (mas não necessariamente os seguidores) receba a mensagem.

## Idempotent Producers <h3>

o que é o recurso Idempotent Producer?
Quando um producer envia mensagens para um tópico, as coisas podem dar errado, como falhas de conexão etc. Quando isso acontece, todas as mensagens com confirmações pendentes podem ser reenviadas ou descartadas. As mensagens podem ter sido escritas com sucesso no tópico, ou não, não há como saber. Se reenviarmos, podemos duplicar a mensagem, mas se não reenviarmos, a mensagem pode essencialmente ser perdida.
Além disso, o reenvio de mensagens pode fazer com que a ordem das mensagens dê errado. Portanto, podemos acabar com as mensagens entregues duas vezes e fora de serviço.

O recurso de idepomtent Producers aborda esses problemas garantindo que as mensagens sempre sejam entregues, na ordem certa e sem duplicidades.

## Como o Idempotent Producer funciona? <h3>
Quando enable.idempotence é definido como true, nenhuma nova tentativa manual é necessária; na verdade, executar novas tentativas no código do aplicativo ainda causará duplicatas. Deixe as tentativas para sua biblioteca cliente, é totalmente transparente para você como desenvolvedor.

Portanto, novas tentativas são feitas, mas como o broker pode identificar mensagens duplicadas e descartá-las?

Cada produtor recebe um Id do produtor (PID) e inclui seu PID toda vez que envia mensagens a um broker. Além disso, cada mensagem obtém um número de sequência monotonicamente crescente. Uma sequência separada é mantida para cada partição de tópico para a qual um produtor envia mensagens. No lado do broker, em uma base por partição, ele mantém o controle da maior combinação de número de sequência PID que foi gravada com sucesso. Quando um número de sequência inferior é recebido, ele é descartado.

Vejamos um exemplo. Vamos ver o que pode acontecer sem a idempotência habilitada.

Com a idempotência desativada, poderíamos ter a situação em que um producer está enviando mensagens de forma assíncrona para uma partição de tópico, por exemplo, mensagens M1 a M10. Logo após o envio da mensagem 7, a conexão falha. Ele recebeu confirmações para as mensagens 1 a 3. Portanto, as mensagens 4, 5, 6 e 7 são reenviadas, depois as mensagens 8 a 10. Mas o corretor foi de fato capaz de gravar tudo, exceto a mensagem 7, na partição, então agora as mensagens armazenadas na partição estão: M1, M2, M3, M4, M5, M6, M4, M5, M6, M7, M8, M9, M10.

Mas com a idempotência habilitada, cada mensagem vem com um PID e número de sequência:

M1 (PID: 1, SN: 1) - escrito na partição. Para PID 1, SN máx. = 1
M2 (PID: 1, SN: 2) - gravado na partição. Para PID 1, SN máx. = 2
M3 (PID: 1, SN: 3) - escrito na partição. Para PID 1, SN máx. = 3
M4 (PID: 1, SN: 4) - escrito na partição. Para PID 1, SN máx. = 4
M5 (PID: 1, SN: 5) - escrito na partição. Para PID 1, SN máx. = 5
M6 (PID: 1, SN: 6) - escrito na partição. Para PID 1, SN máx. = 6
M4 (PID: 1, SN: 4) - rejeitado, SN <= SN máx.
M5 (PID: 1, SN: 5) - rejeitado, SN <= SN máx.
M6 (PID: 1, SN: 6) - rejeitado, SN <= SN máx.
M7 (PID: 1, SN: 7) - escrito na partição. Para PID 1, SN máx. = 7
M8 (PID: 1, SN: 8) - escrito na partição. Para PID 1, SN máx. = 8
M9 (PID: 1, SN: 9) - escrito na partição. Para PID 1, SN máx. = 9
M10 (PID: 1, SN: 10) - escrito na partição. Para PID 1, SN máx. = 10

Se um broker falhar e um novo líder for eleito, a desduplicação ainda continuará a funcionar porque o PID e o número de sequência estão incluídos nos dados da mensagem. Como todas as mensagens são replicadas para os seguidores, um seguidor eleito como o novo líder já possui todos os dados de que precisa para realizar a desduplicação.

Quando a Idempotent Producer deve ser habilitada?
Se você já usa acks = all, não há razão para não ativar esse recurso. Ele funciona perfeitamente e sem uma complexidade adicional para o desenvolvedor do aplicativo. É apenas uma decisão óbvia.

Se você atualmente usa acks = 0 ou acks = 1 por razões de latência e taxa de transferência, você pode considerar ficar longe desse recurso. Acks = all aumenta as latências e a variabilidade da latência. Se você já usa acks = 0 ou acks = 1, provavelmente valoriza os benefícios de desempenho em relação à consistência de dados.

## Breve explicação sobre acks <h4>
A acks é uma configuração de cliente (producer). Ele denota o número de corretores que devem receber o registro antes de considerarmos a gravação como bem-sucedida. Ele suporta três valores __- 0, 1 e all.__

__'acks = 0'__
Com um valor de 0, o producer nem mesmo espera por uma resposta do corretor. Ele imediatamente considera a gravação bem-sucedida no momento em que o registro é enviado.
![acks 0](./acks0.png)

__'acks = 1'__
Com uma configuração de 1, o producer considerará a gravação bem-sucedida quando o líder receber o registro. O corretor líder saberá responder imediatamente no momento em que receber o registro e não esperar mais.
![acks 1](./acks1.png)

__'acks = all'__
Quando definido como all, o producer considerará a gravação bem-sucedida quando todas as réplicas sincronizadas receberem o registro. Isso é conseguido pelo corretor líder sendo inteligente ao responder à solicitação - ele enviará uma resposta assim que todas as réplicas sincronizadas receberem o registro.
![acks all](./acksall.png)

## Utilidade do Acks <h3>
Como você pode ver, a configuração de acks é uma boa maneira de configurar sua escolha preferida entre garantias de durabilidade e desempenho.
Se você gostaria de ter certeza de que seus registros estão bons e seguros - configure seus acks para all.
Se você valoriza a latência e o rendimento do que dormir bem à noite, defina um limite baixo de 0. Você pode ter uma chance maior de perder mensagens, mas inerentemente tem melhor latência e taxa de transferência.

## Réplica mínima em sincronização <h3>
Há uma coisa faltando com a configuração acks=all isolada.
Se o líder responder quando todas as réplicas sincronizadas tiverem recebido a gravação, o que acontecerá quando o líder for a única réplica sincronizada? Isso não seria equivalente a configuração acks=1?
É aqui que __min.insync.replicas__ vem brilhar!
__min.insync.replicas__ é uma configuração no broker que indica o número mínimo de réplicas sincronizadas necessárias para que um broker permita solicitações acks=all. Ou seja, todas as solicitações com acks=all não serão processadas e receberão uma resposta de erro se o número de réplicas sincronizadas estiver abaixo da quantidade mínima configurada. Ele atua como uma espécie de porteiro para garantir que cenários como o descrito acima não aconteçam.
![min.insync.replicas](./min-replicas.png)

Conforme mostrado, __min.insync.replicas=X__ permite que as solicitações acks = all continuem funcionando quando pelo menos x réplicas da partição estiverem sincronizadas. Aqui, vimos um exemplo com duas réplicas.
Mas se formos abaixo desse valor de réplicas sincronizadas, o produtor começará a receber exceções.
![min.insync.replicas](./min-replicas2.png)

Como você pode ver, os producers acks=all não conseguem gravar na partição com sucesso durante tal situação. Observe, no entanto, que os produtores com acks=0 ou acks=1 continuam a gravar normalmente.

Um equívoco comum é achar que a configuração __min.insync.replicas__ denota quantas réplicas precisam receber o registro para que o líder responda ao producer. 
Isso não é verdade - para a que a solicitação seja processada é necessário ter na verdade um numero de replicas sincronizadas .
Ou seja, se houver três réplicas sincronizadas e min.insync.replicas=2, o líder responderá apenas quando todas as três réplicas tiverem o registro.

# Consumers <h1>

## Kafka Consumers: Lendo Dados do Kafka <h3>

Os aplicativos que precisam ler dados do Kafka usam um Kafka Consumer para assinar os tópicos do Kafka e receber mensagens desses tópicos. Ler dados do Kafka é um pouco diferente do que ler dados de outros sistemas de mensagens e há poucos conceitos e ideias exclusivos envolvidos. É difícil entender como usar a API do consumidor sem entender esses conceitos primeiro. Começaremos explicando alguns dos conceitos importantes e, em seguida, passaremos por alguns exemplos que mostram as diferentes maneiras como as APIs de consumidor podem ser usadas para implementar aplicativos com requisitos variados.

## Kafka Consumer: Conceitos <h3>

Para entender como ler os dados do Kafka, primeiro você precisa entender seus __consumidores e grupos de consumidores__. As seções a seguir cobrem esses conceitos.

## Consumidores e grupos de consumidores <h3>
Suponha você tem um aplicativo que precisa ler mensagens de um tópico Kafka, executar algumas validações nelas e gravar os resultados em outro armazenamento de dados. Neste caso, sua aplicação irá criar um objeto consumidor, assinar o tópico apropriado e começar a receber mensagens, validando-as e escrevendo os resultados. Isso pode funcionar bem por um tempo, mas e se a taxa em que os produtores gravam mensagens no tópico exceder a taxa em que seu aplicativo pode validá-las? Se você estiver limitado a um único consumidor lendo e processando os dados, seu aplicativo pode ficar cada vez mais para trás, incapaz de acompanhar a taxa de mensagens recebidas. Obviamente, é necessário dimensionar o consumo a partir dos tópicos. Assim como vários produtores podem escrever no mesmo tópico, precisamos permitir que vários consumidores leiam o mesmo tópico,

Os consumidores de Kafka normalmente fazem parte de um consumer group. Quando vários consumidores estão inscritos em um tópico e pertencem ao mesmo grupo de consumidores, cada consumidor no grupo receberá mensagens de um subconjunto diferente de partições no tópico.

Vamos pegar o tópico T1 com quatro partições. Agora, suponha que criamos um novo consumidor, C1, que é o único consumidor do grupo G1, e o usamos para assinar o tópico T1. O consumidor C1 obterá todas as mensagens de todas as quatro partições T1
Se adicionarmos outro consumidor, C2, ao grupo G1, cada consumidor receberá apenas mensagens de duas partições. Talvez as mensagens das partições 0 e 2 vão para C1 e as mensagens das partições 1 e 3 vão para o consumidor C2.
Se G1 tiver quatro consumidores, cada um lerá mensagens de uma única partição.
Se adicionarmos mais consumidores a um único grupo com um único tópico do que temos partições, alguns dos consumidores ficarão ociosos e não receberão nenhuma mensagem.

A principal maneira de escalar o consumo de dados de um tópico Kafka é adicionando mais consumidores a um grupo de consumidores. É comum que os consumidores do Kafka façam operações de alta latência, como gravar em um banco de dados ou um cálculo demorado dos dados. Nesses casos, um único consumidor não consegue acompanhar os fluxos de dados da taxa em um tópico, e adicionar mais consumidores que compartilham a carga, tendo cada consumidor como proprietário de apenas um subconjunto das partições e mensagens, é nosso principal método de dimensionamento. Esse é um bom motivo para criar tópicos com um grande número de partições - permite adicionar mais consumidores quando a carga aumenta. Lembre-se de que não adianta adicionar mais consumidores do que partições em um tópico - alguns consumidores ficarão apenas ociosos. Vou dar algumas sugestões sobre como escolher o número de partições em um tópico.

Além de adicionar consumidores para dimensionar um único aplicativo, é muito comum ter vários aplicativos que precisam ler dados do mesmo tópico. Na verdade, um dos principais objetivos de design do Kafka era disponibilizar os dados produzidos para os tópicos do Kafka para muitos casos de uso em toda a organização. Nesses casos, queremos que cada aplicativo obtenha todas as mensagens, em vez de apenas um subconjunto. Para garantir que um aplicativo receba todas as mensagens em um tópico, certifique-se de que o aplicativo tenha seu próprio grupo de consumidores. Ao contrário de muitos sistemas de mensagens tradicionais, o Kafka se adapta a um grande número de consumidores e grupos de consumidores sem reduzir o desempenho.

No exemplo anterior, se adicionarmos um novo grupo de consumidores G2 com um único consumidor, esse consumidor obterá todas as mensagens no tópico T1 independentemente do que G1 está fazendo. G2 pode ter mais de um único consumidor, caso em que cada um receberá um subconjunto de partições, assim como mostramos para G1, mas G2 como um todo ainda receberá todas as mensagens, independentemente de outros grupos de consumidores.

Para resumir, você cria um novo grupo de consumidores para cada aplicativo que precisa de todas as mensagens de um ou mais tópicos. Você adiciona consumidores a um grupo de consumidores existente para dimensionar a leitura e o processamento de mensagens dos tópicos, de forma que cada consumidor adicional em um grupo obtenha apenas um subconjunto das mensagens.

## Grupos de consumidores e reequilíbrio de partições <h3>

Como vimos na seção anterior, os consumidores em um grupo de consumidores compartilham a propriedade das partições nos tópicos que assinam. Quando adicionamos um novo consumidor ao grupo, ele começa a consumir mensagens de partições anteriormente consumidas por outro consumidor. A mesma coisa acontece quando um consumidor desliga ou quebra; ele sai do grupo e as partições que costumava consumir serão consumidas por um dos consumidores restantes. A reatribuição de partições aos consumidores também ocorre quando os tópicos que o grupo de consumidores está consumindo são modificados (por exemplo, se um administrador adicionar novas partições).

Mover a propriedade da partição de um consumidor para outro é chamado de rebalanceamento . Os rebalanceamentos são importantes porque fornecem ao grupo de consumidores alta disponibilidade e escalabilidade (permitindo-nos adicionar e remover consumidores de maneira fácil e segura), mas no curso normal dos eventos eles são bastante indesejáveis. Durante um rebalanceamento, os consumidores não podem consumir mensagens, portanto, um rebalanceamento é basicamente uma janela curta de indisponibilidade de todo o grupo de consumidores. Além disso, quando as partições são movidas de um consumidor para outro, o consumidor perde seu estado atual; se estiver armazenando dados em cache, será necessário atualizar seus caches - tornando o aplicativo mais lento até que o consumidor configure seu estado novamente. Ao longo deste capítulo, discutiremos como lidar com os reequilíbrios com segurança e como evitar os desnecessários.

A maneira como os consumidores mantêm a associação em um grupo de consumidores e a propriedade das partições atribuídas a eles é enviando pulsações para um Corretor Kafka designado como coordenador do grupo (esse corretor pode ser diferente para diferentes grupos de consumidores). Contanto que o consumidor esteja enviando pulsações em intervalos regulares, presume-se que ele esteja ativo, bem e processando mensagens de suas partições. As pulsações são enviadas quando o consumidor pesquisa (ou seja, recupera registros) e quando confirma os registros que consumiu.

Se o consumidor parar de enviar pulsações por tempo suficiente, sua sessão expirará e o coordenador do grupo irá considerá-la morta e acionar um rebalanceamento. Se um consumidor travou e parou de processar mensagens, o coordenador do grupo levará alguns segundos sem pulsações para decidir que está morto e acionar o rebalanceamento. Durante esses segundos, nenhuma mensagem será processada das partições pertencentes ao consumidor morto. Ao fechar um consumidor de forma limpa, o consumidor notificará o coordenador do grupo de que está saindo, e o coordenador do grupo acionará um rebalanceamento imediatamente, reduzindo a lacuna no processamento. Posteriormente neste capítulo, discutiremos as opções de configuração que controlam a frequência de pulsação e os tempos limite de sessão e como defini-los para atender aos seus requisitos.

**ALTERAÇÕES NO COMPORTAMENTO DA PULSAÇÃO EM VERSÕES RECENTES DO KAFKA**
Na liberação 0.10.1, a comunidade Kafka introduziu um encadeamento de pulsação separado que também enviará pulsações entre as pesquisas. Isso permite que você separe a frequência de pulsação (e, portanto, quanto tempo leva para o grupo de consumidores detectar que um consumidor travou e não está mais enviando pulsações) da frequência de pesquisa (que é determinada pelo tempo que leva para processar os dados retornado dos corretores). Com as versões mais recentes do Kafka, você pode configurar quanto tempo o aplicativo pode ficar sem pesquisa antes de deixar o grupo e acionar um rebalanceamento.Esta configuração é usada para prevenir um livelock, onde o aplicativo não travou , mas não conseguiu progredir por algum motivo. Essa configuração é separada de session.timeout.ms, que controla o tempo que leva para detectar uma falha do consumidor e parar de enviar pulsações.

O resto do capítulo discutirá alguns dos desafios com os comportamentos mais antigos e como o programador pode lidar com eles. Este capítulo inclui uma discussão sobre como lidar com aplicativos que demoram mais para processar registros. Isso é menos relevante para leitores que executam o Apache Kafka 0.10.1 ou posterior. Se você estiver usando uma nova versão e precisar lidar com registros que demoram mais para serem processados, **basta ajustar max.poll.interval.mspara** lidar com atrasos mais longos entre as pesquisas de novos registros.

## COMO FUNCIONA O PROCESSO DE ATRIBUIÇÃO DE PARTIÇÕES A CORRETORES? <h3>
Quando um consumidor deseja ingressar em um grupo, ele envia uma solicitação JoinGroup ao coordenador do grupo. **O primeiro consumidor a ingressar no grupo torna-se o líder do grupo** . O líder recebe uma lista de todos os consumidores no grupo do coordenador do grupo (isso incluirá todos os consumidores que enviaram uma pulsação recentemente e que, portanto, são considerados ativos) e é responsável por atribuir um subconjunto de partições a cada consumidor. Ele usa uma implementação de PartitionAssignor para decidir quais partições devem ser tratadas por qual consumidor.

O Kafka tem duas políticas de atribuição de partição integradas, que discutiremos com mais detalhes na seção de configuração. Depois de decidir sobre a atribuição da partição, o líder do grupo de consumidores envia a lista de atribuições ao GroupCoordinator, que envia essas informações a todos os consumidores. Cada consumidor vê apenas sua própria atribuição - o líder é o único processo do cliente que possui a lista completa de consumidores no grupo e suas atribuições. Este processo se repete sempre que ocorre um rebalanceamento.

## Criando um Consumidor Kafka <h3>
A primeira etapa para começar a consumir registros é criar uma instância KafkaConsumer. Criar um KafkaConsumer é muito semelhante a criar um KafkaProducer- você cria uma instância Java Properties com as propriedades que deseja passar ao consumidor. Discutiremos todas as propriedades em detalhes posteriormente neste capítulo.Para começar, só precisa usar as __três propriedades obrigatórias: bootstrap.servers, key.deserializer, e value.deserializer__.

A primeira propriedade,, __bootstrap.servers é a string de conexão para um cluster Kafka__. É usado exatamente da mesma maneira que em KafkaProducer. As outras duas propriedades, key.deserializere value.deserializer, são semelhantes às serializers definidas para o produtor, mas em vez de especificar classes que transformam objetos Java em matrizes de bytes, você precisa especificar classes que podem pegar uma matriz de bytes e transformá-la em um objeto Java.

Há uma quarta propriedade, que não é estritamente obrigatória, mas por enquanto vamos fingir que é. A propriedade é group.ide especifica o grupo de consumidores ao qual a KafkaConsumer instância pertence. Embora seja possível criar consumidores que não pertencem a nenhum grupo de consumidores, isso é incomum; portanto, na maior parte do capítulo, presumiremos que o consumidor faz parte de um grupo.

O seguinte snippet de código mostra como criar um KafkaConsumer:

```Properties props = new Properties();
props.put("bootstrap.servers", "broker1:9092,broker2:9092");
props.put("group.id", "CountryCounter");
props.put("key.deserializer",
    "org.apache.kafka.common.serialization.StringDeserializer");
props.put("value.deserializer",
    "org.apache.kafka.common.serialization.StringDeserializer");

KafkaConsumer<String, String> consumer =
    new KafkaConsumer<String, String>(props);```

Muito do que você vê aqui deve ser familiar se você leu o Capítulo 3 sobre a criação de produtores. Presumimos que os registros que consumimos terão Stringobjetos como a chave e o valor do registro. A única propriedade nova aqui é group.id, que é o nome do grupo de consumidores ao qual esse consumidor pertence.

Inscrevendo-se em Tópicos
Depois de criar um consumidor, a próxima etapa é assinar um ou mais tópicos. O subcribe()método usa uma lista de tópicos como parâmetro, por isso é muito simples de usar:

```
consumer.subscribe (Collections.singletonList ("customerCountries"));
```

Aqui, simplesmente criamos uma lista com um único elemento: o nome do tópico customerCountries.

Também é possível chamar subscribe com uma expressão regular. A expressão pode corresponder a vários nomes de tópicos e, se alguém criar um novo tópico com um nome que corresponda, um rebalanceamento acontecerá quase imediatamente e os consumidores começarão a consumir a partir do novo tópico. Isso é útil para aplicativos que precisam consumir vários tópicos e podem lidar com os diferentes tipos de dados que os tópicos irão conter. A assinatura de vários tópicos usando uma expressão regular é mais comumente usada em aplicativos que replicam dados entre o Kafka e outro sistema.

Para se inscrever em todos os tópicos de teste, podemos ligar para:

consumer.subscribe (Pattern.compile ("test. *"));

The Poll Loop
No centro da API do consumidor está um loop simples para pesquisar o servidor em busca de mais dados. Depois que o consumidor assina os tópicos, o loop de pesquisa lida com todos os detalhes de coordenação, rebalanceamentos de partição, pulsações e busca de dados, deixando o desenvolvedor com uma API limpa que simplesmente retorna os dados disponíveis das partições atribuídas. O corpo principal de um consumidor será o seguinte:

```
try { 
    while (true) { 1
        ConsumerRecords <String, String> records = consumer.poll (100); 2
        for (ConsumerRecord <String, String> registro: registros) 3
        { 
            log.debug ("topic =% s, partition =% d, offset =% d," 
                customer =% s, country =% s \ n ", 
                record.topic (), record.partition (), record.offset (), 
                record.key (), record.value ()); 

            int updatedCount = 1; 
            if (custCountryMap.countainsKey (record.value ())) { 
                updatedCount = custCountryMap .get (record.value ()) + 1; 
            } 
            custCountryMap.put (record.value (), updatedCount)

            JSONObject json = novo JSONObject (custCountryMap); 
            System.out.println (json.toString (4)) 4
        } 
    } 
} finalmente { 
    consumer.close (); 5
}
```

















  




