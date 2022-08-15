Imagine que temos um gráfico Helm para WordPress instalado. Nosso site WordPress usaria o servidor web Apache e o servidor de banco de dados MySQL ou MariaDB nos bastidores, além dos próprios arquivos do WordPress, que contêm o código do nosso site. É uma estrutura bastante complexa, onde todas as peças precisam se encaixar perfeitamente para garantir que o site funcione sem problemas. A maioria das atualizações deve ocorrer sem problemas, mas não é uma garantia. Depois de executar um helm upgrade, podemos notar que nosso site misteriosamente para de funcionar. Mas Helm, ser tão bom em automação nos fornece mais uma ferramenta que podemos usar. Com o que é chamado de Hook de gráfico, podemos fazer com que o Helm execute automaticamente algumas ações em determinados pontos. Por exemplo, neste caso, poderíamos usar um hook de gráfico para fazer o Helm fazer backup automático do banco de dados do WordPress antes do helm upgrade começa a fazer o seu trabalho. Agora, se algo der errado, temos uma maneira fácil de restaurá-lo.

Podemos definir Hooks do Helm que serão executados nestes pontos do ciclo de vida do lançamento:

pré-instalação – Antes da versão ser instalada.
pós-instalação – Depois que a versão é instalada
pre-delete – Antes que a versão seja desinstalada.
post-delete – Após a desinstalação da versão.
pré-atualização – antes que a versão seja atualizada.
post-upgrade – Depois que a versão é atualizada.
pre-rollback – antes do lançamento ser revertido para uma versão anterior.
post-rollback – Após o lançamento ser revertido para uma versão anterior.

Por exemplo, quando um Hook de pré-instalação é usado, algo assim acontece:

O usuário digita um comando como: helm install my-website ./nginx
O Helm começa a renderizar os arquivos de modelo, MAS
Os manifestos finais ainda NÃO foram enviados ao Kubernetes
Em vez disso, o Hook de pré-instalação é executado, com as ações definidas no gráfico. Por exemplo, um Hook de pré-instalação pode simplesmente criar um objeto Kubernetes. Pode ser um objeto do tipo Job que executa algum tipo de ação no Kubernetes. Ou pode ser um contêiner simples que faz alguma coisa.
Após a execução do hook de pré-instalação, nosso gráfico finalmente é instalado , o que significa que o que quer que o Helm tenha renderizado, neste ponto ele envia os manifestos para o Kubernetes e nossos objetos são instalados.


Com um hook pós-instalação , é fácil imaginar que a única coisa que muda é que o hook é executado APÓS o gráfico instalar todos os seus objetos renderizados no Kubernetes.

É fácil imaginar que a história é semelhante ao usar um hook pré/pós-atualização ou um pré/pós-reversão . O hook é executado antes que o comando faça suas operações normais ou depois. Quando usaríamos um ou outro depende do que estamos tentando alcançar. Por exemplo, podemos usar um hook de pré-atualização para fazer backup de um banco de dados e um hook de pós-atualização para verificar se nosso site ainda funciona após a atualização.

Vale ressaltar que o Helm aguardará até que o hook termine sua execução. Além disso, se algo como um hook de pré/pós-instalação falhar, toda a operação falhará. O que, neste caso, significaria que a instalação do lançamento falharia completamente (ou mais precisamente, é abandonada desde que o hook falhou).

Como escrever um hook de gráfico
Hooks são arquivos de templates comuns que podemos adicionar ao diretório templates/ como fizemos até agora em nossos exercícios. O que os torna especiais é annotation que adicionamos à seção metadata:. Aqui está um exemplo de tal anotação:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    {{- include "nginx.labels" . | indent 4 }}
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: {{ .Release.Name }}-nginx
      labels:
        {{- include "nginx.labels" . | indent 8 }}
    spec:
      restartPolicy: Never
      containers:
      - name: post-install-job
        image: "some-image:3.3"
        command: ["/bin/some-special-backup-command"]
