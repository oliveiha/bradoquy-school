Digamos que queremos uma rotulagem mais complexa do que temos atualmente, um app: rótulo nginx simples. Digamos que queremos que nossos rótulos sejam assim:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-release-nginx
  labels:    
    app.kubernetes.io/name: nginx
    app.kubernetes.io/instance: my-release

Precisaríamos escrever repetidamente esses rótulos em vários pontos. Por exemplo, em nosso caso, no modelo deployment.yaml , temos três locais onde esses rótulos apareceriam.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:    
    app.kubernetes.io/name: nginx
    app.kubernetes.io/instance: RELEASE-NAME
spec:
  selector:
    matchLabels:      
      app.kubernetes.io/name: nginx
      app.kubernetes.io/instance: RELEASE-NAME
  template:
    metadata:
      labels:        
        app.kubernetes.io/name: nginx
        app.kubernetes.io/instance: RELEASE-NAME
    spec:
      containers:
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP

Além disso, precisaremos usar esses mesmos rótulos em alguns outros objetos do Kubernetes também. Em nosso exercício, também criaremos um modelo service.yaml para obtermos um serviço Kubernetes para nosso aplicativo Nginx, para expor nosso site à Internet. Agora imagine que, em vez dessas duas linhas, temos ainda mais, que precisamos reescrever repetidamente, uma a uma, na forma de modelo, em vários arquivos .yaml . Seria muito tedioso, para não mencionar, propenso a erros. No nosso caso, precisaríamos repetir estas linhas:

app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}

em todos os pontos, eles são necessários. Agora, isso é fácil de lembrar. Mas para coisas mais complexas, podemos esquecer que realmente usamos .Release.Name para nosso rótulo de instância . À medida que criamos mais e mais arquivos de modelo .yaml , no quinto arquivo que criamos, digamos, 5 dias depois, podemos usar erroneamente .Chart.Name para nosso rótulo de instância porque simplesmente esquecemos o que fizemos da última vez. Mas há uma maneira melhor de fazer isso.

# Arquivos auxiliares/modelos nomeados

Todo arquivo que o Helm encontra no diretório templates/ , ele considera que é um template que deve ser renderizado em um arquivo manifesto Kubernetes . Existem algumas exceções, por exemplo, o arquivo NOTES.txt que exploraremos em um blog posterior. Mas os arquivos que têm nomes que começam com sublinhado são tratados de forma diferente. O Helm considera que esses não são arquivos de modelo que devem gerar manifestos do Kubernetes. Em vez disso, esses arquivos são usados ​​para armazenar o que a documentação do Helm chama de parciais e auxiliares.Mas isso soa um pouco enigmático. O que armazenamos aqui são, de certa forma, semelhantes a funções em programação. Podemos criar uma biblioteca, definir as funções de que precisamos aqui, uma vez, e usá-las em todos os arquivos de modelo que as requeiram, sem reescrever as mesmas funções novamente. Se mesmo esta explicação parece difícil de entender, vamos apenas ver na prática, pois isso torna mais claro.

Mencionamos como temos esses rótulos que ficam se repetindo em vários pontos. Então, vamos definir essas duas linhas em um arquivo auxiliar. Vamos nomear este arquivo _helpers.tpl , pois esta é uma prática comum.

