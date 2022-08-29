# Monitoring & Observability
Monitoramento é a ação de observar e verificar o comportamento e as saídas de um sistema e seus componentes ao longo do tempo. O monitoramento não resolve nada. Você precisa consertar as coisas depois que elas quebram.

images/obs01.png

# Overview
*Monitoring != Logging != Tracing != Instrumentation*

## Logging
- Proposta - representa a transformação de estado ou eventos dentro de um aplicativo. Quando as coisas dão errado, os logs são úteis para identificar qual evento causou o erro.

* Pros e Cons - Obter, transferir, armazenar e analisar logs é caro. Registre apenas informações importantes e acionáveis.

* Tools e Frameworks - dependendo do ambiente technologico. e.g, logback, log4j, etc. Splunk

## Tracing
- Proposta - representa a jornada de um único usuário por uma pilha inteira de um aplicativo. Frequentemente usado para fins de otimização.
* Pros e Con 
- As bibliotecas de tracing geralmente são mais complicadas do que o código que estão servindo. 
- Então o rastreamento tende a ser caro.
* Tools e Frameworks - OpenTracing 

## Monitoring
- Proposta - Instrumentar uma aplicação e monitorar os resultados representa o uso de um sistema. Muitas vezes usado para fins de diagnóstico. 
  Monitore aplicativos para detectar problemas e anomalias. 
  Testes básicos de condicionamento físico, como o aplicativo está ativo ou inativo, e health checks proativos. 
  Forneça insights sobre os requisitos de capacidade.

* Pros e Con 
- A instrumentação geralmente é barata. 
- As métricas levam nanossegundos para serem atualizadas e alguns sistemas de monitoramento operam em um modelo “pull”, o que significa que o serviço não é afetado pela carga de monitoramento.

* Tools e Fremeworks - Prometheus, DynaTrace, Wily

__________________________________
## Monitoring

https://vimeo.com/monitorama/videos

Ex

Nome da metrica - k-list
Valores das metricas
counters, gauges, percentiles, nominal, ordinal, interval, ratio, derived

Como podemos monitorar?
Resolução - com que frequência coletar as métricas? a cada 6-10 segundos?
Latência - quanto tempo antes de agirmos sobre eles?
Diversidade - estamos coletando métricas diferentes?
O que é o registro de gravação antecipada? Usado no HBase.

Qualquer sistema de monitoramento deve responder a 2 perguntas principais:
O que está quebrado?
e porque?

# Tipos
#### Black-box monitoring
Testar o comportamento visível externamente como um usuário o veria.
É orientado para os sintomas e representa problemas ativos - não previstos. por exemplo, "O sistema não está funcionando agora".
Útil para paginação. Tem o principal benefício de alertar as pessoas com problemas reais e apenas quando um problema que está em andamento e contribui para sintomas reais.

#### White-box monitoring
Monitoramento baseado em métricas expostas pelos sistemas internos, incluindo logs, interfaces como a interface de criação de perfil JVM ou um manipulador HTTP que emite estatísticas internas. por exemplo. /health padrão de Endpoinsts.
Depende da capacidade de inspecionar profundamente os sistema, como logs ou endpoints HTTP, com instrumentação.
Ele permite a detecção de problemas iminentes, falhas mascaradas e assim por diante.
A telemetria do monitoramento White-box é essencial para a debug. por exemplo, se as solicitações da web estiverem lentas, você precisa saber se a lentidão é causada por um problema de rede ou lentidão no banco de dados.

# Por que Monitorar?

#### Análise de tendências de longo prazo
Qual é o tamanho do meu banco de dados e quão rápido ele está crescendo? Com que rapidez minha contagem de usuários ativos diários está crescendo?
#### Comparação ao longo do tempo ou grupos de experiência
As consultas são mais rápidas com Acme Bucket of Bytes 2.72 versus Ajax DB 3.14? 
Quão melhor é minha taxa de acertos do memcache com um nó extra? 
Meu site está mais lento do que na semana passada?

#### Alertas
Criação de Dashboards
Realização de análise retrospectiva ad hoc (ou seja, debug)
Nossa latência aumentou; o que mais aconteceu no mesmo periodo?

# 4 Golden Signals
Os 4 Golden Signals do monitoramento são: S.E.L.T. (saturação, erro, latência, tráfego)

#### Latência
#### Quanto tempo que levo para atender uma solicitação.
É importante distinguir entre a latência de solicitações bem-sucedidas e a latência de solicitações com falha.
Por exemplo, um erro HTTP 500 gerado devido à perda de conexão com um banco de dados ou algum serviço de back-end crítico não respondeu no tempo esperado; no entanto, como um erro HTTP 500 indica uma solicitação com falha, fatorar 500s em sua latência geral pode resultar em cálculos enganosos. Por outro lado, um erro lento é ainda pior do que um erro rápido!

