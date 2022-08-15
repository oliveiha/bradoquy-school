Os gráficos do Helm são incrivelmente versáteis e podem automatizar quase qualquer tipo de instalação de pacotes Kubernetes que possamos imaginar. De certa forma, eles são semelhantes aos assistentes de instalação que usamos no sistema operacional Windows. Um assistente de instalação, além de extrair os arquivos e diretórios do aplicativo, também pode adicionar atalhos relevantes à área de trabalho, configurar o aplicativo para iniciar quando o Windows iniciar, instalar bibliotecas adicionais necessárias e assim por diante. O mesmo vale para os gráficos do Helm. Embora os gráficos não sejam tecnicamente programas, eles podem agir como programas. Além de apenas instalar vários objetos do Kubernetes para colocar nosso aplicativo em funcionamento, eles também podem fazer algumas coisas extras.

Mas pode ser esmagador pensar em um milhão de coisas que um gráfico do Helm pode fazer. Então, vamos começar com algo simples e aprender os pedaços importantes, um por um.

Escrevendo nosso primeiro gráfico de Helm
O Helm tem um comando embutido para criar um gráfico básico com o qual podemos começar a trabalhar. Isso criará a estrutura básica de diretórios para um gráfico, juntamente com os arquivos mais importantes de que precisamos.

Vamos ver o que precisamos editar para fazer este gráfico instalar um site básico do Nginx em nosso cluster Kubernetes.

Primeiro, entraremos no diretório do nosso gráfico recém-gerado.

Conforme discutido nas lições anteriores, Chart.yaml é como uma página Sobre para o gráfico, onde suas propriedades principais são definidas: seu nome, descrições sobre o que ele faz, e-mails dos mantenedores, dependências e assim por diante. Vamos abrir isso usando qualquer editor.

