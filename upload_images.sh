#!/bin/sh

#加载镜像
ls -F ./docker-images/*/*.tar | awk '{cmd="docker load -i "$0;print(cmd);system(cmd)}'

#nfs-provisioner镜像
docker tag quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11 docker-registry.supconit.com/library/nfs-client-provisioner:v3.1.0-k8s1.11

#kube
docker tag k8s.gcr.io/kube-apiserver:v1.16.0 docker-registry.supconit.com/library/kube-apiserver:v1.16.0
docker tag k8s.gcr.io/kube-proxy:v1.16.0 docker-registry.supconit.com/library/kube-proxy:v1.16.0
docker tag k8s.gcr.io/kube-controller-manager:v1.16.0 docker-registry.supconit.com/library/kube-controller-manager:v1.16.0
docker tag k8s.gcr.io/kube-scheduler:v1.16.0 docker-registry.supconit.com/library/kube-scheduler:v1.16.0
docker tag k8s.gcr.io/etcd:3.3.15-0 docker-registry.supconit.com/library/etcd:3.3.15-0
docker tag k8s.gcr.io/coredns:1.6.2 docker-registry.supconit.com/library/coredns:1.6.2
docker tag k8s.gcr.io/pause:3.1 docker-registry.supconit.com/library/pause:3.1

#calico
docker tag calico/node:v3.8.2 docker-registry.supconit.com/library/node:v3.8.2
docker tag calico/cni:v3.8.2 docker-registry.supconit.com/library/cni:v3.8.2
docker tag calico/kube-controllers:v3.8.2 docker-registry.supconit.com/library/kube-controllers:v3.8.2
docker tag calico/pod2daemon-flexvol:v3.8.2 docker-registry.supconit.com/library/pod2daemon-flexvol:v3.8.2

#efk镜像
docker tag quay.io/fluentd_elasticsearch/fluentd:v2.7.0 docker-registry.supconit.com/library/fluentd:v2.7.0
docker tag quay.io/fluentd_elasticsearch/elasticsearch:v7.3.2 docker-registry.supconit.com/library/fluentd_elasticsearch:v7.3.2
docker tag docker.elastic.co/kibana/kibana-oss:7.2.0 docker-registry.supconit.com/library/kibana-oss:7.2.0

#kuboard监控镜像
docker tag prom/blackbox-exporter:v0.14.0 docker-registry.supconit.com/library/blackbox-exporter:v0.14.0
docker tag grafana/grafana:6.2.5 docker-registry.supconit.com/library/grafana:6.2.5
docker tag mirrorgooglecontainers/kube-state-metrics:v1.6.0 docker-registry.supconit.com/library/kube-state-metrics:v1.6.0
docker tag mirrorgooglecontainers/addon-resizer:1.8.4 docker-registry.supconit.com/library/addon-resizer:1.8.4
docker tag prom/prometheus:v2.10.0 docker-registry.supconit.com/library/prometheus:v2.10.0
docker tag prom/node-exporter:v0.17.0 docker-registry.supconit.com/library/node-exporter:v0.17.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server-amd64:v0.3.6 docker-registry.supconit.com/library/metrics-server-amd64:v0.3.6
#docker tag eipwork/kuboard:latest docker-registry.supconit.com/library/kuboard:latest
docker tag alpine:3.6 docker-registry.supconit.com/library/alpine:3.6

#中间件、数据库镜像
docker tag 172.20.41.47/library/nginx:1.13.0-alpine docker-registry.supconit.com/library/nginx:1.13.0-alpine
docker tag 172.20.41.47/library/nginx:1.13.0-alpine docker-registry.supconit.com/library/nginx:latest
docker tag 172.20.41.47/library/monitor-server:latest docker-registry.supconit.com/library/monitor-server:latest
docker tag 172.20.41.47/library/registry-server:latest docker-registry.supconit.com/library/registry-server:latest
docker tag 172.20.41.47/library/redis:3.2.9 docker-registry.supconit.com/library/redis:3.2.9
docker tag 172.20.41.47/library/storm:latest docker-registry.supconit.com/library/storm:latest
#docker tag 172.20.41.47/library/xxl-job-admin:2.1.2 docker-registry.supconit.com/library/xxl-job-admin:2.1.2
docker tag 172.20.41.47/library/zookeeper:latest docker-registry.supconit.com/library/zookeeper:latest
docker tag 172.20.41.47/library/kafka:latest docker-registry.supconit.com/library/kafka:latest
docker tag 172.20.41.47/library/mysql:latest docker-registry.supconit.com/library/mysql:latest
docker tag 172.20.41.47/library/elasticsearch:7.4.1 docker-registry.supconit.com/library/elasticsearch:7.4.1

#pg、geoserver镜像
docker tag mdillon/postgis:latest docker-registry.supconit.com/library/postgis:latest

#java镜像
docker tag java:8-jre docker-registry.supconit.com/library/java:8-jre
docker tag java:8-jre-zh-font docker-registry.supconit.com/library/java:8-jre-zh-font
docker tag java:8-jdk docker-registry.supconit.com/library/java:8-jdk

#上传镜像
docker login docker-registry.supconit.com -u admin -p Harbor12345

for image in `docker images | grep docker-registry.supconit.com | awk '{print $1":"$2}'`; do docker push "$image"; done
