O Flow Control controla o fluxo de texto gerado. O fluxo de texto pode ir em uma direção ou outra, em vez de o mesmo conteúdo ser gerado todas as vezes. De certa forma, é como se quase pudéssemos programar nossos gráficos para gerar seus conteúdos com base em condições dinâmicas.

Controle de fluxo condicional
Vamos explorar um tipo de controle de fluxo: blocos condicionais if/else .

Um bloco condicional complexo if/else pode ser assim:

{{ if VALUE or PIPELINE passed here is TRUE }}
  # Print out this text
{{ else if OTHER VALUE or OTHER PIPELINE passed here is TRUE}}
  # Print out this other text
{{ else }}
  # If none of the conditions above are met, then print out this default text
{{ end }}

É claro que um bloco condicional if/else não precisa ser tão complexo (com tantos outros e outros ifs). Na prática, um bloco de controle de fluxo condicional simples pode ser algo assim:

{{ if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{ end }}

que é o que realmente usaremos. Este bloco pode ser interpretado assim: se não houver nenhum autoscaling.enabled valor definido pelo usuário em seu arquivo values.yaml (ou for definido como false ), imprima uma linha replicas: no manifesto enviado ao Kubernetes. Se houver um autoscaling.enabledvalor definido como true , pule isso, a linha replicas: não será impressa.

Observe como em uma instrução IF podemos usar um valor simples ou um pipeline inteiro. Então, em uma instrução IF , podemos fazer algo como extrair um valor de algum lugar, passá-lo por um pipeline de funções, transformar os dados de algumas maneiras e avaliar se o resultado final é true ou false . Mas como ele decide se é verdadeiro ou falso ?

Se o pipeline que está sendo avaliado retornar um valor booleano como true ou false , é fácil entender como isso é interpretado. Caso contrário, se for um número, 0 é interpretado como falso, números diferentes de zero como verdadeiro. Se for uma string, uma vazia é false, enquanto se contiver uma única letra, é true . E o mesmo pode ser dito para outros tipos de objetos, como arrays e assim por diante: se estiverem vazios, isso equivale a ser false , se não forem vazios, a condição será avaliada como true .

Vamos usar isso em nosso arquivo deployments.yaml . Nosso conteúdo final deve ficar assim:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: nginx
spec:
  {{ if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{ end }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository | default "nginx" }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP


Então, tudo o que fizemos foi basicamente envolver nossa linha pré-existente

réplicas: {{ .Values.replicaCount }}

entre as linhas recém-adicionadas:

{{ if not .Values.autoscaling.enabled }}

e

{{ end }}

Também precisaremos editar nosso arquivo values.yaml e definir esse novo valor de escalonamento automático que nossa instrução if verificará.

Role até o final e adicione estas linhas:

autoscaling:
  enabled: false

Certifique-se de que o texto está devidamente recuado (deve haver dois espaços vazios antes da enabled: linha False). Além disso, altere replicaCount para 3 . O conteúdo final deve ficar assim:

replicaCount: 3

image:
  repository:
  pullPolicy: IfNotPresent
  tag: "1.16.0"

autoscaling:
  enabled: false

Portanto, com o escalonamento automático desabilitado (definido como false), esperamos que nossa instrução if imprima uma linha de réplicas no manifesto gerado.

helm template ./nginx
E vemos que sim (observe também as estranhas linhas vazias adicionadas antes e depois da linha de réplicas , veremos como corrigir isso também):

---
# Source: nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:
    app: nginx
spec:
  
  replicas: 3
  
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP


Não podemos ver mais linha de réplicas .

# Controlando a saída de espaços em branco/novas linhas

Percebemos como nosso bloco condicional if gera uma saída bastante estranha (linhas vazias) ao redor da linha replicas. Se nos lembrarmos, nossa declaração if and end está enrolada nessa linha.

{{ if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{ end }}

Então, ao ver as novas linhas vazias adicionadas no manifesto gerado, podemos imaginar que elas têm algo a ver com isso if e linha end acima e abaixo da linha replicas.

spec:

  replicas: 3
  
  selector:
    matchLabels:

A linguagem de templates que usamos em nossos arquivos de template tem um método simples para lidar com isso. Nós apenas adicionamos um - sinal ao lado dos colchetes.    

Isso significa remover espaços em branco/novas linhas à esquerda :
{{-

E isso significa remover espaços em branco/novas linhas à direita :
-}}

Vamos editar nosso arquivo de modelo de implantação novamente e adicionar os - sinais “ ” em seus devidos lugares, no início da instrução if e na instrução end . O conteúdo final ficará assim:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: nginx
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository | default "nginx" }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP

Vamos ver como nosso manifesto gerado muda usando helm template ./nginx

---
# Source: nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP







