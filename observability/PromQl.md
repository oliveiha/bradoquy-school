Primeiros passos com PromQL
Nesse post vamos falar sobre o PromQL, que nada mais é do que uma linguagem de consulta do Prometheus, ela nos possibilita selecionar e agregar dados de séries temporais em tempo real.
Essa poderosa linguagem de expressão nos permite realizar filtros utilizando os rótulos de séries temporais e utilizar os resultados de cada expressão para visualizar graficamente.

Consulta do Prometheus
Os nomes das métricas em séries temporais são a parte principal de qualquer consulta no PromQL, todas as métricas do Prometheus são baseadas em tempo, as métricas são divididas em quatro partes, sendo elas:

metric_name: O nome da métrica.
labels: São chave-valor que distinguem cada métrica com o mesmo nome.
value: É o valor mais recente coletado, esse valor é um float64.
timestamp: Registro de data e hora com precisão de milissegundos, porém esse registro não aparece no console de consulta, para poder visualizá-lo você precisa alternar para a guia Gráfico no Prometheus.

Tipos de métricas
As métricas são obtidas através dos exportadores do Prometheus, ele realiza scrapes ou seja raspagem em intervalos regulares. Essa configuração de intervalos é feita no arquivo de configuração do Prometheus chamado de prometheus.yml em scrape_interval que por padrão realiza a raspagem a cada 15s.

Existem quatro tipos de métricas:

Counters: São métricas cumulativas que sempre evoluem como por exemplo, número de acessos a uma página.
Gauges: São métricas voláteis, tais como velocidade de transmissão, temperatura, etc.
Histogram: São métricas que se baseiam em observações, geralmente baseados numa amostragem temporal.
Summary: Summary é semelhante ao histogram, ele realiza coletas amostras e cria várias métricas, incluindo soma (sum) e contagem (count).
Laboratório
Vamos ver na prática como criar gráficos utilizando as expressões do PromQL e exibi-los no Prometheus.

Nesse laboratório utilizarei o Prometheus executando em container do Docker, supondo que você já possua Docker e Docker Compose instalados na sua máquina.

Conteúdo do docker-compose.yml:

version: '3.3'
02
 
03
volumes:
04
  prometheus:
05
 
06
services:
07
  prometheus:
08
    image: prom/prometheus
09
    hostname: prometheus
10
    ports:
11
      - 9090:9090


Podemos filtrar a consulta utilizando algumas labels (rótulos), temos quatro operadores suportados que podemos utilizar nos filtros de labels sendo eles:

= Igual
!= Não igual
=~ Corresponde a regex
!~ Não corresponde a regex

https://github.com/google/re2/wiki/Syntax
https://blog.4linux.com.br/um-banco-de-dados-time-series-chamado-timescaledb/

Dessa forma estamos filtrando na métrica promhttp_metric_handler_requests_total apenas pelo código igual a 200.

Vetores de intervalo
Podemos anexar uma duração de intervalo em uma consulta, dessa forma obtemos vários valores de data e hora registrados no intervalo selecionado. Isso se chama vetor de intervalo, esses valores serão registrados na série temporal.

Para as durações de tempo, possuímos as seguintes unidades:

s – segundos
m – minutos
h – horas
d – dias
w – semanas
y – anos
Vamos realizar uma consulta buscando os valores registrados nos últimos 5 minutos da métrica promhttp_metric_handler_requests_total:


Funções
Geralmente utilizamos uma função em um vetor de intervalo dessa forma obtemos um vetor instantâneo, assim podemos visualizá-lo graficamente (apenas vetores instantâneos podem ser representados graficamente).

O Prometheus possui diversos tipos de funções para vetores instantâneos e de intervalo, algumas delas são:

rate() – Essa função calcula a taxa média de aumento por segundo da série temporal no vetor de intervalo.
irate() – Essa função calcula a taxa instantânea de aumento por segundo da série temporal no vetor de intervalo. Isso é baseado nos dois últimos pontos de dados.
increase() – Essa função calcula o aumento na série temporal no vetor de intervalo, ele basicamente multiplica a taxa pelo número de segundos no seletor de intervalo de tempo.

rate(promhttp_metric_handler_requests_total{code="200"}[5m])

Agora é possível ver graficamente vetores de intervalo em um vetor instantâneo.

Operadores de agregação
O Prometheus possui alguns operadores de agregação internos, que podemos utilizar para agregar os elementos de um único vetor instantâneo, dessa forma teremos um novo vetor de menos elementos com valores agregados, alguns deles são:

sum – Calcula soma sobre dimensões.
min – Seleciona as dimensões mínimas acima.
max – Seleciona o máximo de dimensões.
avg – Calcula a média das dimensões.
count – Conta o número de elementos no vetor.
count_values – Conta o número de elementos com o mesmo valor.

Podemos utilizar o operador sum para obter o número totais de requisições da instância localhost:
sum(promhttp_metric_handler_requests_total) by (instance)

https://prometheus.io/docs/prometheus/latest/querying/operators/#binary-operators

Dessa forma estamos somando todas as requisições da instância localhost independente do código de reposta.

O PromQL também suporta operadores binários aritméticos, sendo eles:

+ = Adição.
– = Subtração.
* = Multiplicação.
/ = Divisão.
% = Módulo.
^ = Potenciação.
Podemos utilizar esses operadores para somar o valor de duas métricas, como por exemplo:

promhttp_metric_handler_requests_total{code="200"} + on (instance) promhttp_metric_handler_requests_total{code="500"}