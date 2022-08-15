## Download arquivos 
[/Download strimzi-0.27.1.zip](https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.27.1/strimzi-0.27.1.zip)
unzip strimzi-0.27.1.zip

# criar namespace kafka-operator
kubectl create ns kafka-operator

# Modifique os arquivos de instalação para fazer referência ao kafkanamespace onde você instalará o Strimzi Kafka Cluster Operator.
sed -i 's/namespace: .*/namespace: kafka-operator/' install/cluster-operator/*RoleBinding*.yaml

# Crie um novo namespace kafka-cluster onde você implantará seu cluster Kafka.
kubectl create ns kafka-cluster

# Edite o arquivo *install/cluster-operator/060-Deployment-strimzi-cluster-operator.yaml* e defina a variável de ambiente STRIMZI_NAMESPACE para o namespace kafka-cluster
Ex:
env:
- name: STRIMZI_NAMESPACE
  value: kafka-cluster

# Implante os CRDs e os recursos de controle de acesso baseado em função (RBAC) para gerenciar os CRDs.
kubectl create -f install/cluster-operator/ -n kafka-operator

# Dê permissão ao kafka Operador para observar o namespace kafka-cluster.
kubectl create -f install/cluster-operator/020-RoleBinding-strimzi-cluster-operator.yaml -n kafka-cluster
kubectl create -f install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml -n kafka-cluster

# Editar o arquivo *kafka-persistent.yaml* em examples/kafka/kafka-persistent.yaml e adicionar a configuração de loadbalancer
```
    - name: external
        port: 9094
        tls: false
        type: loadbalance
```
# Atenção para o tamanho referente persistencia de disco 
```
    - id: 0
        type: persistent-claim
        size: 10Gi 
        deleteClaim: false
```
# Ajustes configuração *configmap kafka-cluster-kafka-config*
## Configuração de balanceamento dos acessos externos 
## OBs ; os ips abaixo são os ips atrelados pela cloud ref aos loadbalancer criados *- name: external port: 9094 tls: false type: loadbalance*
```
    data:
  advertised-hostnames.config: >-
    EXTERNAL_9094_0://10.104.2.69 EXTERNAL_9094_1://10.104.2.70
    EXTERNAL_9094_2://10.104.2.73
    PLAIN_9092_0://kafka-cluster-kafka-0.kafka-cluster-kafka-brokers.kafka-cluster.svc
    PLAIN_9092_1://kafka-cluster-kafka-1.kafka-cluster-kafka-brokers.kafka-cluster.svc
    PLAIN_9092_2://kafka-cluster-kafka-2.kafka-cluster-kafka-brokers.kafka-cluster.svc
    TLS_9093_0://kafka-cluster-kafka-0.kafka-cluster-kafka-brokers.kafka-cluster.svc
    TLS_9093_1://kafka-cluster-kafka-1.kafka-cluster-kafka-brokers.kafka-cluster.svc
    TLS_9093_2://kafka-cluster-kafka-2.kafka-cluster-kafka-brokers.kafka-cluster.svc
  advertised-ports.config: >-
    EXTERNAL_9094_0://9094 EXTERNAL_9094_1://9094 EXTERNAL_9094_2://9094
    PLAIN_9092_0://9092 PLAIN_9092_1://9092 PLAIN_9092_2://9092
    TLS_9093_0://9093 TLS_9093_1://9093 TLS_9093_2://9093
  listeners.config: PLAIN_9092 TLS_9093 EXTERNAL_9094  
```    

## Referenciando as configs acima

```
    
    listener.name.replication-9091.ssl.truststore.type=PKCS12

    listener.name.replication-9091.ssl.client.auth=required


    ##########

    # Listener configuration: PLAIN-9092

    ##########


    ##########

    # Listener configuration: TLS-9093

    ##########

    listener.name.tls-9093.ssl.keystore.location=/tmp/kafka/cluster.keystore.p12

    listener.name.tls-9093.ssl.keystore.password=${CERTS_STORE_PASSWORD}

    listener.name.tls-9093.ssl.keystore.type=PKCS12



    ##########

    # Listener configuration: EXTERNAL-9094

    ##########


    ##########

```
    