#### Tráfego
Uma metrica de quanta demanda está sendo colocada em seu sistema, medida em uma métrica específica do sistema de alto nível.
Para um serviço da Web, essa medida geralmente é de solicitações HTTP por segundo, talvez divididas pela natureza das solicitações (por exemplo, conteúdo estático versus conteúdo dinâmico).
Para um sistema de streaming de áudio, essa medida pode se concentrar na taxa de E/S da rede ou em sessões simultâneas.
Para um sistema de armazenamento de valor-chave, essa medida pode ser de transações e recuperações por segundo.

#### Erros
A taxa de solicitações que falham,
explicitamente (por exemplo, HTTP 500s),
implicitamente (por exemplo, uma resposta de sucesso HTTP 200, mas associada ao conteúdo errado),
ou por política (por exemplo, “Se você se comprometeu com tempos de resposta de um segundo, qualquer solicitação acima de um segundo é um erro”).
Onde os códigos de resposta do protocolo são insuficientes para expressar todas as condições de falha, protocolos secundários (internos) podem ser necessários para rastrear os modos de falha parcial.
O monitoramento desses casos pode ser drasticamente diferente: capturar HTTP 500s em seu balanceador de carga pode fazer um trabalho decente ao capturar todas as solicitações com falha completa, enquanto apenas testes de sistema de ponta a ponta podem detectar que você está servindo o conteúdo errado.

#### Saturação
O quanto o meu serviço esta sendo utilizado.
Uma medida da fração do seu sistema, enfatizando os recursos que são mais restritos (por exemplo, em um sistema com restrição de memória, mostre a memória; em um sistema com restrição de E/S, mostre E/S).
Observe que muitos sistemas perdem o desempenho antes de atingirem 100% de utilização, portanto, é essencial ter uma meta de utilização.
Os aumentos de latência costumam ser um indicador importante de saturação.
A saturação também está preocupada com predicações de saturação iminente, como “parece que seu banco de dados encherá seu disco rígido em 4 horas”

# Anti-patterns

#### Obsessão por Ferramentas
não existe a ferramenta de painel único que, de repente, fornecerá visibilidade perfeita de sua rede, servidores e aplicativos, tudo com pouco ou nenhum ajuste ou investimento de equipe. Muitos fornecedores de software de monitoramento vendem essa ideia, mas é um mito.
O monitoramento não é um problema único, portanto, é lógico que também não pode ser resolvido com uma única ferramenta.
O monitoramento sem agente é extraordinariamente inflexível e nunca lhe dará a quantidade de controle e visibilidade que você deseja.
Quantas ferramentas são demais? - Se houver 3 ferramentas para monitorar seu banco de dados e todas elas fornecerem as mesmas informações, você deve considerar a consolidação. Por outro lado, se todos os três fornecerem informações diferentes, você provavelmente está bem.
Evite ferramentas de culto à carga - Adotar ferramentas e procedimentos de equipes e empresas mais bem-sucedidas, da uma noção equivocada de que as ferramentas e os procedimentos são e o que tornaram essas equipes bem-sucedidas, então também farão com que sua própria equipe tenha sucesso da mesma forma. Infelizmente, a causa e o efeito são inversos: o sucesso que a equipe experimentou os levou a criar as ferramentas e os procedimentos, e não o contrário.

#### Monitoramento como um trabalho
Esforce-se para tornar o monitoramento um cidadão de primeira classe quando se trata de construir e gerenciar serviços. Lembre-se, ele não está pronto para produção até que seja monitorado.
A equipe de observabilidade é a equipe cujo trabalho é construir ferramentas de monitoramento de autoatendimento como um serviço para outra equipe. No entanto, essa equipe não é responsável por instrumentar os aplicativos, criar alertas etc. O antipadrão é alertar para que sua empresa não se esquive da responsabilidade de monitorar, deixando-o apenas nos ombros de uma única pessoa.

#### Checkbox Monitoring
Esse antipadrão é quando você tem sistemas de monitoramento apenas para dizer que os tem. Isso é ineficaz, barulhento, não confiável e provavelmente pior do que não ter monitoramento algum.

#### Sinais comuns desse antipadrão
métricas de gravação como uso de CPU, carga do sistema e utilização de memória, mas o serviço ainda fica inativo.
Você está constantemente ignorando os alertas, pois eles são alarmes falsos na maioria das vezes.
verificando os sistemas de métricas a cada 5 minutos.
não armazenar dados de métricas históricas.

#### Consertar
As métricas do SO não são muito úteis para alertar. Se o uso da CPU estiver acima de 90%, isso não é motivo para alertar, se o servidor ainda estiver fazendo o que deveria fazer.
Colete suas métricas com mais frequência e procure padrões.

#### Alertas como muleta
Evite a tendência de aprender no monitoramento como uma muleta. O monitoramento é ótimo para alertar problemas, mas não se esqueça do próximo passo: corrigir os problemas.

## Padrões de design
1. Monitoramento Componível : Use várias ferramentas especializadas e acople-as livremente, formando uma plataforma de monitoramento . Semelhante à filosofia UNIX, escreva um programa que faça uma coisa e faça bem. Escreva programas para trabalharem juntos.

