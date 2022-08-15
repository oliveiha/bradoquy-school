Genericamente falando, para trabalhar com o Helm você deve ter o seguinte:

Um cluster funcional do Kubernetes
kubectl instalado e configurado em seu computador local
Detalhes de login configurados no arquivo Kubeconfig, localizado no diretório inicial do seu usuário, na pasta .kube/config. No Windows, se seu nome de usuário for john, esse arquivo deverá estar localizado em C:\Users\john\.kube.config. Em sistemas operacionais baseados em Linux, ele estaria localizado em /home/john/.kube/config.
Existem alguns métodos de instalação listados em https://helm.sh/docs/intro/install/ . O mais fácil é navegar até esta página e baixar a versão mais recente para o seu sistema operacional.

Instale o Helm no Windows
Por exemplo, se o seu sistema operacional for Windows, no momento da escrita, a versão mais recente do Helm pode ser encontrada neste pacote: https://get.helm.sh/helm-v3.5.4-windows-amd64.zip

Não há nada para instalar em seu sistema, pois o Helm consiste em um único arquivo executável simples. Então você só precisa abrir o arquivo ZIP baixado e destacar o arquivo executável “helm”.



Clique com o botão direito do mouse e selecione “Copiar” depois disso, navegue até o diretório inicial do seu usuário, encontrado em C:\Users\your_username. Agora cole o arquivo neste local.

Agora você pode abrir o Prompt de Comando e poderá executar comandos do leme. Simples assim!



Você deve verificar periodicamente a página que lista os novos lançamentos do Helm e verificar se uma nova versão está disponível. Se houver um, basta seguir as mesmas etapas e substituir o arquivo helm que você extraiu em C:\Users\your_username\helm.

Instalando no Linux
Como o Linux já possui gerenciadores de pacotes disponíveis, é mais fácil instalar através deles, pois também rastreia automaticamente quando novas versões da ferramenta de software podem ser baixadas.

Se você estiver em uma distribuição do Ubuntu, este comando simples instalará o Helm da maneira mais fácil:

sudo snap install helm --classic
Usamos o parâmetro “–classic” aqui, pois este pacote usa o que é chamado de “confinamento clássico”, que é um sandbox mais “relaxado” que dá ao aplicativo um pouco mais de acesso ao sistema host, em vez de isolá-lo estritamente em seu ambiente separado . Dessa forma, o Helm pode acessar facilmente o arquivo Kubeconfig em nosso diretório inicial, para que ele saiba como se conectar ao nosso cluster Kubernetes.

Em distribuições Debian ou baseadas em Debian que não possuem o Snap pré-instalado, você pode usar os seguintes comandos:

curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -


sudo apt install apt-transport-https


echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list


sudo apt update && sudo apt install helm
E caso isso não funcione no futuro (por exemplo, porque o repositório baltocdn.com não está mais disponível), você pode usar o seguinte script.

Primeiro, baixe o script

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
Torná-lo executável

chmod +x get_helm.sh
E execute-o para instalar o Helm.

./get_helm.sh