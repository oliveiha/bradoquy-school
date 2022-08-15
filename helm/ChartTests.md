Nem todos os clusters do Kubernetes são iguais. Um gráfico que funciona em um cluster pode não ser instalado corretamente em outro. Talvez esteja faltando um recurso necessário. Talvez não haja recursos suficientes. Ou talvez alguns objetos do Kubernetes que nosso gráfico cria não consigam se interconectar corretamente. Como não importa quão bom seja o gráfico, o sucesso não é garantido, o Helm suporta os chamados testes de gráfico . Esses testes podem ajudar um usuário de gráfico a certificar-se de que o pacote que ele acabou de instalar está totalmente funcional, funcionando corretamente.

Como de costume, vamos ver isso na prática, para entender melhor.

Construindo um teste de gráfico de leme
O teste que escreveremos para um gráfico é praticamente um arquivo de modelo regular e deve ser colocado no diretório templates/ . Mas o Helm precisa de uma maneira de saber que não é apenas um arquivo de modelo comum, mas, na verdade, um arquivo especial que só deve ser usado quando o usuário executar o comando helm test . Isso é feito facilmente adicionando a seguinte linha no conteúdo do arquivo, na metadataseção:

helm.sh/hook: test
Então, basicamente, estamos adicionando uma simples anotação de hook Helm aqui e isso é suficiente para dizer ao nosso utilitário o que é isso. Mas e o teste em si? Como isso deve ser construído?

Um teste deve descrever um contêiner. Isso, por sua vez, deve executar um comando que de alguma forma verifica se o gráfico instalado está funcionando bem. Para entender isso, devemos primeiro explorar um assunto diferente.

Entendendo os códigos de saída
Um comando, no Linux, normalmente retorna um código de saída . Isso geralmente não é exibido ao usuário, mas retornado silenciosamente ao programa que invocou o comando. Por exemplo, quando você executa

ls
para listar arquivos e diretórios, o comando ls retorna um código de saída. Então esse código de saída é retornado para quem se não o virmos? Ele é retornado ao seu processo pai, que neste caso é o shell Bash que nos permite inserir comandos e ver sua saída. No Bash, podemos ver o último código de saída retornado, com este comando:

echo $?
Neste caso, o código de saída será “0” que sinaliza sucesso, zero erros, comando finalizado seu trabalho sem problemas.

Saída de exemplo:


Cada comando (ou melhor, os desenvolvedores do programa) podem escolher o que significa cada código de saída acima de 0, mas 0, por convenção, deve sempre significar que o comando foi executado com sucesso. Isso nos ajuda muito no nosso cenário.

Mencionamos que um teste de gráfico deve descrever um contêiner que executa um comando que de alguma forma verifica se o pacote que acabamos de instalar com o Helm está funcionando corretamente. O Helm sabe se o teste foi bem-sucedido com a ajuda do código de saída do comando. Se qualquer comando executado retornar 0 , o Helm considerará o teste aprovado. Se o código for qualquer outro número, o teste é considerado reprovado.

Então, o que poderíamos testar? aqui estão alguns exemplos:

Um comando que tenta efetuar login no servidor de banco de dados com o nome de usuário e a senha fornecidos no arquivo values.yaml. Dessa forma, testamos se o nome de usuário e a senha do administrador foram definidos corretamente e também se o servidor de banco de dados está totalmente funcional.
Teste se o servidor web está funcionando corretamente tentando estabelecer uma conexão com ele.
Faça uma solicitação específica para um aplicativo da Web e verifique se ele retorna uma resposta válida. Por exemplo, digamos que você instalou algum tipo de site que possui uma API especial. Você pode usar um comando para enviar uma solicitação HTTP POST especialmente criada que solicita a versão do site. Se a API estiver funcionando, ela retornará uma resposta válida. Se não estiver funcionando, não haverá resposta. Por exemplo, o comando curl pode ser usado para essa finalidade.
Você pode construir um ou vários testes e colocá-los em qualquer lugar no diretório templates/ . Mas para maior clareza, melhor estrutura, é recomendado que você crie um subdiretório chamado tests e coloque todos eles em templates/tests . Ao agrupar todos eles, será mais fácil diferenciar entre seus arquivos de modelo regulares e seus testes. Vamos criar este subdiretório.

nano ~/nginx/templates/tests/test-nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ .Release.Name }}-nginx-test"
  labels:
    {{- include "nginx.labels" . | indent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ .Release.Name }}-nginx:80']
  restartPolicy: Never

