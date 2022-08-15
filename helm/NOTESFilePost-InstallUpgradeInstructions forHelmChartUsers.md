Alguns gráficos do Helm podem ficar bastante complexos, instalando e interconectando muitos objetos em seu cluster Kubernetes. Como tal, pode ser bastante confuso para os usuários como eles devem continuar após a instalação de um gráfico. Como me conecto a este pacote/aplicativo do Kubernetes? Como faço para gerenciá-lo? Quais são o nome de usuário e a senha? O que preciso fazer durante uma atualização? Todas essas perguntas podem ser respondidas imediatamente após a instalação ou atualização de um gráfico, exibindo informações úteis para o usuário. Isso pode ser feito adicionando um arquivo especial chamado NOTES.txt ao diretório templates/ do gráfico.

O arquivo NOTES.txt é renderizado exatamente como um arquivo de modelo normal do Helm, a única diferença é que depois de renderizado, ele não é enviado para o Kubernetes, mas sim, o conteúdo é exibido na janela/terminal da linha de comando, para o usuário ver. Como é tratado como um modelo regular, significa que podemos usar as mesmas técnicas e truques que usamos até agora. Podemos buscar valores do arquivo values.yaml, podemos buscar valores do nome do gráfico, nome da versão, adicionar blocos condicionais if, usar controle de fluxo, funções, pipelines e assim por diante. Mas, como sempre, a teoria pode parecer um pouco misteriosa, então vamos ver isso na prática.

Vamos criar o arquivo NOTES.txt usando seu editor de texto favorito e podemos adicionar instruções sobre como os usuários podem se conectar ao servidor web Nginx após instalar este gráfico. Cole este conteúdo em seu arquivo NOTES.txt .

Please wait a few seconds until the {{ .Chart.Name }} chart is fully installed.

After installation is complete, you can access your website by running this command:

kubectl get --namespace {{ .Release.Namespace }} service {{ .Release.Name }}-nginx

and then entering the IP address you get, into your web browser's address bar.


Agora, quando instalarmos este gráfico usando o comando helm install test ./nginx, veremos esta saída:


```bash
user@debian:~$ helm install test ./nginx
NAME: test
LAST DEPLOYED: Sat Jun 12 00:17:11 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Please wait a few seconds until the nginx chart is fully installed.

After installation is complete, you can access your website by running this command:

kubectl get --namespace default service test-nginx

and then entering the IP address you get, into your web browser's address bar.
```

Excelente! Agora, nossos usuários de gráficos têm todas as informações de que precisam.