Usando a ajuda integrada do Helm
Primeiro, precisamos saber: O que podemos fazer com o comando Helm? . E é aqui que a ajuda integrada é muito útil.

Para começar e ter uma ideia dos (sub)comandos que ele suporta, podemos digitar

helm --help

Isso pode servir como uma maneira rápida de lembrar qual é o comando certo para fazer algo. Por exemplo, digamos que queremos restaurar um lançamento para uma versão anterior, após uma atualização com falha. Podemos nos perguntar: Espere, qual foi o comando para fazer isso? restauração do leme? . E então vemos nesta lista que o comando correto é na verdade a reversão do leme . É muito mais rápido do que procurar a resposta na Internet, pois é imediatamente acessível a partir da linha de comando.

Também podemos usar esse recurso de ajuda para subcomandos. Por exemplo, se quisermos ver quais ações relacionadas ao repositório podemos realizar

helm repo --help
E podemos ainda aprofundar e aprender sobre o que um sub-subcomando faz e quais parâmetros ele suporta:

helm repo update --help

Depois de usar a ajuda interna do Helm algumas vezes, será fácil memorizar os comandos corretos para todas as ações que você normalmente precisa.

Procurando gráficos de leme no ArtifactHub.io
Então vamos supor que estamos em um cenário onde precisamos lançar um site WordPress no Kubernetes. Fazer isso sem o Helm, embora não seja muito difícil, ainda envolve muitas outras etapas. Você pode conferir um exemplo aqui: https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/. Podemos ver que é uma longa lista de ações que precisamos tomar. Precisamos criar cada objeto do Kubernetes, um por um, até que todos os componentes estejam prontos. Precisaremos de volumes persistentes para armazenar o banco de dados. Precisaremos definir um serviço para expor o site ao mundo exterior. Em seguida, precisamos definir objetos de implantação para iniciar nossos pods que realmente executam o banco de dados MySQL e os aplicativos do servidor web Apache. Agora vamos ver como é mais fácil fazer isso com o Helm.

Primeiro precisamos encontrar um gráfico para a estrutura do WordPress que queremos. Na verdade, podemos usar o próprio comando helm para procurar por isso:

helm search hub wordpress
Mas isso é um pouco limitado. Não podemos ver muito sobre como eles são construídos e o que exatamente eles contêm. Na verdade, existem comandos (por exemplo, helm show readme bitnami/wordpress) para obter mais detalhes sobre um gráfico, diretamente na janela do seu terminal, mas é um pouco difícil de ler neste ambiente restrito. Assim, podemos visitar este mecanismo de pesquisa que lista todos os tipos de recursos do Kubernetes e, o que nos interessa, os repositórios que contêm os gráficos de que precisamos: https://artifacthub.io/ .

Com software, em geral, especialmente o que usamos em um ambiente comercial/corporativo, sempre há a questão de Podemos confiar neste código? É não malicioso? É de boa qualidade? Para garantir um gráfico de alta qualidade, podemos tentar encontrar um que tenha o selo de editor oficial ou verificado. Se clicarmos neste resultado, veremos uma página detalhada com todas as informações que podemos querer saber sobre este gráfico. Ele começa com os comandos exatos que precisamos usar para instalar o gráfico em nosso cluster Kubernetes, continua com os componentes de software que ele usa e, mais abaixo na página, podemos até ver algumas das configurações configuráveis ​​mais importantes que podemos ajustar. Cabe aos desenvolvedores de gráficos mencionar o que eles acham importante na página de descrição.

Como implantar um gráfico de leme
Haverá casos em que os pacotes que instalamos com o Helm não requerem ajustes, e podemos apenas colocá-los em funcionamento com dois comandos simples helm repo adde . helm installVamos supor que nosso aplicativo WordPress se encaixa nesse cenário e instalá-lo em nosso cluster Kubernetes.

Primeiro, informamos ao Helm sobre esse novo repositório de gráficos que queremos usar:

helm repo add bitnami https://charts.bitnami.com/bitnami
Dessa forma, ele saberá o endereço de onde poderá obter os gráficos de que precisaremos.

Chamamos esse repositório de bitnami . Podemos escolher qualquer nome que quisermos, após o comando add, mas precisaremos usar esse mesmo nome ao instalar nosso gráfico.

Vale a pena mencionar aqui que, de tempos em tempos, também queremos usar este comando:

