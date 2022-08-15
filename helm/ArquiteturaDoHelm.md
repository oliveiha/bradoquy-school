O Helm tem vários componentes com os quais trabalharemos. Então, vamos dar uma olhada em sua estrutura geral, conceitos e as peças com as quais trabalharemos.

Arquivo binário do Helm (executável/programa do Helm)
O arquivo binário é o arquivo executável, o programa que usamos em nossos computadores para instruir o Helm a fazer sua mágica em nosso cluster Kubernetes. Usamos isso em comandos como:

helm install my-wordpress-site bitnami/wordpress
Com tal comando estamos realmente executando o arquivo chamado helm . Quando isso é executado, ele analisa quais parâmetros passamos para ele. Então, neste caso, parece que queremos “instalar” algo, chamá-lo de my-wordpress-site e usar o gráfico localizado em bitnami/wordpress .

Charts de Helm
Os gráficos são uma coleção de arquivos. E eles contêm todas as instruções que o Helm precisa para saber como criar a coleção de objetos que você precisa em seu cluster Kubernetes. Ao usar esses gráficos e adicionar os objetos de acordo com as instruções específicas nos gráficos, o Helm, de certa forma, instala “apps” em seu cluster. Claro, esses não são aplicativos no sentido convencional, como aplicativos em seu telefone, mas geralmente são semelhantes em escopo: uma coleção de objetos que trabalham juntos para realizar algum tipo de tarefa.

values.yaml
Em um gráfico do Helm, muitas vezes estaremos interagindo com um arquivo especial. Veja bem, na maioria das vezes não precisaremos construir os gráficos nós mesmos. Temos centenas deles já disponíveis para download. Mas o que quase sempre precisaremos fazer, ou queremos fazer, é configurar o pacote que instalamos através desse gráfico.

Considere o exemplo acima, usando o Helm para instalar um site WordPress, com um gráfico que baixamos do Bitnami. Podemos abrir o arquivo values.yaml e configurar alguns parâmetros importantes nele. Por exemplo, podemos escolher o nome de usuário do administrador do nosso site, a senha, o nome do blog e assim por diante. Os gráficos virão com muitos valores padrão já pré-configurados. Mas ter esse arquivo por perto nos dá uma localização central onde podemos encontrar e editar rapidamente as configurações com as quais este aplicativo será instalado, de acordo com nossos gostos e necessidades. Quando o Helm usa o gráfico, ele dá uma olhada nos valores que colocamos lá e configura a versão com esses parâmetros.

Assim, podemos considerar que values.yaml é como um arquivo de configurações para as versões que instalamos com base nesse gráfico.

Releases de Helm
Quando um gráfico é aplicado ao seu cluster, uma versão é criada. Poderíamos nos perguntar, por que a necessidade de um item adicional? Por que não podemos simplesmente dizer que instalamos um gráfico no Kubernetes?

No comando

helm install my-wordpress-site bitnami/wordpress
usamos o gráfico em bitnami/wordpress e nomeamos o lançamento como my-wordpress-site .

Então, por que não usar um comando mais curto como helm install bitnami/wordpresse pronto? Sem nome de lançamento. Bem, uma razão simples pela qual faz mais sentido ter lançamentos baseados em gráficos é que podemos instalar vários lançamentos baseados no mesmo gráfico. Assim, podemos lançar um segundo site WordPress com um comando como:

helm install my-SECOND-wordpress-site bitnami/wordpress
E como são dois lançamentos diferentes, eles podem ser rastreados separadamente e alterados independentemente. Embora sejam baseados no mesmo gráfico, como lançamentos, são duas entidades totalmente diferentes.


Isso pode ser útil em muitos cenários. Por exemplo, você pode ter uma versão para um site WordPress que seus clientes usam e outra versão para um site WordPress que é visível apenas para sua equipe interna de desenvolvedores. Lá, eles podem experimentar e adicionar novos recursos sem quebrar o site principal. Como os dois lançamentos são baseados no mesmo gráfico, assim que conseguirem algo funcionando corretamente no site de desenvolvimento, podem transferi-lo para o site principal, pois deve funcionar exatamente da mesma forma, pois os dois sites são basicamente clones, construídos da mesma forma maneira.

Repositórios de Helm
Assim como podemos encontrar todos os tipos de projetos disponíveis gratuitamente no GitHub, podemos encontrar gráficos Helm em repositórios públicos. Por exemplo, no repositório https://artifacthub.io/ , muitas vezes você encontrará o que está procurando e, às vezes, os gráficos são publicados pelo próprio desenvolvedor desse projeto. Você verá os selos de editor oficial ou verificado nesses casos, e é preferível usá-los quando disponíveis.


No comando que continuamos oferecendo como exemplo acima, bitnami é o nome do repositório e wordpress é o nome do gráfico, então acabamos com bitnami/wordpress para especificar o repositório e o gráfico que queremos extrair de uma fonte online.

Metadados (dados sobre dados)
Para acompanhar o que ele fez em nosso cluster, as versões instaladas, os gráficos usados, os estados de revisão e assim por diante, o Helm precisará de um local para salvar esses dados. Agora não seria muito útil se salvasse isso em nosso computador local. Se outra pessoa precisasse trabalhar com nossos lançamentos, por meio do Helm, ela precisaria de uma cópia de nossos próprios dados. Então, em vez disso, o Helm faz a coisa inteligente e salva esses metadados diretamente em nosso cluster Kubernetes, como segredos do Kubernetes. Dessa forma, os dados sobrevivem, desde que o cluster Kubernetes sobreviva e todos da nossa equipe possam acessá-los, para que possam fazer atualizações de leme ou o que precisarem. Assim, o Helm sempre saberá sobre tudo o que fez neste cluster e poderá acompanhar todas as ações, todas as etapas do caminho, pois sempre tem seus metadados disponíveis.