Podemos ver tudo bem descrito nos comentários (linhas precedidas pelo sinal #).

Vamos supor o seguinte cenário. Construímos isso para nossa empresa e queremos que os outros funcionários que o utilizam tenham algumas informações básicas sobre o gráfico. Modificaremos a descrição e adicionaremos um e-mail ao final, para que as pessoas possam entrar em contato conosco em caso de dúvidas.

O resultado final deve ficar assim:

```yaml
apiVersion: v2
name: nginx
description: Basic Nginx website for our company

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "1.16.0"

maintainers:
- email: john@example.com
  name: John Smith
```

Agora salve o arquivo. Observe que você deve respeitar as mesmas regras de formatação que seguiria ao editar um arquivo YAML normal para Kubernetes (por exemplo, em “mantenedores” alinhamos tudo com espaços duplos; um espaço após “-” e dois espaços antes de “nome” para que eles ambos estão alinhados da mesma forma, sinalizando que são filhos do grupo “mantenedores”).

Agora vamos mudar para o diretório de templates onde a maior parte da mágica acontece.

Vamos excluir todo o conteúdo aqui e começar do zero, pois é mais fácil de entender se construirmos tudo peça por peça, explorando vários conceitos, como funções, pipelines, controles de fluxo, ganchos e assim por diante, à medida que avançamos.

Fazendo nosso gráfico buscar valores do arquivo values.yaml
Vamos construir uma implantação simples do Kubernetes que executará nosso(s) pod(s) Nginx.

Normalmente, uma implantação pode ser algo assim:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
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
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Mas não queremos usar valores estáticos. Queremos que nosso gráfico gere dinamicamente coisas como o nome da implantação, pode ser baseado no nome da versão que um usuário escolheu quando instalou o gráfico. Também queremos definir o número de réplicas com base nos valores que os usuários podem definir em seu arquivo values.yaml e assim por diante. Em poucas palavras, precisamos escrever o gráfico de forma que ele se adapte às necessidades de cada usuário.

Alguns recursos devem ter nomes exclusivos
Imagine que em nosso gráfico, usamos esse nome para a implantação, destacado abaixo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
```

Agora imagine que instalamos uma versão baseada neste gráfico. Tudo vai bem. A versão está instalada, uma implantação chamada nginx-deployment chega ao nosso cluster Kubernetes. Mas se tentarmos instalar uma segunda versão com base neste gráfico, ela falhará. Por quê? Porque o Helm tentaria criar uma segunda implantação, com o mesmo nome: nginx-deployment . Isso entra em conflito com o mais antigo que usa esse nome.

Então, como resolvemos isso? Nós modelamos o nome da implantação. Usamos a linguagem de templates do Helm para basicamente dizer Ei, Helm, o nome desta implantação deve ser baseado em como o usuário escolheu nomear sua versão. Dê uma olhada nesta linha:

```yaml
name: {{ .Release.Name }}-nginx
```

Dessa forma, se criarmos um release chamado release1 e outro chamado release2 , o primeiro nomeará a implantação como release1-nginx enquanto o segundo o chamará de release2-nginx . E agora temos nomes exclusivos garantidos.

De um modo geral, devemos seguir técnicas semelhantes para todos os objetos do Kubernetes que devem ter valores/nomes exclusivos. O Helm não nos permite instalar duas versões com o mesmo nome, portanto, baseando os nomes de nossos objetos Kubernetes no nome da versão, podemos ter certeza de que nossos gráficos nunca poderão criar dois objetos com o mesmo nome. Além disso, quando mais tarde exploramos nossos objetos, ver algo chamado release5-pvc rapidamente nos ajuda a identificar a qual release esse objeto também pertence.

Portanto, por enquanto, adicione esse conteúdo ao arquivo deployment.yaml .

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
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

A segunda coisa interessante que vemos aqui é {{ .Values.replicaCount }}. As chaves de abertura e fechamento {{ }} incluem o que é chamado de diretiva de modelo e a sintaxe é específica para a linguagem de modelagem Go.

Em vez de usar um número de réplica estático aqui, extraímos o número de réplicas que queremos de nosso arquivo values.yaml , do campo intitulado replicaCount . Em seguida, vemos que puxamos o nome do nosso contêiner, diretamente do nome do gráfico, com {{ .Chart.Name }}. Portanto, podemos extrair valores não apenas do arquivo values.yaml , mas também de outras partes da estrutura do gráfico.

Podemos ver que algumas coisas começam com letras maiúsculas enquanto outras com letras minúsculas. Existe uma convenção de que os valores internos do Helm começam com letras maiúsculas. É por isso que temos .Chart.Name e não .Chart.name . O nome do gráfico é embutido/estático, não escolhido pelo usuário. Mas o replicaCount in .Values.replicaCount é algo que um usuário escolheu em seu arquivo values.yaml , por isso começa com uma letra minúscula.

Podemos usar várias diretivas de modelo em uma única linha, como veremos a seguir. Na linha, image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"extraímos o nome de nossa imagem de valores aninhados definidos pelo usuário em nosso arquivo values.yaml .

Para ter uma ideia de quais valores são buscados aqui, veja um exemplo das partes relevantes do arquivo values.yaml .

```yaml
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.16.0"
```

Com essa linha em nosso deployment.yaml e os valores definidos em values.yaml, o Helm passará isso por seu mecanismo de modelagem e, finalmente, gerará uma linha como image: "nginx:1.16.0"no manifesto final que será enviado ao Kubernetes, ao instalar este gráfico.

Vamos criar o arquivo values.yaml e ver tudo isso em ação. Primeiro, vamos voltar a um diretório, para colocar o arquivo em seu local apropriado.

Removeremos o arquivo de valores de amostra que foi gerado pelo helm createcomando.

E vamos criar nosso próprio arquivo. Copie e cole o seguinte conteúdo e salve o arquivo:

```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.16.0"
```

Certificando-se de que nosso gráfico está funcionando como pretendido
Vamos voltar um diretório para que possamos passar nosso gráfico corretamente para o próximo comando do Helm.

Então, como podemos ter certeza de que nosso gráfico está realmente fazendo o que deveria fazer? Existem várias maneiras de verificarmos. Em primeiro lugar, queremos ter certeza de que o material de modelagem que adicionamos no deployment.yaml está realmente gerando o que esperamos no manifesto final (analisado) que ele enviará ao Kubernetes. Podemos verificar o que seria gerado, com este comando:

helm template ./nginx

Essa saída nos mostra o que cada arquivo .yaml de modelo geraria e tudo parece correto; os valores que definimos em values.yaml foram selecionados e usados ​​por nosso arquivo de modelo deployment.yaml .

```yaml
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
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

Para verificar se o gráfico está definido corretamente, também podemos usar este comando:

helm lint ./nginx

Os arquivos exatos do problema são indicados, tornando a depuração muito mais fácil. Nesse caso, nenhum problema é encontrado, pois eles são marcados com ERROR em vez de INFO . Adicionar um ícone ao nosso gráfico é apenas uma recomendação, para torná-lo mais facilmente identificável com essa representação gráfica.

```markdown
==> Linting ./nginx
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

Antes de realmente instalar isso, podemos fazer o que é chamado de simulação . Isso apenas finge instalar o pacote no cluster e pode capturar coisas que o Kubernetes reclamaria em uma instalação real.

helm install --dry-run my-nginx-release ./nginx

Por exemplo, se os objetos não estiverem bem definidos, o Kubernetes pode gerar erros como estes:

```bash
user@debian:~$ helm install --dry-run my-nginx-release ./nginx

Error: unable to build kubernetes objects from release manifest: error validating "": error validating data: ValidationError(Deployment.spec.template): unknown field "containers" in io.k8s.api.core.v1.PodTemplateSpec
```

Mas no nosso caso, tudo está OK, então vemos essa saída, mais uma vez nos mostrando os manifestos (definições de nosso(s) objeto(s) que seriam implantados no Kubernetes.