2. Monitorar da perspectiva do usuário : Uma das coisas mais eficazes para monitorar são simplesmente os códigos de resposta HTTP (especialmente da variedade HTTP 5xx) seguidos pelos tempos de solicitação (também conhecidos como latência). Sempre pergunte a si mesmo: “Como essas métricas me mostrarão o impacto do usuário?” .

Ao medir o desempenho de sua solicitação, não calcule apenas o tempo médio de resposta. Agrupe-os por latências: quantas solicitações levaram entre 0 ms e 10 ms, entre 10 ms e 30 ms, , entre 30 ms e 100 ms e assim por diante . Plotar isso em um histograma geralmente é uma maneira fácil de visualizar a distribuição de suas solicitações.

# Dados de telemetria
MELT (Métricas, Eventos, Logs e Traces)
MELT são os tipos de dados essenciais de observabilidade.

#### Eventos
Um evento é uma ação discreta que acontece em um momento no tempo. Os eventos são apenas sobre “algo aconteceu em algum momento”.
Exemplo: Às 15h34 do dia 21/02/2019 foi comprado um saco de batatas fritas para churrasco por 1 dólar.
Não existe uma regra rígida sobre quais dados um evento pode conter — você define um evento como achar melhor. Os eventos se tornam mais poderosos quando você adiciona mais metadados a eles. por exemplo, tipo de evento, ItemCategory e PaymentType, etc.
Como os eventos são basicamente um histórico de cada coisa individual que aconteceu em seu sistema, você pode agrupá-los em agregados para responder a perguntas mais avançadas em tempo real.

*Prós*
Incluir pontos de dados individuais permitem que você faça as perguntas que quiser a qualquer momento.
pode ser calculado em tempo real.

*Contras*
Cada evento requer uma certa quantidade de energia computacional para coletar e processar. Eles também ocupam espaço em seu banco de dados – potencialmente muito espaço. Por exemplo, você pode armazenar um evento para cada mudança minúscula de subgraus na temperatura, o que encheria rapidamente até os maiores bancos de dados. Ou você pode tirar uma amostra da temperatura em intervalos regulares. Esse tipo de dado é melhor armazenado como uma métrica .
Caro para armazenar grandes volumes de dados de eventos.
Pode atingir restrições de largura de banda no sistema de origem ao coletar e enviar os dados do evento.
Pode ser demorado para consultar

#### Métricas
As métricas são um conjunto agregado de medidas agrupadas ou coletadas em intervalos regulares.
Ao contrário dos eventos, as métricas não são discretas — elas representam agregados de dados em um determinado período de tempo.
Os tipos de agregação de métricas são diversos (por exemplo, média, total, mínimo, máximo, soma dos quadrados), mas todas as métricas geralmente compartilham as seguintes características:
Um carimbo de data/hora (observe que este carimbo de data/hora representa um período de tempo, não um horário específico)
Um nome
Um ou mais valores numéricos representando algum valor agregado específico
Uma contagem de quantos eventos são representados no agregado
Exemplo: para o minuto das 15h34 às 15h35 de 21/02/2022, houve um total de três compras, totalizando US$ 2,75.
Observe que perdemos alguns dados aqui comparados a um evento. Não sabemos mais quais foram as três compras específicas, nem temos acesso aos seus valores individuais (e esses dados não podem ser recuperados). No entanto, esses dados exigem muito menos armazenamento, mas ainda nos permitem fazer algumas perguntas críticas, como: "Quais foram minhas vendas totais durante um determinado minuto?"
Métricas de exemplo: error rate, response time, throughput, etc.
As métricas vêm em diferentes representações
O count é uma métrica cada vez maior. por exemplo, hodômetro em um carro, número de visitas a um site.
O Gauge é um valor pontual. por exemplo, Velocímetro no carro.
A natureza do Counter tem uma grande falha: ele não diz nada sobre valores anteriores e não fornece nenhum indício de valores futuros. 
Armazenar Gauges em um TSDB pode fazer coisas como plotar em um gráfico, prever tendências futuras, etc.

*Prós*
Armazene significativamente menos dados
Menos tempo para computar roll-ups

*Contras*
Necessário para tomar decisões com antecedência sobre as quais você deseja analisar os dados

#### Logs
Os logs são essencialmente strings de texto com um carimbo de data/hora associado a eles.
Assim como os eventos, os dados de log são discretos
Logs vêm em 2 tipos
- Registros não estruturados
- Logs estruturados : o exemplo mais comum é o formato JSON.
Um evento pode produzir vários logs. Por exemplo, um evento de compra do cliente em uma máquina de venda automática pode ter várias mensagens de log, como moeda inserida, botões pressionados, dispensados, etc.

#### Traces
Traces – ou mais precisamente, “rastros distribuídos” – são amostras de cadeias causais de eventos (ou transações) entre diferentes componentes em um ecossistema de microsserviços. 
E como eventos e logs, os traces são discretos e irregulares na ocorrência.
Traces costurados formam eventos especiais chamados “spans” ; spans ajudam você a rastrear uma cadeia causal por meio de um ecossistema de microsserviços para uma única transação. Para fazer isso, cada serviço passa identificadores de correlação, conhecidos como “contexto de rastreamento”, entre si; esse contexto de rastreamento é usado para adicionar atributos no intervalo.

# Componentes
https://www.usenix.org/sites/default/files/conference/protected-files/dickson.pdf

Um serviço de monitoramento tem 5 facetas principais !

#### Coleta de dados
Baseado em pull
SNMP, Nagios.
Uso do padrão de endpoint /health no monitoramento de aplicativos que expõe métricas e informações de integridade sobre um aplicativo que podem ser pesquisadas por um serviço de monitoramento, ferramenta de descoberta de serviço como Consul e etcd ou por um balanceador de carga.
O modelo pull pode ser difícil de dimensionar, pois exige que os sistemas centrais acompanhem todos os clientes conhecidos, lidem com o agendamento e analisem os dados de retorno.

Baseado em push
O modelo push é mais fácil de dimensionar em uma arquitetura distribuída, como a nuvem, devido à falta de um poller central. Os nós que enviam dados precisam saber apenas para onde enviá-los e não precisam se preocupar com a implementação subjacente do lado receptor.
vários sistemas coletam dados em várias velocidades.
vários sistemas têm vários conceitos de uma unidade de identidade métrica sem interface consistente por exemplo, top, np, netstats, sar, nagios.

#### Armazenamento de dados
Armazenamento de métricas
Métricas, sendo séries temporais, normalmente armazenadas em um Banco de Dados de Séries Temporais (TSDB). por exemplo, Round Robin Database (RRD), Graphite's Whisper, OpenTSDB.
Muitos TSDBs acumulam ou envelhecem os dados após um determinado período de tempo. Isso significa que, à medida que os dados envelhecem, vários pontos de dados são resumidos em um único ponto de dados. Um método comum de roll-up é a média, embora algumas ferramentas suportem outros métodos, como somar pontos de dados.
O rollup de métrica ocorre como resultado de compromissos: armazenar a resolução nativa de métricas fica muito caro para os discos - tanto no armazenamento quanto no tempo necessário para ler todos esses pontos de dados do disco para uso em um gráfico.
Armazenamento de registros 
Armazene os dados de log como arquivos simples. por exemplo, rsyslog
Armazene os arquivos de log em um mecanismo de pesquisa. por exemplo, ElasticSearch
O armazenamento métrico é barato. O armazenamento de log pode ficar caro.

#### Visualização
O Visual Display of Quantitive Information de Edward Tufte e o Information Dashboard Design de Stephen Few.