helm repo update
Isso é um pouco equivalente ao que um sudo apt-get updatecomando faz em alguns sistemas operacionais baseados em Linux. Em poucas palavras, as informações que o Helm tem sobre esse repositório são armazenadas localmente. Com o tempo, os mantenedores do repositório fazem alterações, atualizam coisas e assim por diante, então nossa cópia local dessas informações fica obsoleta, desatualizada. O comando acima atualiza as informações que o Helm possui, puxando-as do repositório online para o nosso computador local. Desta forma, obtemos os dados mais recentes disponíveis.
Finalmente, podemos instalar nosso gráfico WordPress. Observe como usamos o mesmo nome que escolhemos para o repositório que adicionamos anteriormente. bitnami/wordpress no próximo comando é basicamente uma maneira de dizer, instale o gráfico chamado WordPress do repositório que chamamos de bitnami .

helm install my-release bitnami/wordpress
E bum! Com um único comando, o Helm faz todo o trabalho pesado e está preparando tudo nos bastidores. No final, até obtemos algumas informações úteis sobre como podemos usar esta instalação do WordPress.

user@debian:~$ helm install my-release bitnami/wordpress
NAME: my-release
LAST DEPLOYED: Wed Jun 30 17:26:36 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
** Please be patient while the chart is being deployed **

Your WordPress site can be accessed through the following DNS name from within your cluster:

    my-release-wordpress.default.svc.cluster.local (port 80)

To access your WordPress site from outside the cluster follow the steps below:

1. Get the WordPress URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace default -w my-release-wordpress'

   export SERVICE_IP=$(kubectl get svc --namespace default my-release-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
   echo "WordPress URL: http://$SERVICE_IP/"
   echo "WordPress Admin URL: http://$SERVICE_IP/admin"

2. Open a browser and access WordPress using the obtained URL.

3. Login with the following credentials below to see your blog:

  echo Username: user
  echo Password: $(kubectl get secret --namespace default my-release-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)

Este texto é realmente gerado por instruções incluídas no gráfico. Dessa forma, os usuários têm uma ideia de como podem continuar com o pacote Kubernetes recém-instalado. Aprenderemos como podemos fazer o mesmo (gerar saída no final da instalação) com os gráficos que construímos.

Agora, se você quiser realmente ver se o site do WordPress está realmente em execução, depende de onde seu cluster Kubernetes está hospedado. Normalmente, você pode apenas seguir as instruções em seu terminal e acessar o WordPress através do IP externo exibido neste comando:

kubectl get svc --namespace default my-release-wordpress
Mas se depois que você deu ao Helm alguns minutos para instalar tudo, você ainda obtiver a saída mostrando o EXTERNAL-IP em um estado pendente , talvez você não tenha essa opção disponível pronta para uso. Por exemplo, isso pode acontecer se você estiver executando seu cluster localmente, com Minikube . No Minikube , uma solução rápida é abrir outra janela de terminal e usar este comando:

minikube tunnel
Você precisará fornecer uma senha de usuário sudo em alguns segundos. Deixe a janela do terminal aberta, pois isso precisa continuar sendo executado em segundo plano.

Retorne à sua janela de terminal antiga e digite

kubectl get svc --namespace default my-release-wordpress
novamente até ver um EXTERNAL-IP listado. Digite isso na barra de endereços do seu navegador e voila, podemos ver que o Helm realmente fez toda a sua mágica e instalou um aplicativo complexo para nós em nosso cluster, sem muito esforço de nossa parte.

Bem fácil, certo? Basicamente, usamos apenas dois comandos para instalar um site WordPress complexo que precisa de muitos objetos do Kubernetes para começar a funcionar.

Se você usou o comando minikube tunnel, volte para a janela do terminal, pressione CTRL+C e feche a janela.

Excluindo liberação
Agora queremos remover todos os vestígios deste aplicativo. Imagine fazer isso manualmente . Teríamos que excluir muitos objetos do nosso cluster, um por um, para nos livrarmos de todos os componentes relacionados ao WordPress. Mas com o Helm, isso é feito facilmente com um único comando.

Para ver todas as versões instaladas:

helm list
Isso é muito útil, não apenas para rastrear o que foi instalado, mas também para ver o que não é atualizado há muito tempo.

Como agora temos o nome da versão, podemos remover todos os objetos Kubernetes adicionados por este site WordPress, com um simples comando.

helm uninstall my-release
Novamente, muito fácil. Podemos realmente começar a ver o poder do Helm como gerenciador de pacotes para Kubernetes.

Personalizando os parâmetros do gráfico no momento da instalação
Para simplificar, passamos por um exemplo de como instalar um gráfico Helm com suas configurações padrão. Normalmente, os gráficos oferecem várias maneiras para os usuários especificarem suas próprias configurações desejadas, editando um arquivo values.yaml especial ou fornecendo as preferências desejadas na linha de comando. Mas os gráficos são construídos de forma inteligente, de modo que, se o usuário não especificar nenhuma preferência, os valores padrão serão usados.

Com alguns aplicativos mais simples, às vezes usaremos os padrões, pois não há muitas coisas interessantes que possamos querer ajustar, e os padrões gerais são bons o suficiente. Mas no caso de algo como o WordPress, pode ser útil escolher algumas configurações personalizadas que desejamos, antes que tudo seja instalado. O WordPress é um aplicativo muito complexo, com centenas de configurações personalizáveis, desde coisas simples, como título do site, até coisas relacionadas à segurança, como senha de administrador ou certificado TLS, que seriam usados ​​para fornecer conexões HTTPS aos visitantes do site. Claro, há também a opção de ajustar essas configurações mais tarde, a partir da interface de administração do WordPress, ou, com comandos kubectl para editar objetos Kubernetes. No entanto, é muito útil saber como podemos personalizar nossos lançamentos do Helm, no momento da instalação.

1. Especificando nossos parâmetros personalizados diretamente na linha de comando
Se houver apenas algumas coisas que queremos personalizar, podemos apenas especificar nossos valores personalizados desejados diretamente na linha de comando, adicionando --setparâmetros. Por exemplo, este gráfico nos permite especificar o título do nosso site WordPress. Poderíamos usar um comando como este para escolher um título específico:

helm install --set wordpressBlogName="Helm Tutorials" my-release-2 bitnami/wordpress
Se precisarmos especificar vários valores personalizados para nosso gráfico, basta usar o --setparâmetro várias vezes.

helm install --set wordpressBlogName="Helm Tutorials" --set wordpressEmail="john@example.com" my-release-3 bitnami/wordpress
2. Criando um arquivo “values.yaml” onde especificamos todos os nossos valores personalizados desejados.

Quando há muitos valores que queremos definir, usar 30 parâmetros –set em um único comando tornaria muito longo, tedioso de escrever e simplesmente feio de olhar, para não mencionar difícil de editar se precisarmos reinstalar nosso aplicativo com configurações diferentes. Então, a maneira mais limpa é criar um arquivo onde listamos os valores que queremos definir.

Vamos criar este arquivo:

nano values.yaml
Neste arquivo, em vez de especificar um valor na forma de wordpressBlogName="Helm Tutorials", usaremos uma notação diferente. Adicione este conteúdo ao arquivo values.yaml .

wordpressBlogName: Helm Tutorials 
wordpressEmail: john@example.com

Estamos basicamente usando “:” em vez de “=” e adicionando um espaço após esses “:” para definir o valor que desejamos.

Pressione CTRL+X, y e ENTER para salvar este arquivo.

Então, como dizemos ao Helm para usar esses valores personalizados ao instalar o gráfico? Adicionando o parâmetro de linha de comando –values ​​e especificando o caminho para nosso arquivo values.yaml .

helm install --values values.yaml my-release-4 bitnami/wordpress
3. Fazer download de todo o gráfico localmente e editar o arquivo values.yaml incluído

Esse método geralmente é recomendado se realmente quisermos nos aprofundar na personalização do aplicativo que instalamos com este gráfico. E tem uma grande vantagem. Gráficos complexos e desenvolvidos profissionalmente têm muitos comentários dentro do arquivo values.yaml, o que nos ajuda a entender melhor o que podemos mudar e qual seria o efeito. Vamos a um exemplo.

Podemos baixar um gráfico com este comando:

helm pull --untar bitnami/wordpress
Normalmente, o gráfico seria baixado em um formato arquivado (chamado arquivo TAR). Mas o --untarparâmetro que adicionamos extrai automaticamente o conteúdo deste arquivo.

Veja como parte do arquivo values.yaml se parece

wordpressUsername: user
## @param wordpressPassword WordPress user password
## Defaults to a random 10-character alphanumeric string if not set
##
wordpressPassword: ""
## @param existingSecret Name of existing secret containing WordPress credentials
## NOTE: Must contain key `wordpress-password`
## NOTE: When it's set, the `wordpressPassword` parameter is ignored
##
existingSecret:
## @param wordpressEmail WordPress user email
##
wordpressEmail: user@example.com
## @param wordpressFirstName WordPress user first name
##
wordpressFirstName: FirstName
## @param wordpressLastName WordPress user last name
##
wordpressLastName: LastName
## @param wordpressBlogName Blog name
##
wordpressBlogName: User's Blog!

Podemos editar tudo o que quisermos aqui e, quando terminarmos, salve o arquivo e use este comando:

helm install my-release-5 ./wordpress