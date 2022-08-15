Como os administradores precisavam gerenciar cada vez mais objetos do Kubernetes em seus clusters para executar seus aplicativos e infraestrutura, surgiu uma necessidade natural de algo para gerenciar toda essa complexidade. Assim, o projeto chamado Helm apareceu sob o guarda- chuva da CNCF (Cloud Native Computing Foundation). Desde o lançamento inicial em 2016, o projeto amadureceu e ficou cada vez melhor. As melhorias também foram possibilitadas pelo fato de que o próprio Kubernetes estava melhorando, então o Helm tinha mais ferramentas à sua disposição que poderia alavancar diretamente do Kubernetes

Não há mais Helm

Quando o Helm 2 existia, o Kubernetes não possuía recursos como controle de acesso baseado em função e definições de recursos personalizados. Para permitir que o Helm faça sua mágica, um componente extra, chamado Tiller, teve que ser instalado no cluster Kubernetes. Portanto, sempre que você deseja instalar um gráfico Helm, você usa o programa Helm (cliente) instalado em seu computador local. Isso se comunicou com o Tiller que estava sendo executado em algum servidor. Tiller, por sua vez, se comunicou com o Kubernetes e passou a agir para que o que você solicitasse acontecesse. Então, Tiller era o intermediário, por assim dizer.


Além do fato de que um componente extra entre você e o Kubernetes adiciona complexidade, também havia algumas preocupações de segurança. Por padrão, o Tiller estava sendo executado no “modo Deus” ou, dito de outra forma, tinha privilégios para fazer o que quisesse. Isso foi bom, pois permitiu fazer as alterações necessárias em seu cluster Kubernetes para instalar seus gráficos. Mas isso era ruim, pois permitia que qualquer usuário com acesso Tiller fizesse o que quisesse no cluster.

Depois que coisas legais como controle de acesso baseado em função (RBAC) e definições de recursos personalizados apareceram no Kubernetes, a necessidade do Tiller diminuiu, então ele foi removido inteiramente no Helm 3. Agora não há nada entre o Helm e o cluster.

Ou seja, quando você usa o programa Helm em seu computador local, ele se conecta diretamente ao cluster (servidor da API Kubernetes) e começa a fazer sua mágica.

Além disso, com o RBAC, a segurança é muito melhorada e qualquer usuário pode ser limitado no que pode fazer com o Helm. Antes você tinha que definir esses limites no Tiller e essa não era a melhor opção. Mas com o RBAC construído desde o início para ajustar as permissões do usuário no Kubernetes, agora é simples de fazer. No que diz respeito ao Kubernetes, não importa se o usuário está tentando fazer alterações no cluster com kubectl ou com comandos helm. O usuário que solicita as alterações tem as mesmas permissões permitidas pelo RBAC, independentemente da ferramenta que usar.

Patch de mesclagem estratégica de três vias

Agora, esta é provavelmente uma mudança mais importante do que discutimos antes com Tiller.

O nome pode parecer intimidante, mas não se preocupe, no final desta seção veremos que é realmente simples, mas uma coisa muito inteligente que pode ser bastante útil.

O Helm tem algo como um recurso de instantâneo. Aqui está um exemplo:

Você pode usar um gráfico para instalar um site WordPress completo. Isso criará a revisão número 1 para esta instalação. Então, se você alterar algo, por exemplo, atualizar para um gráfico mais recente para atualizar sua instalação do WordPress, chegará à revisão número 2. Essas revisões podem ser consideradas algo como snapshots, o estado exato de um pacote Kubernetes naquele momento em Tempo. Se houver necessidade, você pode retornar à revisão número 1, fazer uma reversão. Isso colocaria seu pacote/aplicativo no mesmo estado em que você instalou seu gráfico pela primeira vez.

Novas revisões são criadas sempre que mudanças importantes são feitas com o comando Helm. Por exemplo, quando instalamos um pacote, uma revisão é criada. Quando atualizamos esse pacote, uma nova revisão aparece. Mesmo quando revertemos, uma nova revisão é criada.

Isso não é como um recurso típico de backup/restauração, no sentido de que você não recupera dados antigos. Se você excluiu um banco de dados em um volume persistente, isso não restaura o volume persistente com os dados antigos. O que isso faz é trazer todos os objetos do Kubernetes de volta ao seu estado antigo, suas declarações antigas, como estavam no momento em que a revisão foi criada.


Outra maneira de pensar sobre isso é que uma reversão restaura praticamente tudo de volta ao que era, EXCETO para dados persistentes. Os dados persistentes devem ser copiados com métodos regulares.

O Helm 2 era menos sofisticado quando se tratava de como fazia essas reversões. Para entender o que estava faltando, a página de documentação oficial nos dá este exemplo:

Você instala um gráfico. Isso cria a revisão número 1 e contém uma implantação com 3 réplicas. Mas alguém, por algum motivo, reduz o número de réplicas para 0, com um comando como:

kubectl scale --replicas=0 deployment/myapp
Agora, isso não cria uma nova revisão, pois não foi um comando de atualização, instalação ou reversão do leme. Foi apenas uma mudança “manual” feita sem o Helm.

Mas ainda temos a revisão 1 disponível, com o estado original. Portanto, não há problema, pensamos, apenas voltamos ao original:

helm rollback myapp
Mas o Helm 2 compara o gráfico usado atualmente com o gráfico para o qual queremos reverter. Como esta é a instalação original, revisão 1, e queremos reverter para a revisão 1, o gráfico atual e o gráfico antigo são idênticos. Não alteramos nenhum gráfico, apenas editamos manualmente um pequeno objeto do Kubernetes. O Helm 2 considera que nada deve ser alterado para que nada aconteça. A contagem de réplicas permanece em 0.

O Helm 3, por outro lado, é mais inteligente. Ele compara o gráfico para o qual queremos reverter, o gráfico atualmente em uso e também o estado ativo ( como nossos objetos do Kubernetes se parecem atualmente, suas declarações no formato .yaml ). É daí que vem o nome chique de "Patch de mesclagem estratégico de três vias ". Ao observar também o estado ativo, ele percebe que a contagem de réplicas do estado ativo está em 0, mas a contagem de réplicas na revisão 1 para a qual queremos reverter está em 3, portanto, faz as alterações necessárias para voltar ao estado original.

Além de reversões, também há coisas como atualizações a serem consideradas, onde o Helm 2 também estava faltando. Por exemplo, digamos que você instale um gráfico. Mas então você faz algumas alterações em alguns dos objetos do Kubernetes instalados. Tudo funciona bem até você realizar uma atualização. O Helm 2 examina o gráfico antigo e o novo gráfico para o qual você deseja atualizar. Todas as suas alterações serão perdidas, pois não existem no gráfico antigo ou no novo gráfico. Mas o Helm 3, como mencionado, analisa os gráficos e também o estado ao vivo. Ele percebe que você adicionou algumas coisas próprias para que ele execute a atualização enquanto preserva qualquer coisa que você possa ter adicionado.


Você pode visitar o link para uma explicação mais detalhada .

O que foi mencionado acima são provavelmente as maiores mudanças no Helm 3. Existem algumas outras mudanças menores, mas elas não afetam realmente como você trabalhará com a versão mais recente do Helm, especialmente se você for um novo usuário.