```

Isso simplesmente define um hook pós-instalação que criaria um trabalho do Kubernetes para fazer algo em nosso cluster após o comando de instalação do helm ser bem- sucedido.

Se quisermos usar isso em nosso gráfico, criaremos um arquivo com um comando como nano ~/nginx/templates/do-something-post-install.yaml e colaremos o conteúdo acima nele. Mas não faremos isso, pois não geraria nenhum resultado prático interessante em nosso cenário. Em vez disso, vamos estudar como usar as anotações: seção.

A linha

"helm.sh/hook": post-install

é bem fácil de entender. Aqui definimos que tipo de hook é este, pós-instalação, pré-instalação, pós-reversão e assim por diante.

Certifique-se de que os hooks sejam executados em uma determinada ordem
Podemos ter vários hooks em um gráfico. Mesmo vários hooks do mesmo tipo. Por exemplo, poderíamos ter um hook de pré-atualização para fazer backup de nosso banco de dados e outro hook de pré-atualização para também fazer backup de nossos arquivos. Nesse caso, não importa realmente a ordem em que os hooks são executados. Mas imagine que o hook arquiva alguns arquivos e outro hook os carrega para algum serviço de nuvem que armazena backups de forma confiável. Nesse caso, é importante que os hooks sejam executados em uma ordem específica, primeiro os arquivos devem ser arquivados, e só depois podem ser carregados pelo outro hook. Então, como podemos garantir que eles sejam executados nesta ordem? Com pesos de hook.

"helm.sh/hook-weight": "-5"

Os pesos são números que podem ser negativos ou positivos e devem ser escritos como strings (certifique-se de que tem aspas

" " em torno do número). Se tivéssemos três hooks, com os pesos “-5”, “0” e “7”, primeiro o “-5” seria executado, depois “0” e finalmente “7” então é bem simples como esses trabalhar.

Excluir recursos criados por hooks
Quando você instala um gráfico, o Helm rastreia quais objetos seus arquivos de modelo adicionaram ao Kubernetes. Quando você desinstala o gráfico, o Helm remove automaticamente esses objetos. Mas no caso de hooks, o Helm não rastreia isso. Portanto, se um hook de pós-instalação criar um pod que fez alguma coisa, esse pod ainda será deixado após a conclusão da instalação do gráfico e mesmo se você remover o gráfico completamente posteriormente. Para excluir esses recursos automaticamente, podemos usar a anotação de política de exclusão.

Em nosso exemplo, usamos a linha:

"helm.sh/hook-delete-policy": hook-succeeded

Isso faria com que o Helm excluísse os recursos criados pelo hook, se e somente se o hook fosse bem-sucedido. Obviamente, isso significa que, se o hook falhar, os recursos não serão excluídos. Isso pode realmente ser útil, pois talvez queiramos depurar tal falha, ver o que deu errado, então é vantajoso que ainda tenhamos o recurso disponível. A política de exclusão é compatível com os seguintes valores:

before-hook-creation – Este é o comportamento padrão. O recurso é excluído quando o hook é executado. Na primeira vez que isso for executado, não haverá um recurso a ser excluído, então isso não importa. Mas digamos que um hook pós-atualização crie um objeto Kubernetes. Na próxima vez que atualizarmos, o hook pós-atualização excluirá o objeto antigo do Kubernetes que ficou suspenso após a última atualização. Depois que ele exclui o objeto antigo, o novo objeto é criado e isso também fica pendente até que o próximo comando de atualização seja executado. Isso também ajuda a evitar situações em que o hook tentaria criar um objeto duplicado, com o mesmo nome e o Kubernetes poderia reclamar que “Objeto/Recurso X já existe”.
hook-succeeded – Exclua o recurso se o hook for executado com sucesso.
hook-failed – Exclua o recurso se o hook falhar.

Também é possível usar várias políticas de exclusão. Nós apenas os enumeramos na mesma linha e separamos os valores com vírgulas ,. Aqui está um exemplo:

"helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded,hook-failed
Essa política excluiria os recursos criados pelo hook toda vez após a conclusão da execução.

