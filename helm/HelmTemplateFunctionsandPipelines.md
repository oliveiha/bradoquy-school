No gráfico que criamos até agora, atribuímos valores adequados a todas as configurações personalizáveis ​​listadas em values.yaml e referenciadas em deployment.yaml . Assim, para uma linha como image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"Helm, basta buscar os valores que fornecemos em nosso arquivo values.yaml e gerar o resultado final, que pode ser algo como image: "nginx:1.16.0". Mas foi fácil no nosso caso. Temos um pequeno values.yaml para trabalhar. Nós apenas tivemos que personalizar quatro configurações. Mas em um gráfico complexo, pode haver centenas de configurações personalizáveis. A maioria dos usuários não fornecerá valores para todos eles. Isso leva a uma situação em que algo como o nome da imagem pode acabar vazio. Vamos realmente ver isso na prática.

Vamos abrir o arquivo values.yaml e excluiremos o "nginx" valor que atribuímos ao nome do repositório. O resultado final ficará assim:

```yaml
replicaCount: 1

image:
  repository:
  pullPolicy: IfNotPresent
  tag: "1.16.0"
```
Se olharmos agora para o manifesto que este gráfico geraria. veremos que o nome do repositório está realmente ausente.

user@debian:~$ helm template ./nginx
```yaml
# Source: nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:
    app: nginx
spec:
  replicas: 1
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
          image: ":1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Se tentássemos instalar este gráfico, pareceria que nada deu errado à primeira vista, mas quando dermos uma olhada nos pods, veremos isso:

```bash
user@debian:~$ kubectl get pods
NAME                                READY   STATUS             RESTARTS   AGE
nginx-deployment-6c76ffbdd7-z4qgf   0/1     InvalidImageName   0          3s
```

Nenhum pod é iniciado, com um status de erro mostrando InvalidImageName . Isso porque nosso gráfico, sem um nome de repositório fornecido no arquivo values.yaml , gerou o nome da imagem incompleta image: ":1.16.0" em vez do que era antes, image: "nginx:1.16.0". Portanto, o que precisamos aqui é uma maneira simples de nosso gráfico ter alguns valores padrão aos quais possa recorrer, caso os usuários não forneçam nada em seu arquivo values.yaml. A lógica seria Se o usuário fornecesse algo em seu arquivo values.yaml, então use isso. Se ele não o fez, use este valor padrão: 'nginx'. Podemos fazer isso usando funções.

# Funções

Usar funções em um gráfico é simples. Vamos abrir nosso arquivo de modelo deployment.yaml e ver uma função em ação.

Em nosso modelo, geramos o nome do contêiner buscando o nome do gráfico. Então, basicamente, o contêiner será nomeado exatamente como o gráfico é nomeado. Mas e se esse nome tiver que respeitar algum tipo de convenção? Por exemplo, talvez precisemos que o nome do contêiner esteja em letras maiúsculas. Podemos usar a função upper para pegar um valor de texto e transformá-lo em letras maiúsculas, então nginx ou Nginx se tornaria NGINX quando passado por essa função.

Role para baixo até a seção de contêineres neste arquivo e adicione a função superior antes .Chart.Name de . O conteúdo final deve ficar assim:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: {{ upper .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Se agora verificarmos o manifesto que nosso gráfico geraria após salvar o arquivo:

helm template ./nginx

---
# Source: nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: NGINX
          image: ":1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP

O nome do contêiner está em letras maiúsculas agora.

De um modo geral, você deve pensar em funções sempre que precisar transformar os dados que está buscando em seu gráfico. No entanto, não se limita a este cenário, pois existem muitos tipos de funções e algumas podem até gerar dados do nada. Por exemplo, se você quiser adicionar um carimbo de data/hora a um objeto gerado no Kubernetes, poderá usar a função now para adicionar a data e hora atual a qualquer local no manifesto.

Por exemplo, o arquivo de modelo pode ter uma linha como:

 timeLaunched: {{ now }}

 E o manifesto gerado por este gráfico ficaria assim:

 ```bash
 timeLaunched: 2021-06-08 08:38:50.701447903 -0400 EDT m=+0.049411442
 ```

 Há uma lista bem grande de funções úteis que temos disponíveis e esta página é um bom ponto de partida para se familiarizar com as que você pode precisar: 
[lista de funçoes](https://helm.sh/docs/chart_template_guide/function_list/)

# Pipelines

Mas vamos voltar ao que realmente precisávamos aqui: usar valores padrão se o usuário não fornecer nenhum em seu arquivo values.yaml.

No processo, também aprenderemos que podemos usar funções de uma maneira diferente, por meio de pipelines.

Os pipelines nos gráficos do Helm são bastante semelhantes aos pipelines que você pode ter visto ou usado na linha de comando de um ambiente Linux.

Por exemplo, para imprimir abcd na tela usaríamos um comando simples como:

echo "abcd"

Mas se quisermos pegar a saída desse comando e processá-la de alguma forma, em outro comando, podemos usar um pipeline. Nesse caso, pegamos a saída normal do comando echo, que seria abcd , passamos para o comando tr que o processa, transforma todas as letras em maiúsculas e gera o resultado final

user@debian:~$ echo "abcd" | tr a-z A-Z
ABCD

A sintaxe e a lógica de como usamos pipelines nos gráficos do Helm são muito semelhantes.

Vamos abrir nosso deployment.yaml e ver.

Antes de tudo, vamos editar a linha name: {{ upper .Chart.Name }}. Neste formulário, estamos basicamente dizendo, use esta função, upper , neste valor buscado, .Chart.Name. Mas com pipelines, vamos dizer “Ok, extraímos um pedaço de texto aqui, de .Chart.Name. Agora pegue este pedaço de texto e envie para esta função aqui, superior.

Nossa name: {{ upper .Chart.Name }}linha se torna

name: {{ .Chart.Name | upper }}

(este é realmente um nome inválido para um contêiner, pois não é permitido nomeá-lo com todas as letras maiúsculas, mas estamos apenas testando as coisas e reverteremos essa alteração depois de vermos seu efeito)

Agora vamos continuar e também resolver nosso problema anterior. Vimos que sem um valor de repositório de imagens definido no arquivo values.yaml, nosso gráfico falha na instalação.

Vamos fazer com que ele use um nome de repositório padrão, caso o usuário não forneça nenhum valor no arquivo values.yaml .

Vamos modificar a linha

image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"

image: "{{ .Values.image.repository | default "nginx" }}:{{ .Values.image.tag }}"

Vale a pena notar que é importante colocar o nginx entre aspas “” . Não podemos escrever , precisamos escrever caso contrário o interpretador do Helm pensaria que nginx é o nome de alguma função e lançaria um erro como Error: parse error at (nginx/templates/deployment.yaml:19): função “nginx” não definida .default nginxdefault "nginx"

Agora, nosso arquivo deployment.yaml final deve ficar assim:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: {{ .Chart.Name | upper }}
          image: "{{ .Values.image.repository | default "nginx" }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

E agora, se dermos uma olhada no manifesto que este gráfico geraria helm template ./nginx, vemos esta saída:

```yaml
# Source: nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: NGINX
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Assim, vemos a linha image: "nginx:1.16.0"em que o valor nginx reapareceu magicamente, embora nosso arquivo values.yaml atual não forneça atualmente nenhum nome de repositório.

replicaCount: 1

image:
  repository: 
  pullPolicy: IfNotPresent
  tag: "1.16.0"

Agora vamos abrir o arquivo de modelo de implantações e remover o pipeline de função superior para que nosso gráfico gere um nome de contêiner válido.

```yaml
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
```





