#### URLS
[Speed Index](https://gitlab.com/andrewn/speedindex-blackbox)
[Robust Perception](https://www.robustperception.io/)
[Performance Tools](https://www.brendangregg.com/bpf-performance-tools-book.html)

# Breve relato sobre o dia-a-dia da Monitoração de apps

## Instrumentalização de apps

#### Pontos de entrada e Saida
1. Medir e registrar solicitações e respostas para paginas web e endpoints de apis.
2. Medir e registrar camadas externas, banco de dados, cache, Serviços e serviços de terceiros (ex um gateway de pagamento).
3. Medir e registrar agendamentos e outros eventos periodicos (ex cron).
4. Medir eventos empresariais e funcionais significativos, como usuários sendo criados ou transações como pagamentos e vendas.
5. Medir métodos e funções que lêem e escrevem em bancos de dados e caches.

## Schema de instrumentalização
Você deve garantir que os eventos e as métricas sejam categorizados e claramente identificados pelo aplicativo, método, função ou marcador semelhante para que você possa garantir que você sabe o que e onde um evento ou métrica específico é gerado.
Você deve desenvolver um esquema para seus nomes de métricas e eventos de registro (falaremos mais sobre log estruturado e semântico posteriormente neste capítulo). 
Vamos olhar para um exemplo:

#### Um examplo de metric name schema.

*location.application.environment.subsystem.function.actions*

Aqui, criamos um esquema métrico que deve abranger a maioria de nossos aplicativos típicos e pode ser facilmente reduzido para fornecer outros exemplos. Vamos aplicá-lo a uma aplicação:

```java
productiona.tornado.development.payments.collection.job.count
```

Especificamos o data center onde nosso aplicativo está localizado, no caso em produção. 
Em seguida, especificamos o nome do aplicativo. Também listamos o ambiente em execução, por exemplo, produção, desenvolvimento e assim por diante. 
Em seguida, um subsistema ou componente como pagamentos ou usuário, a função que está sendo medida, e abaixo disso, quaisquer métodos ou ações. Para aplicações menos complexas, podemos reduzir o path.

#### Tempo e o efeito 
Também é importante garantir, que o horário dos eventos seja preciso e que o tempo nos hosts que executam seus aplicativos tambem seja preciso.
Também certifique-se de que o fuso horário em seu host esteja definido como UTC para consistência entre seus hosts.
Você deve garantir que seus eventos tenham carimbos de data / hora. Se você criar eventos e métricas que contenham carimbos de data / hora, use padrões. Por exemplo, o padrão ISO8601 fornece datas e carimbos de data / hora que podem ser analisados por muitas ferramentas.
Por último, sempre que possível, minimize a carga em seu aplicativo registrando eventos de forma assíncrona. Em mais de um caso, interrupções foram causadas ou desempenho degradado pelo monitoramento ou sobrecarga de métricas de um aplicativo.

É o efeito do monitor que introduzimos. Se o seu monitoramento consumir consideráveis ciclos de CPU ou memória, então isso poderia impactar o desempenho da sua aplicação ou distorcer os resultados de qualquer monitoramento.
Agora, vamos examinar cada método de monitoramento por vez.

#### Métricas
Como grande parte do restante do nosso monitoramento, as métricas serão fundamentais para a nossa aplicação.
Então, o que devemos monitorar em nossos aplicativos? Nos queremos coletar dois tipos de métricas:
* Métricas de aplicativos, que geralmente medem o estado e o desempenho do código do seu aplicativo.
* Métricas de negócios, que geralmente medem o valor de seu aplicativo. Exemplo, em um site de comércio eletrônico, pode ser quantas vendas você fez.
Vou mostrar ou exemplos de metricas.

#### Métricas de aplicativo (golden signals)
As métricas de aplicativos medem o desempenho e o estado de seus aplicativos. Eles incluem características da experiência do usuário final do aplicativo, como latência e tempos de resposta. Por trás disso, medimos a taxa de transferência do aplicativo:
* solicitações 
* volumes de solicitação 
* transações 
* tempos de transação

Também examinamos a funcionalidade e o estado do aplicativo. Um bom exemplo disso pode ser logins ou erros bem-sucedidos e com falha, travamentos e falhas. Nós também podemos medir o volume e o desempenho de atividades como jobs, e-mails ou outras atividades assíncronas.

#### Métricas de negócios
As métricas de negócios são a próxima camada acima de nossas métricas de aplicativos. Elas são geralmente sinônimo de métricas de aplicativo. Se você pensa em medir o número de solicitações feitas a um serviço específico como sendo uma métrica de aplicativo, então a métrica de negócios geralmente faz alguma coisa com o conteúdo da solicitação. A exemplo da métrica do aplicativo pode ser medir a latência de um pagamento, transação; a métrica de negócios correspondente pode ser o valor de cada transação de pagamento. As métricas de negócios podem incluir o número de novos usuários / clientes, número de vendas, vendas por valor ou localização, ou qualquer outra coisa que ajude a medir o estado de uma empresa.

#### Padrões de monitoramento ou onde colocar suas métricas.
Depois de saber o que queremos monitorar e medir, precisamos descobrir onde colocar nossas métricas. Em quase todos os casos, o melhor lugar para colocar essas métricas é dentro nosso código e o mais próximo possível da ação que estamos tentando monitorar ou medir.
Não queremos, no entanto, colocar nossa configuração de métricas embutida em todos os lugares onde queremos registrar uma métrica. Em vez disso, queremos criar uma biblioteca de utilitários: uma função que nos permite criar uma variedade de métricas a partir de uma configuração centralizada.
Às vezes, isso também é chamado de "utility pattern" - registro de métricas como uma classe de utilitários que não requer instanciação e possui apenas métodos estáticos.

#### The utility pattern
Um padrão comum é criar uma biblioteca de utilitários ou módulo usando ferramentas como StatsD, Bibliotecas Java Micrometer, ou bibliotecas prometheus. A biblioteca de utilitários exporia uma API que nos permite criar e incrementar Métricas. Podemos então usar essa API em toda a nossa base de código para instrumentar as áreas do aplicativo em que estamos interessados.
Vamos dar uma olhada em um exemplo disso. 
Nós criamos um "Ruby-esquecode" código para demonstrar, e presumimos que já criamos uma biblioteca chamada "Metric".

```ruby
include Metric
def pay_user(user, amount)
pay(user.account, amount)
Metric.increment 'payment'
Metric.increment "payment.amount, #{amount.to_i}"
Metric.increment "payment.country, #{user.country}"
send_payment_notification(user.email)
end
def send_payment_notification(email)
send_email(payment, email)
Metric.increment 'email.payment'
end
```

Aqui, primeiro incluímos nossa biblioteca de utilitários Metric. Podemos ver que especificamos metricas de aplicativos e métricas de negócios. Primeiro definimos um método chamado "pay_user" que leva os valores de usuário e quantia como parâmetros. Em seguida, fizemos um pagamento usando nossos dados e três métricas incrementadas:

1. Uma métrica de pagamento - aqui, incrementamos a métrica cada vez que fazemos um    pagamento.
2. Uma payment.amount metric - Essa métrica registra cada pagamento por valor.
3. Uma payment.country metric - Esta métrica registra o país de origem do cada pagamento.
4. Por fim, enviamos um e-mail usando um segundo método, send_payment_notification, onde incrementamos uma quarta métrica: email.payment. O email.payment métric conta o número de emails de pagamento enviados.


#### O external pattern
E se você não controlar a base do código, não puder inserir monitores ou medidas dentro seu código, ou talvez tenha um aplicativo legado que não pode ser alterado ou atualizado?
Em seguida, você precisa encontrar o próximo local mais próximo ao seu aplicativo. Os lugares mais obvios são as saídas e subsistemas externos em torno de seu aplicativo.
Se o seu aplicativo emite logs, identifique o material que eles contêm e veja se você pode usar seu conteúdo para medir o comportamento do aplicativo. 
Este é um uso ideal para Logstash e filtros como grok. Você pode usar filtros, como o plug-in de métricas, para dissecar suas entradas de registro e extraia dados que você pode mapear e enviar para Prometheus/NewRelic ou Elasticsearch a ser indexado. Freqüentemente, você pode rastrear a frequência dos eventos por simplesmente registrar as contagens de entradas de log específicas.
Se o seu aplicativo registra ou dispara eventos em outros sistemas - coisas como transações de banco de dados, agendamento de trabalho, e-mails enviados, chamadas para autenticação ou autorização de sistemas, caches ou armazenamentos de dados - então você pode usar os dados contidos nestes eventos ou nas contagens de eventos específicos para registrar o desempenho de seu aplicativo.

#### Construindo métricas em um aplicativo de testes

Agora que temos algum conhecimento sobre o monitoramento de aplicativos, vamos dar uma olhada em um exemplo de como podemos implementar isso no mundo real. 
Vamos construir um aplicativo que tira proveito de uma biblioteca de utilitários para enviar eventos do aplicativo para um servidor de statistics aggregation denominado Prometheus.

***
Ferramenta de gerenciamento de desempenho, ou APM, como New Relic ou AppDynamics. 
Esses geralmente são plug-ins ou add-ons para seu aplicativo que coletam e enviam dados e desempenho de aplicativos para um serviço que processa e exibe isto.
***

#### O que é o Prometheus?
Conforme descrito no próprio github da ferramenta, o Prometheus é um sistema de monitoramento para serviços e aplicações. Ele coleta as métricas de seus alvos em determinados intervalos, avalia expressões de regras, exibe os resultados e também pode acionar alertas se alguma condição for observada como verdadeira.
Dentre muitas, estas são principais características do Prometheus:

* É um modelo de dados multi-dimensional (time series).
* Possui uma linguagem própria(PromQL) para queries de dados em formato time series.
* Totalmente autônomo, sem dependência de armazenamento externo.
* A coleta das métricas ocorre com um modelo pull e via HTTP.
* Também é possível enviar métricas através de um gateway intermediário.
* A definição dos serviços a serem monitorados pode ser feita através de uma configuração estática ou através de descoberta.
* Possui vários modos de suporte a gráficos e painéis.
* O projeto Prometheus inclui uma coleção de bibliotecas de cliente que permitem que as métricas sejam publicadas para que possam ser coletadas (ou "copiadas" usando a terminologia do Prometheus) pelo servidor de métricas.

#### Métricas Prometheus / instrumentação de código com OpenMetrics.

No seguinte tutorial orientado a exemplo, aprenderemos como usar Prometheus metrics / OpenMetrics para instrumentar seu código se você estiver usando Golang, Java, Python ou Javascript. Cobriremos os diferentes tipos de métricas e forneceremos trechos de código prontamente executáveis.

As bibliotecas de métricas do Prometheus foram amplamente adotadas, não apenas por usuários do Prometheus, mas por outros sistemas de monitoramento, incluindo InfluxDB, OpenTSDB, Graphite etc. Hoje em dia, muitos projetos CNCF expõem métricas prontas para usar usando o formato de métricas Prometheus. Você também os encontrará nos principais componentes do Kubernetes, como o servidor de API, etcd, CoreDNS e muito mais. Você pode aprender mais sobre isso no guia de monitoramento do Kubernetes com Prometheus.

O formato de métricas do Prometheus é tão amplamente adotado que se tornou um projeto independente: OpenMetrics, que se esforça para tornar essa especificação de formato de métrica um padrão da indústria. 

#### Prometheus metrics: dot-metrics vs tagged metrics
Antes de descrever o formato de métricas / OpenMetrics do Prometheus em particular, vamos dar uma olhada mais ampla nos dois paradigmas principais usados para representar uma métrica: *dot notation e multi-dimensional tagged metricas*.

Vamos começar com métricas *dot notation*. Em essência, tudo o que você precisa saber sobre a métrica está contido no nome da métrica. Por exemplo:

```ruby
production.server5.pod50.html.request.total
production.server5.pod50.html.request.error
```
Essas métricas fornecem os detalhes e a hierarquia necessárias para utilizar suas métricas com eficácia. Para tornar mais rápido e fácil o uso de suas métricas, este modelo de exposição de métricas sugere que, se você quiser uma agregação diferente, deve calcular essa métrica antecipadamente e armazená-la usando um nome diferente. Então, com nosso exemplo acima, vamos supor que estamos interessados nas métricas de "solicitações" em todo o serviço. Podemos reorganizar nossas métricas para ficar assim:

```ruby
production.service-nginx.html.request.total
production.service-nginx.html.request.error
```

Você pode imaginar muitas outras combinações de métricas de que possa precisar.

Por outro lado, o formato de métrica do Prometheus tem uma abordagem simples para nomear métricas. Em vez de um nome hierárquico separado por pontos, você tem um nome combinado com uma série de rótulos ou tags:

```java
<metric name>{<label name>=<label value>, ...}
```

Uma série temporal com o nome da métrica http_requests_total e os rótulos service = "service", server = "pod50 ″ e env =" production "pode ser escrita assim:

```java
http_requests_total{service="service", server="pod50", env="production"}
```

Dados altamente dimensionais basicamente significam que você pode associar qualquer número de rótulos específicos de contexto a cada métrica enviada.

Imagine uma métrica típica como http_requests_per_second, cada um de seus servidores da web está emitindo essas métricas. Você pode então agrupar os rótulos (ou dimensões):

Web Server software (Nginx, Apache)
Environment (production, staging)
HTTP method (POST, GET)
Error code (404, 503)
HTTP response code (number)
Endpoint (/webapp1, /webapp2)
Datacenter zone (east, west)

E voila! Agora você tem dados N-dimensionais e pode facilmente derivar os seguintes gráficos de dados:
* Número total de solicitações por pod de servidor da web em produção
* Número de erros HTTP usando o servidor Apache para webapp2 em teste
* Solicitações POST mais lentas segmentadas por URL de endpoint.

#### Formato de métricas / OpenMetrics do Prometheus
O formato baseado em texto das métricas do Prometheus é orientado por linhas. As linhas são separadas por um caractere de alimentação de linha (n). A última linha deve terminar com um caractere de alimentação de linha. Linhas vazias são ignoradas.

Uma métrica é composta por vários campos:

* Nome da métrica
* Qualquer número de rótulos (pode ser 0), representado como uma matriz de valores-chave
* Valor métrico atual
* Carimbo de data e hora da métrica opcional

Uma métrica do Prometheus pode ser tão simples quanto:
```java
http_requests 2
```
Ou, incluindo todos os componentes mencionados:
```java
http_requests_total{method="post",code="400"}  3   1395066363000
```
A saída da métrica normalmente é precedida por linhas de metadados 
* # HELP 
* # TYPE.

A string HELP identifica o nome da métrica e uma breve descrição dela. 
A string TYPE identifica o tipo de métrica. Se não houver TYPE antes de uma métrica, a métrica é definida como não digitada. Tudo o mais que começa com um # é analisado como um comentário.

* # HELP metric_name Description of the metric
* # TYPE metric_name type
* # Comment that's not parsed by prometheus
```java
http_requests_total{method="post",code="400"}  3   1395066363000
```

Prometheus metrics / OpenMetrics representa dados multidimensionais usando rótulos ou tags como vimos na seção anterior:
```java
traefik_entrypoint_request_duration_seconds_count{code="404",entrypoint="traefik",method="GET",protocol="http"} 44
```
A principal vantagem dessa notação é que todos esses rótulos dimensionais podem ser usados pelo consumidor de métricas para executar dinamicamente; 
1. agregação 
2. definição de escopo 
3. segmentação de métricas 

Usar esses rótulos e metadados para dividir e dividir suas métricas é um requisito absoluto ao trabalhar com Kubernetes e microsserviços.

#### Bibliotecas cliente de métricas do Prometheus.
#### Bibliotecas cliente Golang, Java, Scala e Python prometheus.
O projeto Prometheus mantém 4 bibliotecas de métricas oficiais do Prometheus escritas em Go, Java / Scala, Python e Ruby.
A comunidade Prometheus criou muitas bibliotecas de terceiros que você pode usar para instrumentar outras linguagens (ou apenas implementações alternativas para a mesma linguagem):

* Bash
* C++
* Common Lisp
* Elixir
* Erlang
* Haskell
* Lua for Nginx
* Lua for Tarantool
* .NET / C#
* Node.js
* Perl
* PHP
* Rust

## Tipos de métricas / OpenMetrics do Prometheus
Dependendo do tipo de informação que você deseja coletar e expor, você terá que usar um tipo de métrica diferente. Aqui estão suas quatro opções disponíveis na especificação OpenMetrics:

#### Counter
Isso representa uma métrica cumulativa que só aumenta com o tempo, como o número de solicitações para um terminal.
*Observação: em vez de usar o Counter para instrumentar valores decrescentes, use Gauges.*

"# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed."
"# TYPE go_memstats_alloc_bytes_total counter"
```go
go_memstats_alloc_bytes_total 3.7156890216e+10
```
#### Gauge
Os gauge são medições instantâneas de um valor. Eles podem ser valores arbitrários que serão registrados.
Os gauge representam um valor aleatório que pode aumentar e diminuir aleatoriamente, como a carga do seu sistema.

"# HELP go_goroutines Number of goroutines that currently exist."
"# TYPE go_goroutines gauge"
```go
go_goroutines 73
```
##### Histograma
Um histograma mostra observações (geralmente coisas como durações de solicitação ou tamanhos de resposta) e as conta em intervalos configuráveis. Ele também fornece uma soma de todos os valores observados.
Um histograma com o nome de uma métrica de base expõe várias séries temporais durante um scrape:

"# HELP http_request_duration_seconds histograma de duração da solicitação"
"# TYPE http_request_duration_seconds histograma"
```
http_request_duration_seconds_bucket {le = "0,5"} 0
http_request_duration_seconds_bucket {le = "1"} 1
http_request_duration_seconds_bucket {le = "2"} 2
http_request_duration_seconds_bucket {le = "3"} 3
http_request_duration_seconds_bucket {le = "5"} 3
http_request_duration_seconds_bucket {le = "+ Inf"} 3
http_request_duration_seconds_sum 6
http_request_duration_seconds_count 3
```
#### Summary
Semelhante a um histograma, um Summary mostra observações (geralmente coisas como durações de solicitação e tamanhos de resposta). Embora também forneça uma contagem total de Summary e uma soma de todos os valores observados, ele calcula quantis configuráveis em uma janela de tempo deslizante.
Um resumo com um nome de métrica de base de também expõe várias séries temporais durante um scrape:

"# HELP go_gc_duration_seconds Um resumo das durações de invocação do GC."

"# TYPE go_gc_duration_seconds summary"

```bash
go_gc_duration_seconds {quantile = "0"} 3.291e-05
go_gc_duration_seconds {quantile = "0.25"} 4.3849e-05
go_gc_duration_seconds {quantile = "0,5"} 6,2452e-05
go_gc_duration_seconds {quantile = "0.75"} 9.8154e-05
go_gc_duration_seconds {quantile = "1"} 0,011689149
go_gc_duration_seconds_sum 3.451780079
go_gc_duration_seconds_count 13118
```

## Exemplos de instrumentalização de métricas Prometheus
Instrumentação de código Golang com métricas Prometheus / OpenMetrics
Para demonstrar a instrumentação do código de métricas do Prometheus no Golang, usaremos a biblioteca oficial do Prometheus para instrumentar um aplicativo simples.

Você só precisa criar e registrar suas métricas e atualizar seus valores. O Prometheus tratará da matemática por trás dos resumos e exporá as métricas para seu endpoint HTTP.
```bash
package main

import (
  "net/http"

  "github.com/prometheus/client_golang/prometheus"
  "github.com/prometheus/client_golang/prometheus/promhttp"
  "log"
  "time"
  "math/rand"
)

var (
  counter = prometheus.NewCounter(
     prometheus.CounterOpts{
        Namespace: "golang",
        Name:      "my_counter",
        Help:      "This is my counter",
     })

  gauge = prometheus.NewGauge(
     prometheus.GaugeOpts{
        Namespace: "golang",
        Name:      "my_gauge",
        Help:      "This is my gauge",
     })

  histogram = prometheus.NewHistogram(
     prometheus.HistogramOpts{
        Namespace: "golang",
        Name:      "my_histogram",
        Help:      "This is my histogram",
     })

  summary = prometheus.NewSummary(
     prometheus.SummaryOpts{
        Namespace: "golang",
        Name:      "my_summary",
        Help:      "This is my summary",
     })
)

func main() {
  rand.Seed(time.Now().Unix())

  http.Handle("/metrics", promhttp.Handler())

  prometheus.MustRegister(counter)
  prometheus.MustRegister(gauge)
  prometheus.MustRegister(histogram)
  prometheus.MustRegister(summary)

  go func() {
     for {
        counter.Add(rand.Float64() * 5)
        gauge.Add(rand.Float64()*15 - 5)
        histogram.Observe(rand.Float64() * 10)
        summary.Observe(rand.Float64() * 10)

        time.Sleep(time.Second)
     }
  }()

  log.Fatal(http.ListenAndServe(":8080", nil))
}
```
#### Experimente no Docker
Para tornar as coisas mais fáceis e porque adoramos contêineres, você pode executar este exemplo diretamente usando o Docker:

```bash
$ git clone https://github.com/sysdiglabs/custom-metrics-examples
$ 
$ docker run -d --rm --name prometheus-golang -p 8080: 8080 prometheus-golang
$ curl localhost:8080/metrics
```

## Instrumentação de código Java com métricas Prometheus / OpenMetrics
Usando a biblioteca cliente Java oficial, criamos este pequeno exemplo de instrumentação de código Java com métricas do Prometheus:

```bash
import io.prometheus.client.Counter;
import io.prometheus.client.Gauge;
import io.prometheus.client.Histogram;
import io.prometheus.client.Summary;
import io.prometheus.client.exporter.HTTPServer;

import java.io.IOException;
import java.util.Random;

public class Main {

   private static double rand(double min, double max) {
       return min + (Math.random() * (max - min));
   }

   public static void main(String[] args) {
       Counter counter = Counter.build().namespace("java").name("my_counter").help("This is my counter").register();
       Gauge gauge = Gauge.build().namespace("java").name("my_gauge").help("This is my gauge").register();
       Histogram histogram = Histogram.build().namespace("java").name("my_histogram").help("This is my histogram").register();
       Summary summary = Summary.build().namespace("java").name("my_summary").help("This is my summary").register();

       Thread bgThread = new Thread(() -> {
           while (true) {
               try {
                   counter.inc(rand(0, 5));
                   gauge.set(rand(-5, 10));
                   histogram.observe(rand(0, 5));
                   summary.observe(rand(0, 5));


                   Thread.sleep(1000);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
           }
       });
       bgThread.start();

       try {

           HTTPServer server = new HTTPServer(8080);
       } catch (IOException e) {
           e.printStackTrace();
       }
   }
}
```

#### Experimente no Docker
Baixe, crie e execute (certifique-se de ter as portas 8080 e 80 livres em seu host ou altere a porta redirecionada):
```bash
$ git clone https://github.com/sysdiglabs/custom-metrics-examples
$ docker build custom-metrics-examples / prometheus / java -t prometheus-java
$ docker run -d --rm --name prometheus-java -p 8080: 8080 -p 80:80 prometheus-java
$ curl localhost:8080
```

#### Métricas do Prometheus para monitoramento de Golden Signals
O monitoramento do Golden Signals é uma estratégia de monitoramento de microsserviços / sistemas distribuídos introduzida pelo Google. Em resumo, estas são as quatro métricas mais importantes para monitorar qualquer aplicativo de microsserviços:
* Latência ou tempo de resposta
* Tráfego ou conexões
* Erros
* Saturação

Quando você instrumenta seu código usando métricas do Prometheus, uma das primeiras coisas que você deseja fazer é expor essas métricas de seu aplicativo. As bibliotecas do Prometheus permitem que você exponha facilmente os três primeiros: latência ou tempo de resposta, tráfego ou conexões e erros.
Expor as métricas HTTP pode ser tão fácil quanto importar a biblioteca de instrumentos, como promhttp em nosso exemplo Golang anterior:
```bash
import (
  "github.com/prometheus/client_golang/prometheus/promhttp"
)
  http.Handle("/metrics", promhttp.Handler())
```

#### Prometheus Exporters
Muitos aplicativos de servidor populares, como Nginx ou PostgreSQL, são muito mais antigos do que a popularização do Prometheus metrics / OpenMetrics. Eles geralmente têm seus próprios formatos de métricas e métodos de exposição. Se você está tentando unificar seu pipeline de métrica em muitos microsserviços e hosts usando as métricas do Prometheus, isso pode ser um problema.
Para contornar esse obstáculo, a comunidade Prometheus está criando e mantendo uma vasta coleção de exportadores Prometheus. Um exportador é um programa “tradutor” ou “adaptador” capaz de coletar as métricas nativas do servidor (ou gerar seus próprios dados observando o comportamento do servidor) e republicar essas métricas usando o formato de métricas Prometheus e transportes de protocolo HTTP.

Esses pequenos binários podem ser colocados no mesmo contêiner ou pod executando o servidor principal que está sendo monitorado ou isolados em seu próprio contêiner de arquivo secundário e, em seguida, você pode coletar as métricas de serviço raspando o exportador que as expõe e as transforma em métricas do Prometheus.

#### Conclusão
Prometheus metrics / OpenMetrics facilita uma interface limpa e sem atrito entre desenvolvedores e operadores, tornando a instrumentação de código fácil e padronizada. Já existem bibliotecas para os idiomas mais populares e mais estão sendo desenvolvidas pela comunidade. Além disso, o recurso de rotulagem o torna uma ótima escolha para instrumentar métricas personalizadas se você planeja usar contêineres e microsserviços.

#### Logging

Além de incorporar métricas, também podemos adicionar suporte para logging e eventos de log para nossos aplicativos. As métricas são úteis para nos dizer o desempenho ou
manter o controle de várias partes do estado, mas os logs costumam ser muito mais expressivos.
Com os logs, fornecemos contexto ou informações adicionais sobre uma situação, ou destacamos
que algo ocorreu. Um exemplo disso é um rastreamento de pilha gerado
quando ocorre um erro. Para fins de diagnóstico, as entradas de log são extremamente úteis. Então,
para complementar nossa instrumentação existente, existem duas maneiras de deduzir a aplication status e desempenho dos logs:

• Criação de entradas de log estruturadas em pontos estratégicos de nossa aplicação, em linha com o que discutimos em nosso primer de monitoramento de aplicativos.

• Consumir dados de registro existentes, como discutimos no padrão externo, também
apresentado anteriormente neste capítulo.
Vamos examinar os dois métodos, começando com a adição de nossas próprias entradas de logs.

## Adicionando nossas próprias entradas de logs estruturadas
A maioria dos mecanismos de registro emite entradas de registro que contêm um valor de string e a mensagem ou descrição do erro. O exemplo clássico disso é o Syslog, usado
por muitos hosts, serviços e aplicativos como um formato de registro padrão. 
A mensagem Syslog se parece com:

Dec 6 23:17:01 logstash CRON[5849]: (root) CMD (cd / && runparts
--report /etc/cron.hourly)

Além da carga útil, neste caso, um relatório sobre um cron job, ele tem um carimbo de data e uma fonte (o logstash do host). Embora versátil e legível, o formato Syslog
não é ideal - é basicamente uma longa corda. Esta string é incrível da perspectiva de legibilidade - é fácil olhar para uma string Syslog e saber o que ocorreu. Mas somos o público-alvo de uma mensagem baseada em strings? 
Provavelmente no tempo em que tínhamos um pequeno volume de hosts e estávamos nos conectando a eles para ler os logs. Agora temos um pool de hosts, serviços e aplicativos, e nossas entradas de log são centralizadas. Isso significa que agora existe uma máquina que consome a mensagem de log antes que nós, humanos, a vejamos. E por causa de o formato de string eminentemente legível, esse consumo não é fácil.
Esse formato significa que provavelmente seremos forçados, como vimos anteriormente, a recorrer a expressões regulares para analisá-lo. Na verdade, provavelmente mais de uma expressão regular.
Mais uma vez, o Syslog é um bom exemplo. Implementações entre plataformas às vezes são
sutilmente diferente, e isso geralmente significa que mais de uma expressão regular precisa ser implementados e mantidas. Também vimos isso anterior, quando adicionamos
nossos logs de Docker em nossa implementação de Syslog existente. A sobrecarga adicional e fica mais difícil extrair o valor - diagnóstico ou operacional - de nosso
dados de registro.

No entanto, há uma maneira melhor de gerar logs: logs estruturados (também conhecidos
como logs semânticos ou digitados). Atualmente, não há um padrão para registro estruturado.
Houve algumas tentativas de criar um, mas nada ainda ganhou força.
Ainda assim, podemos descrever o conceito de perfilagem estruturada. Em vez de uma string como nossos exemplos de Syslog, logs estruturados tentam preservar dados ricos digitados em vez de converte-los. 
Vejamos um exemplo de código que produz um código fragmento e não estruturado:

## Exemplo de mensagem de log não estruturado

Logger.error("The system had a hiccup trying to create user" +
username)

Vamos supor que o usuário que está sendo criado seja james@example.com. Este pseudo-código geraria uma mensagem como: O sistema teve um soluço ao tentar criar
usuário james@example.com. 
Teríamos então que enviar essa mensagem para algum lugar, para o Logstash, por exemplo, e depois analisa-o em uma forma útil.
Como alternativa, podemos criar uma mensagem mais estruturada.

## Exemplo de mensagem de log estruturado

Logger.error("user_creation_failed", user=username)

Observe que em nossa mensagem estruturada, temos uma vantagem inicial em qualquer análise.
Supondo que enviemos a mensagem de log em algum formato codificado, JSON como
exemplo ou um formato binário como buffers de protocolo, então obtemos um nome de evento, user_creation_failed, e uma variável, user, que contém o nome de usuário do
usuário que não conseguimos criar, ou mesmo um objeto de usuário contendo todos os parâmetros do usuário que está sendo criado.

Vejamos como pode ser o nosso evento codificado em JSON:
[
{
"time": 1449454008,
"priority": "error",
"event": "user_creation_failed",
"user": "james@example.com"
}
]

Em vez de uma string, temos uma matriz JSON contendo uma entrada de registro estruturada: 
a hora, uma prioridade, um identificador de evento e alguns dados importantes desse evento: o usuário que nosso aplicativo não conseguiu criar. Estamos registrando uma série de objetos que agora estão facilmente consumidos por uma máquina em vez de uma string que precisamos analisar.