Um princípio por trás de um ótimo monitoramento é que você deve construir as coisas de uma maneira que funcione melhor para o seu ambiente.
A visualização comum para dados de séries temporais é o gráfico de linhas (também chamado de strip data).
A visualização deve ter itens acionáveis. Evite gráficos de pizza para métricas de uso de disco. Pense em gráficos visuais que podem prever o tamanho do disco após 6 meses.
[Flame Graph](https://www.brendangregg.com/flamegraphs.html)
[State Map](https://github.com/TritonDataCenter/statemap)

# Análise e relatórios
1. SLA 
2. SLO 
3. SLI

O SLA, SLO e SLI são baseados na suposição de que o serviço não estará disponível 100%

#### SLA (Acordo de Nível de Serviço) é um contrato que o provedor de serviços promete aos clientes sobre a disponibilidade do serviço, desempenho, etc.
SLAs são para acordos externos.
SLA é simplesmente um SLO que 2 ou mais partes “concordaram”.
Os SLAs fazem sentido apenas quando considerados em prazos fixos, que são chamados de “janelas de garantia”.
#### SLO (Objetivo de Nível de Serviço) é uma meta que o provedor de serviços deseja alcançar.
Os SLOs geralmente são usados ​​apenas para acordos internos.
Se a disponibilidade de um serviço violar o SLO, as operações precisam reagir rapidamente para evitar a quebra do SLA, o que custaria dinheiro ao provedor de serviços.
SLOs são regras de alerta

#### SLI (Indicador de Nível de Serviço) é uma medida que o provedor de serviços usa para a meta.
SLIs são as métricas no sistema de monitoramento.
A maioria das pessoas realmente quer dizer SLO quando dizem “SLA”. Um brinde: se alguém fala sobre uma “violação de SLA”, quase sempre está falando sobre um SLO perdido. Uma violação real do SLA pode desencadear um processo judicial por quebra de contrato.

#### Relação
O provedor de serviços precisa coletar métricas com base no SLI, definir limites de métricas com base no SLO e monitore os limites das métricas para que não quebre o SLA.
Você não pode atender ou superar as expectativas se ninguém concordar com quais são as expectativas.

#### Disponibilidade
A disponibilidade de um aplicativo/serviço é comumente referida pelo número de noves. 99,99% são quatro noves.
Disponibilidade = tempo de atividade / (tempo de inatividade + tempo de atividade)
As formas mais comuns de medir a disponibilidade são a marcação de quanta de tempo ou a contagem de falhas.
Por que a alta disponibilidade é difícil?
De acordo com o teorema de amostragem de Nyquist-Shannon, para medir uma interrupção de 2 minutos, você deve coletar dados em intervalos de um minuto. Assim, para medir a disponibilidade em até 1 segundo, você deve coletar dados em intervalos de menos de um segundo. Essa é apenas uma das razões pelas quais é tão difícil obter relatórios de SLA precisos com mais de 99%.
Um ponto frequentemente negligenciado sobre disponibilidade é quando seu aplicativo tem componentes dependentes: seu serviço pode estar tão disponível quanto os componentes subjacentes nos quais ele foi criado. por exemplo, AWS S3 fornece SLA de 99,95%. Um aplicativo que depende do S3 nunca pode ser >99,95% SLA.
Da mesma forma, se a rede subjacente não for confiável, os servidores e os aplicativos mais altos na pilha não poderão ser mais confiáveis ​​do que a rede.
Cada nove adicional de disponibilidade tem um custo significativamente maior associado a ele, e o investimento geralmente não vale a pena: muitos clientes não conseguem dizer a diferença entre 99% e 99,9%.

#### Alerta
O monitoramento não existe para gerar alertas: os alertas são apenas um resultado possível. Com isso em mente, lembre-se de que cada métrica coletada e gráfico não precisa ter um alerta correspondente.
Um alerta deve evocar um senso de urgência e exigir ação da pessoa que recebe esse alerta. Todo o resto pode ser essencialmente uma entrada de log, uma mensagem colocada em sua sala de bate-papo interna ou um ticket gerado automaticamente.

##### 3 categorias de alerta
1. Resposta/ação necessária imediatamente - envie para SMS, PagerDuty
2. Conscientização necessária, mas não é necessária ação imediata - envie-as para salas de bate-papo internas
3. Registre para fins de histórico/diagnóstico - envie-o para o arquivo de log e analise mais tarde

# práticas recomendadas de alerta

1. Pare de usar e-mail para alertas
2. Escreva runbooks - Um runbook é para quando o julgamento e o diagnóstico humanos são necessários para resolver algo.
3. Limites estáticos arbitrários não são a única maneira
4. Alertar sobre coisas como “datapoint cruzou X” não é útil. Um limite estático definido para alertar em “espaço livre abaixo de 10%” não alertará quando um disco aumentar rapidamente em uso de 11% para 80% durante a noite.
5. O uso de uma alteração percentual/derivado resolveria nosso problema de uso do disco, informando que “o uso do disco cresceu 50% da noite para o dia”
6. Poucas dessas abordagens: médias móveis, bandas de confiança, desvio padrão.
7. Excluir e ajustar alertas.
8. A "Alert Fadigue" ocorre quando você está tão exposto a alertas que fica insensível a eles. Alertas devem causar uma pequena descarga de adrenalina.
9. Use "períodos de manutençãos" se você precisar trabalhar em um serviço ou aplicativo e espera que ele acione um alerta (por exemplo, por estar inativo), defina esse alerta no período de manutenção.
10. Tente se autocurar primeiro

# plantões

#### Estratégias eficazes para plantão

1. Trabalhe na resiliência e estabilidade dos sistemas durante o turno de plantão quando não estiverem combatendo incêndios.
2. Com base nas informações coletadas na semana de plantão anterior, planeje a estabilidade e a resiliência dos sistemas durante o planejamento da sprint/reunião da equipe da semana seguinte.
3. Inicie a rotação de plantão durante a semana de trabalho em vez da semana do calendário. Isso permite que a equipe faça uma transferência de plantão.
4. Rotações Follow-The-Sun (FTS) permitem ter cobertura total de plantão sem ninguém ficar de plantão durante a noite. Uma grande desvantagem das rotações do FTS é o aumento significativo na sobrecarga de comunicação.
5. Somente quando você tiver uma equipe grande, tenha uma pessoa de plantão de reserva para a pessoa de plantão principal. Para equipes menores, isso significa que a mesma pessoa está de plantão a cada 2-3 semanas.
6. Quantas pessoas você precisa para um cronograma de rodízio de plantão eficaz? Depende de 2 fatores: quão ocupado seu plantão tende a ser e quanto tempo você quer dar às pessoas entre os turnos de plantão.
7. Os engenheiros de software devem estar de plantão. Evite a versão “jogar por cima da parede” da engenharia de software. Se os engenheiros de software estão cientes das dificuldades que surgem durante o plantão, eles são incentivados a criar um software melhor.

# Monitoramento em vários níveis
#### Monitoramento de negócios
TBD

#### Monitoração do Frontend
##### 2 abordagens para monitoramento de front-end

. RUM (monitoramento de uso real) 
    . usa o tráfego real do usuário para os dados de monitoramento.
    . Ex Google Analytics.

. Monitoramento sintético
    . criar solicitações falsas sob uma variedade de condições de teste para gerar os dados.
    . por exemplo, WebpageTest.org, scripts Dynatrace Gomez

. DOM (modelo de objeto de documento)
    . Carregamento síncrono: por padrão, os scripts em uma página da Web são carregados de forma síncrona. ou seja, se a análise do DOM encontrar uma tag <script>, o navegador parará de analisar o DOM e carregará o script.
    . Carregamento assíncrono: HTML5 suporta atributo assíncrono nas tags <script> que permite que os scripts sejam baixados em segundo plano enquanto o DOM continua sendo carregado, executando o script quando o download terminar. Isso melhora muito o desempenho da página.
. Métricas de desempenho
    . API de tempo de navegação
        . Os navegadores expõem as métricas de desempenho da página por meio da API Navigation Timing.
        . Esta API expõe 21 métricas. Consistentemente úteis entre eles são navigationStart, domLoading, domInteractive, domContentLoaded, domComplete
    . API de tempo do usuário
        . Enquanto as métricas da API Navigation Timing são definidas pelo navegador, a API User Timing permite que você crie suas métricas e eventos.
###### Ferramentas
. WebPageTest.org
. SpeedIndex
    . calcula a integridade percebida pelo usuário
    . Enquanto as métricas de tempo de navegação dependem de relatórios precisos do navegador, o SpeedIndex usa captura de vídeo a uma taxa de 10 quadros por segundo para determinar exatamente quando uma página é carregada do ponto de vista visual.
    . O algoritmo do SpeedIndex produz um único número como saída - quanto menor, melhor.

# Monitoramento de aplicativos
#### StatsD
ferramenta criada pela Etsy em 2011 para adicionar métricas dentro do seu código - originalmente projetada para um back-end Graphite
Um daemon de rede que é executado na plataforma Node.js e escuta estatísticas, como contadores e temporizadores, enviados por UDP ou TCP e envia agregações para um ou mais serviços de back-end conectáveis ​​(por exemplo, Graphite, OpenTSDB, InfluxDB)

#### Monitorar pipeline de CI/CD
capturar métricas como hora de início da implantação, hora de término etc.
As métricas de implantação junto com as métricas de desempenho do aplicativo, podem ajudar a identificar problemas causados ​​por uma implantação específica.
#### Health Endpoint Pattern
/health endpoint padrão ou endpoint canary ou endpoint de status é um endpoint HTTP para fornecer métricas básicas de integridade sobre o aplicativo - por exemplo, versão do aplicativo, configuração usada, status das dependências etc.

*Benefícios*
pode ser usado como verificação de integridade para um balanceador de carga ou para ferramentas de descoberta de serviço
útil para depuração: expor informações de compilação ajuda a determinar facilmente o que está sendo executado no ambiente

*Desvantagens*
envolve muito mais trabalho de engenharia para implementar do que uma simples abordagem de métricas baseadas em push
precisa de ferramentas para verificar consistentemente o endpoint

#### Monitoramento de serveless Apps
Em construção

# Monitoramento do servidor
. Uso da CPU: métricas /proc/stat via comando top
. Uso de memória: métricas /proc/meminfo via comando free -m
    . também monitore a geração do OOMKiller nos logs
. Uso da rede: métricas /proc/net/dev via ifconfig, ip (do pacote iproute2)
. Uso do disco: métricas /proc/diskstats via iostat -x (do pacote sysstat)
    . iowait representa a quantidade de tempo que a CPU ficou ociosa devido à espera no disco para concluir as operações.
    . iostat sem -x retorna tps (transferências por segundo) ou IOPS (E/S por segundo). Notar uma queda repentina no IOPS pode indicar um problema de desempenho do disco.
. Load: /proc/loadavg métricas por meio do comando uptime.
    . Load é uma medida de quantos processos estão esperando para serem atendidos pelo CPI. É representado por 3 números: uma média de 1 m, uma média de 5 m, uma média de 15 m [artigo top](https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html)
. Certificados SSL
    . Para monitoramento de sites externos, use ferramentas como Pingdom, StatusCake, etc.
    . Para monitoramento interno do site, crie scripts de shell personalizados.
. Web Servers
    . Solicitações por segundo (req/sec): Métrica de ouro para avaliar o desempenho ou a taxa de transferência do servidor web.
    . conexões abertas ou keepalives
    . conexões não são solicitações. Antes do uso de keepalives, cada solicitação exigia sua própria conexão. Como uma página da Web pode ter vários objetos para solicitar o carregamento da página, isso levou a muitas conexões.
    . Abrir uma conexão requer passar pelo handshake TCP completo, configurar uma conexão, mover dados e desfazer a conexão - dezenas de vezes para uma única página.
    . Assim, os keepalives HTTP nasceram: o servidor web mantém aberta a conexão para um cliente em vez de derrubá-la, para reutilizar a conexão para o cliente, o que permite que muitas solicitações sejam feitas em uma única conexão. Claro, a conexão não pode ser mantida    aberta para sempre, então os keepalives são governados por um tempo limite no lado do servidor web.
    Há também uma configuração keepalive no lado do navegador chamada conexão persistente com seus próprios valores de tempo limite. Todos os navegadores modernos usam conexões persistentes por padrão.
. request time

# Servidores de banco de dados
    . conexões abertas
    . consultas por segundo
    . IOPS
#### Cache
    . de itens despejados: despejos altos são um bom sinal de que um cache é muito pequeno, fazendo com que muitos itens sejam despejados para dar espaço para novos itens.
    . Proporção de acertos/erros ou proporção de acertos de cache

# servidor NTP
ntpstat

# Monitoramento de rede
A definir

# Monitoramento de segurança
. HIDS (Sistema de Detecção de Intrusão de Host)
    . detecta bad actors ou rootkits em um host específico
    . Os rootkits podem ser qualquer coisa, desde webshells instalados em massa até binários recompilados furtivos e tudo mais.
    . Devido à sua natureza furtiva, os rootkits podem ser bastante difíceis de detectar.
    . Ferramentas: rkhunter, [OSSEC](https://www.ossec.net/).
. NIDS (Sistema de Detecção de Intrusão de Rede)
    . detecta ameaças na própria rede.
    . funciona ouvindo o tráfego bruto no fio usando um ou mais taps de rede colocados em toda a rede.
    . Um toque de rede é uma peça de hardware que fica em linha em sua rede, interceptando todo o tráfego que passa por ela e encaminhando uma cópia para outro sistema.
    . O tráfego de tap das redes é enviado para análise em uma ferramenta chamada gerenciamento de informações e eventos de segurança (SIEM). por exemplo, [Zeek](https://zeek.org/), [Snort](https://www.snort.org/).

# Ferramentas
AppDynamics
Cacti (mrtg++) - Solução de Network Graphing projetada para aproveitar o poder da funcionalidade de armazenamento e gráfico do RRDTool
[Cônsul](https://www.consul.io/)
ElasticSearch
etcd
FluentD - uma ferramenta de código aberto para coletar eventos e logs e armazenar como JSON - construído em CRuby - plugins permite armazenar os dados massivos para Log Search (como ElasticSearch), Analytics e Archiving (MongoDB, S3, Hadoop)
[Ganglia](http://ganglia.info/) - uma ferramenta de monitoramento de sistema distribuído escalável para sistemas de computação de alto desempenho, como clusters e grades. - normalmente usado com Nagios.
Grafana - ferramenta de visualização
[Grafite](http://graphiteapp.org/)
    . esta ferramenta de código aberto escrita em Python faz 2 coisas: armazena dados numéricos de séries temporais e renderiza gráficos desses dados sob demanda
    . não coleta dados.
    . 3 componentes
        . carbono - um daemon Twisted que escuta dados de séries temporais
        . whisper - uma biblioteca de banco de dados simples para armazenar dados de séries temporais
        . graphite-webapp - Um webapp Django que renderiza gráficos sob demanda usando Cairo.
GrayLog2 - um sistema de análise de dados de código aberto - pesquise logs, crie gráficos, crie alertas - aproveita Java e ElasticSearch. Comunicação via API REST
LogStash - Redis para armazenamento - RabbitMQ, grok - Implementação típica: logstash + redis + elasticsearch
InfluxDB
Jaeger - sistema de rastreamento distribuído de código aberto
Kibana - interface web para visualizar registros de logstash armazenados no elasticsearch
Librato - Ferramenta comercial
Loggly - ferramenta comercial
MRTG - sigla para Multi Router Traffic Grapher - software gratuito para monitorar e medir a carga de tráfego em links de rede. - obtém seus dados por meio de agentes SNMP a cada poucos minutos - os resultados são plotados em gráficos - possui mecanismo de alerta
Nagios
NewRelic
OpenTSDB - solução de armazenamento puro - um banco de dados de séries temporais distribuído gratuitamente escrito em cima do HBase - foi escrito para armazenar, indexar e servir métricas coletadas em grande escala e torná-lo facilmente acessível e gráfico.
Pingdom - ferramenta comercial
Prometeu
RRDTool - acrônimo para Round-Robin Database Tool - visa lidar com dados de séries temporais como largura de banda n/w, carga da CPU, etc. hora extra. - Possui ferramentas para exibir os dados em formato gráfico.
sar
Sensu - estrutura de monitoramento de código aberto
Shinken
open-source Nagios como ferramenta, redesenhado e reescrito do zero.
Nagios + Grafite + Configuração
Smashing - ferramenta de visualização
Splunk
Estatísticas
ouve tudo e qualquer coisa
escrito em node.js. Existem implementações alternativas em groovy, C, etc.
ouve estatísticas (contadores e temporizadores) e envia agregações para serviços de back-end como Graphite
vestígio
Zenoss
Zipkin
Embarcadores
lenhador
Castor
syslog
marmota
Outras ferramentas
mongusto
coletado
jmxtrans
tasseo
gdash
libra

# Splunk
é um indexador de séries temporais - um produto que cuida muito bem dos três Vs.
3 funcionalidades principais!!
1. Coleção de dados 
    1.1 da fonte estática
    1.2 da fonte em tempo real
    1.3 de arquivos de log, arquivos de log rolantes
    1.4 de bancos de dados
2. dos resultados do script
Indexação de dados - índice dos dados acima
3. Pesquisa e Análise - Usando Splunk Processing Language para pesquisar e extrair resultados na forma de gráficos, eventos, etc.
O Splunk divide as entradas do arquivo de log em diferentes eventos com base no timestamp associado. Se nenhum registro de data e hora for encontrado, todas as linhas no arquivo de log serão consideradas como um único evento.

#### Components
* Search Head
* Forwarders

#### Queries
* Principais navegadores: sourcetype="access_combined_wcookie" | top user agent
* 3 navegadores inferiores: sourcetype=access_combined_wcookie | limite de usuário raro = 3
* 5 principais endereços IP: sourcetype="access_combined_wcookie" | limite de cliente superior = 5
* Principais referências sem campo de porcentagem: sourcetype=access_combined_wcookie referer != *MyGizmo* | referência superior | campos - porcentagem
* Contagem de 404 erros agrupados por origem: sourcetype=access_combined_wcookie status=404 | contagem de estatísticas por fonte
* Principais compras por produto: sourcetype=access* | timechart count(eval(action="purchase")) por productId usenull=f
* Visualizações e compras de páginas: sourcetype=access_* | timechart per_hour(eval(method="GET")) AS Views, per_hour(eval(action="purchase")) AS Compras
* Geolocalização de IPs (Google Maps): sourcetype=access* | cliente de geoip

#### Analytics
também conhecido como Business Intelligence / Data Mining / OLAP
As análises tradicionais são baseadas em 'Early Structure Binding', onde você precisa saber de antemão quais perguntas serão feitas sobre os dados.
As etapas típicas de desenvolvimento podem ser resumidas da seguinte forma:
* Decida quais perguntas fazer
* Projete o esquema de dados
* Normalize os dados
* Escreva o código de inserção do banco de dados
* Crie as consultas
* Alimente os resultados em uma ferramenta de análise
* Late Structure Binding, que tem estes passos simples:
* Gravar dados (ou eventos) em arquivos de log
* Colete os arquivos de log
* Crie pesquisas, gráficos e relatórios usando o Splunk
A Inteligência Operacional refere-se às informações coletadas e processadas
Log semântico como dados ou eventos que são gravados em arquivos de log explicitamente com a finalidade de coletar análises.

#### Logging
[Log estruturado](https://stackify.com/what-is-structured-logging-and-why-developers-need-it/)

* slf4j

* [Estruturas de meta log](http://www.slf4j.org)

* [NDC, declarações MDC](http://stackoverflow.com/questions/7404435/conditional-logging-with-log4j?)


Quais são os problemas do carregador de classe que afligem o JCL?

O que significa 'abordagem de ligação estática' em sl4j?

Objetos marcadores NOPlogger?

#### Tracing
O Distributed Tracing é uma metodologia e uma cadeia de ferramentas para monitorar as interações complexas inerentes a uma arquitetura de microsserviços.
por exemplo. Google Dapper, Zipkin
Como funciona?
para cada solicitação que ocorrer, “marque-a” com um ID de solicitação exclusivo.
esse ID de solicitação permanece com a solicitação e as solicitações resultantes ao longo de sua vida, permitindo ver em quais serviços uma solicitação toca e quanto tempo é gasto em cada serviço.
O rastreamento está mais preocupado com solicitações individuais do que com métricas agregadas

* OpenTracing
OpenTracing é uma especificação neutra de fornecedor para APIs de instrumentação.
Ele oferece APIs consistentes, expressivas e neutras de fornecedor para plataformas populares, tornando mais fácil para os desenvolvedores adicionar (ou alternar) implementações de rastreamento com uma alteração de configuração O(1).
O OpenTracing também oferece uma língua franca para instrumentação OSS e bibliotecas auxiliares de rastreamento específicas da plataforma.
* Tutoriais
CNCF Jaeger, uma plataforma de UI de rastreamento distribuído


# References
#### Livros
* Mastering Distributed Tracing
* Distributed Systems Observability - Cindy Sridharan
* Logging and Log Management - Anton Chuvakin, Kevin Schmidt
* O’Reilly - Practical Monitoring - Mike Julian
* O’Reilly - Monitoring Distributed Systems - Rob Ewaschuk, Betsy Beyer
* O’Reilly - Site Reliability Engineering
* Circonus - The Art and Science of the Service-Level Objective - paper by Theo Schlossnagle