{{/*
Here, we generate selector labels. It's highly recommended that you include comments here, so that other people know what this section does, but it's not mandatory.
*/}}
{{- define "nginx.labels" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

Basicamente definimos um tipo de função e decidimos chamá-la nginx.labels. Claro, dizemos função aqui apenas para dar uma ideia aos programadores de que elas são semelhantes às funções na prática regular de codificação. Mas estes são tecnicamente chamados de templates nomeados no mundo de Helm.

Poderíamos ter nomeado nosso modelo da maneira que quiséssemos, mas essa convenção de prefixar o nome com o nome do gráfico atual facilita a prevenção de alguns erros. Por exemplo, digamos que simplesmente o nomeamos rótulos. Podemos ter alguns gráficos complexos que dependem de subgráficos. Se esses subgráficos também tiverem um arquivo auxiliar que contenha um rótulo chamado template, ele poderá substituir o que definimos aqui, gerando tipos de conteúdo totalmente diferentes, criando confusão para nós e levando a longas sessões de depuração para rastrear o que deu errado.

Se você mantiver o formato name_of_chart.name_of_template para todos os seus modelos nomeados, você deve evitar facilmente esses problemas, pois cada modelo nomeado em cada gráfico e subgráfico deve agora ter um nome exclusivo.

Agora que definimos essas coisas repetitivas que precisamos usar em três pontos diferentes em nosso modelo deployment.yaml , vamos ver como fazemos isso (equivalente a chamar uma função no programa principal).

Sob o dois labels: sections e o matchLabels: section, excluímos tudo e o substituímos pelo nosso modelo nomeado definido em nosso arquivo auxiliar. O resultado final ficará assim:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    {{- include "nginx.labels" . | indent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "nginx.labels" . | indent 6 }}
  template:
    metadata:
      labels:
        {{- include "nginx.labels" . | indent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository | default "nginx" }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Assim, com uma palavra- chave Include simples, podemos chamar nosso template nomeado, definido em nosso arquivo _helpers.tpl , para preencher o que precisamos adicionar aqui, ou seja, nossos dois rótulos modelados. Bem fácil. Mas vale a pena notar as coisas adicionais que fizemos. Usamos o sinal “-“ para remover as linhas extras vazias desnecessárias que essas linhas include adicionariam ao manifesto gerado.

Além disso, usamos a função indent para inserir o número necessário de espaços na frente de cada um de nossos rótulos.

Mas o mais importante, vemos um ponto . após incluir e o nome do modelo a ser incluído. O ponto é uma maneira de passar o chamado escopo de nível superior para este modelo nomeado. Lembre-se, nosso modelo nomeado se parece com isso

{{- define "nginx.labels" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

.Chart.Name e {{ .Release.Name }}precisa buscar o nome do gráfico e o nome do lançamento de algum lugar. Se você é um desenvolvedor, provavelmente já entende a necessidade de escopos aqui e o que realmente acontece. Se você não é, você pode pensar desta forma. Usando . para passar o escopo de nível superior aqui, quando o Helm entrar no modelo nomeado e começar a processá-lo, quando finalmente precisar buscar o .Chart.Name ele sabe que deve puxar isso do nome do gráfico atual em que está (o gráfico principal, o gráfico superior nível chart) , porque foi instruído a procurar no escopo de nível superior atual. Sem um escopo, ele não saberia de qual contexto ou de qual ambiente extrair esses valores. Por exemplo, imagine que um modelo nomeado é chamado de uma dependência (gráfico filho do gráfico principal). Este modelo nomeado puxa o nome do gráfico pai? Ou ele puxa o nome do gráfico filho? Sem escopo, ele não sabe de onde obter esses dados.

Agora vamos explorar o manifesto que nosso gráfico recém-reescrito gera.

user@debian:~$ helm template ./nginx
---
# Source: nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:    
    app.kubernetes.io/name: nginx
    app.kubernetes.io/instance: RELEASE-NAME
spec:
  selector:
    matchLabels:      
      app.kubernetes.io/name: nginx
      app.kubernetes.io/instance: RELEASE-NAME
  template:
    metadata:
      labels:        
        app.kubernetes.io/name: nginx
        app.kubernetes.io/instance: RELEASE-NAME
    spec:
      containers:
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP

Muito legal, para 6 linhas geradas, tivemos que escrever apenas 3 linhas em nosso deployment.yaml . E mais importante, agora podemos usar esse modelo nomeado em qualquer arquivo que precisarmos, sem ter que lembrar as especificidades de como realmente definimos/modelamos esses rótulos. Usei o nome do gráfico ou o nome da versão para o rótulo da minha instância? Agora, essa questão não importa, você tem a garantia de gerar consistentemente os mesmos tipos de rótulos sempre que precisar deles, sem a possibilidade de alternar acidentalmente para um formato diferente no meio da escrita de seu gráfico complexo.

Agora, como mencionado anteriormente, vamos ver como podemos usar o mesmo modelo nomeado do nosso arquivo auxiliar, em nossos outros arquivos de modelo.

De certa forma, para completar nosso pequeno gráfico Nginx Helm, também precisamos de um objeto de serviço, para que possamos tornar os pods Nginx acessíveis a partir de qualquer navegador da web. No caso de implantação, precisaríamos de uma estrutura semi-complexa aqui, com um balanceador de carga na frente do nosso serviço, mas vamos mantê-lo simples e apenas fazer algo que funcione bem o suficiente para nossos propósitos de teste.

Então, criaremos outro arquivo de modelo, chamado service.yaml , que gerará um manifesto para um objeto de serviço.

apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    {{- include "nginx.labels" . | indent 4 }}
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "nginx.labels" . | indent 4 }}

Podemos ver como, mais uma vez, usamos nosso modelo nomeado em dois pontos aqui. Então, vemos mais um exemplo de por que os arquivos _helper e os modelos nomeados são úteis.

Pode não ser imediatamente óbvio o que você deseja incluir em seus arquivos auxiliares, mas você pode começar pensando O que eu/vou usar repetidamente na maioria dos meus arquivos de modelo?. Outra maneira de descobrir o que é útil ter nesses arquivos auxiliares é baixando gráficos feitos por profissionais e vendo o que eles incluíram lá.    