Podemos ver mais uma vez porque o template nomeado que definimos no arquivo _helpers.tpl , em um blog anterior , é útil. Usamos o nginx.labelsmodelo nomeado para produzir os mesmos rótulos que usamos em nosso objeto de implantação. E podemos ver o teste em si na seção containers:, que é bastante simples. Usamos busyboxcomo uma imagem de contêiner, que é uma imagem muito leve que nos dá acesso a alguns comandos úteis, geralmente usados ​​para depurar/consertar coisas. Nesse caso, usamos o comando wget fornecido por busybox, e passamos alguns argumentos de linha de comando para wget , na seção args: . wgeté um utilitário de download simples e nós o instruímos nos argumentos para se conectar ao servidor web Nginx que nosso gráfico instala. Garantimos que usamos o mesmo nome que usamos em nosso arquivo deployment.yaml{{ .Release.Name }}-nginx e informamos ao wget para se conectar à porta :80que o Nginx escuta (para conexões de entrada) por padrão.

Executando testes de gráficos de leme
Para ver isso em ação, primeiro precisamos instalar nosso gráfico novamente.

Os objetos que nosso gráfico criará no Kubernetes são poucos e simples, então isso começa a funcionar rapidamente. Mas para gráficos mais complexos, talvez seja necessário aguardar alguns minutos para garantir que tudo esteja pronto antes de executar os testes.

Genericamente, os testes do Helm são executados com o seguinte comando: helm test NAME_OF_RELEASE.

Assim, com o nome do nosso release, my-website , podemos executar nossos testes com este comando:

helm test my-website
E esta saída confirma que o(s) teste(s) é(são) bem-sucedido(s).

```yaml
user@debian:~$ helm test my-website
NAME: my-website
LAST DEPLOYED: Mon Jun 14 00:16:35 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE:     my-website-nginx-test
Last Started:   Mon Jun 14 00:19:47 2021
Last Completed: Mon Jun 14 00:19:50 2021
Phase:          Succeeded
NOTES:
Please wait a few seconds until the nginx chart is fully installed.

After installation is complete, you can access your website by running this command:

kubectl get --namespace default service my-website-nginx

and then entering the IP address you get, into your web browser's address bar.
```

Mas, como sempre, não devemos estar convencidos de que isso está funcionando corretamente até vermos o outro cenário. E se nosso servidor web Nginx estivesse inativo? Isso detectaria a anomalia? Podemos simular a falha de nosso servidor Nginx definindo o número de réplicas como zero, para que nenhum pod Nginx esteja mais em execução.

kubectl scale --replicas=0 deployment/my-website-nginx

Agora, se executarmos novamente o teste do Helm, veremos um resultado diferente, indicando que o teste falhou.

```yaml
user@debian:~$ helm test my-website
NAME: my-website
LAST DEPLOYED: Mon Jun 14 00:16:35 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE:     my-website-nginx-test
Last Started:   Mon Jun 14 00:23:35 2021
Last Completed: Mon Jun 14 00:23:39 2021
Phase:          Failed
NOTES:
Please wait a few seconds until the nginx chart is fully installed.

After installation is complete, you can access your website by running this command:

kubectl get --namespace default service my-website-nginx

and then entering the IP address you get, into your web browser's address bar.
Error: pod my-website-nginx-test failed
```

Legal! Agora podemos fornecer aos nossos usuários de gráficos uma maneira rápida de verificar se tudo foi implantado corretamente em seus clusters.

Como os testes são Hooks do Helm, vale a pena notar que, se você quiser criar vários testes para um gráfico, se necessário, você pode garantir que eles sejam executados em uma determinada ordem, usando helm.sh/hook-weightanotações.
Além disso, lembre-se de que os hooks (daí os testes também) criam objetos do Kubernetes que podem ser deixados para trás. Por exemplo, neste caso, os testes criam alguns pods que, embora sejam executados uma vez, ainda aparecem nos comandos kubectl get pods 

NAME                    READY   STATUS      RESTARTS   AGE
my-website-nginx-test   0/1     Completed   0          103s
test-nginx-test         0/1     Error       0          28m

Podemos usar helm.sh/hook-delete-policy anotatations para garantir que esses objetos sejam excluídos depois de executados uma vez. Se adicionarmos a linha destacada em nosso arquivo test-nginx.yaml , poderíamos garantir que esses recursos de pod sejam excluídos:

Antes de um novo teste (repetido) ser executado.
Após o teste passar.
Após o teste falhar.
É a mesma política de exclusão de hook que aprendemos em uma lição anterior.

Se agruparmos todas as políticas, podemos garantir que os objetos do Kubernetes criados pelos testes sempre sejam limpos quando o teste terminar.

Teste de exemplo com todas as três políticas de exclusão de hook habilitadas:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ .Release.Name }}-nginx-test"
  labels:
    {{- include "nginx.labels" . | indent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded,hook-failed
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ .Release.Name }}-nginx:80']
  restartPolicy: Never
```

Mas, lembre-se, isso nem sempre pode ser desejado. Às vezes, você pode querer que esses objetos fiquem por perto.