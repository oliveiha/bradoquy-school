Atualizando versões com o Helm
Agora , o gerenciamento do ciclo de vida pode soar como um termo técnico sofisticado que é abstrato demais para ser entendido à primeira vista. Então, vamos traduzir em inglês simples, dando uma olhada em exemplos práticos. 

Cada vez que puxamos um gráfico e o instalamos, uma versão é criada. Uma versão é um pouco semelhante a um aplicativo, mas, mais especificamente, representa um pacote ou uma coleção de objetos do Kubernetes. Como o Helm sabe quais objetos do Kubernetes pertencem a cada versão, ele pode fazer coisas como upgrades, downgrades ou desinstalações, sem tocar em objetos que possam pertencer a outras versões. Assim, cada versão pode ser gerenciada de forma independente, mesmo que todas sejam baseadas no mesmo gráfico.

Vamos apenas criar uma nova versão e discutir isso à medida que avançamos. Vamos instalar uma versão bem antiga deste gráfico.

helm install nginx-release bitnami/nginx --version 7.1.0

Agora temos uma versão do Nginx, simplesmente chamada nginx-release . Agora imagine 2 meses se passando. Isso é muito tempo para qualquer software, mas especialmente para um site. Muitas vulnerabilidades de segurança são descobertas e precisam ser corrigidas.

Nosso site hospedado no Nginx pode ter muitos objetos em nosso cluster Kubernetes. Quando atualizamos os pods executando o Nginx, talvez também precisemos fazer algumas alterações em outros objetos do Kubernetes. Mas pode ser difícil acompanhar todas as peças que precisam ser alteradas. Felizmente, como dissemos, o Helm acompanha tudo associado a um lançamento. Portanto, não precisamos atualizar nossos objetos um por um. O Helm pode atualizar todos eles automaticamente, com um único comando.

Mas primeiro, vamos ver qual versão do Nginx está sendo executada em nosso pod. Inicialmente, temos que descobrir o nome do nosso pod Nginx.


helm upgrade nginx-release bitnami/nginx

No processo de atualização, o pod antigo é destruído e um novo é criado, então precisaremos obter o nome do novo.

Você pode ver como temos uma versão mais recente em execução aqui.

Então, aí está, acabamos de passar pelo chamado Gerenciamento do Ciclo de Vida com o Helm . Uma versão pode existir por meses ou anos. O Helm pode gerenciar seu ciclo de vida de várias maneiras, acompanhando seu estado atual, estados anteriores e trazendo-o para estados futuros. Então, neste caso, trouxemos o lançamento para um estado futuro, atualizando-o. Mas Helm também manteve um registro do estado anterior. Notamos que o número da revisão mudou para “2”, então o estado anterior seria a revisão “1”. Agora, como isso nos ajuda?


Revertendo lançamentos com o Helm
Se dermos uma olhada em nossos lançamentos:

helm list

helm history nginx-release

Podemos ver claramente muitas coisas úteis:

Qual versão do gráfico foi/é usada em cada revisão.
Qual versão do aplicativo foi/é usada em cada revisão.
Que ação realmente criou essa revisão. Foi uma instalação, uma atualização, uma reversão?
Portanto, isso mostra uma imagem clara dos estágios pelos quais nosso lançamento passou, seu histórico de ciclo de vida.

Agora vamos supor que esta atualização fez algo que não gostamos. O gerenciamento do ciclo de vida do Helm permite outra coisa legal chamada rollback . Isso nos permite retornar uma versão a um estado anterior. Então, neste caso, queremos retornar à revisão 1.

helm list

helm history nginx-release

helm rollback nginx-release 1

helm history nginx-release

vemos a versão antiga do Nginx restaurada.

E o Helm também registrou essa mudança no estado do lançamento.

Vale a pena mencionar que escolhemos o Nginx aqui, pois é simples de atualizar. Mas haverá pacotes do Kubernetes que podem exigir algumas etapas extras para atualizar. Por exemplo, se tivéssemos tentado atualizar a versão anterior do WordPress que criamos, teríamos esta saída:

Agora, isso não quer dizer que isso seja um problema. Ele pode ser facilmente resolvido adicionando mais alguns parâmetros à linha de comando, conforme instruído no texto. Por que isso acontece? Nesse caso, o Helm não pode atualizar tudo sem ter acesso a algumas senhas administrativas. Ele precisa de acesso administrativo ao banco de dados e ao próprio site WordPress para que possa obter as permissões para fazer as alterações necessárias.

Também vale a pena mencionar que, embora os rollbacks sejam muito semelhantes a um recurso de backup/restauração, ele não abrange dados de arquivos/diretórios que possam ser criados por nossos aplicativos. Em vez disso, o Helm faz backup e restaura as declarações/manifestos de nossos objetos Kubernetes. Portanto, para coisas que usam volumes persistentes ou outras formas de dados persistentes, uma reversão também não restaurará esses dados. Por exemplo, imagine que você reverte um servidor de banco de dados MySQL. Os pods MySQL serão restaurados para seus estados anteriores, versões de software usadas e assim por diante, mas o banco de dados real, seus dados, permanecerão os mesmos.

