#!/bin/sh

if [ $# != 3 ] ; then 
echo "USAGE: sh install.sh Docker数据存放路径[默认/var/lib/docker] Harbor数据存放路径[默认/data]   harbor服务器IP" 
echo " e.g.: sh install.sh /var/lib/docker /supconit/harbor-data  172.17.1.37" 
exit 1; 
fi 

DOCKER_DATA_PATH=$1
HARBOR_DATA_PATH=${2:-/data}
HARBOR_IP=$3

echo "Docker数据存放路径：$DOCKER_DATA_PATH"
echo "Harbor数据存放路径：$HARBOR_DATA_PATH"
echo "本机IP地址：$HARBOR_IP"

read -r -p "请确认上述配置,是否继续? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
        #安装tar:判断是否安装
        rpm -q tar
        if [ $(echo $?) -gt 0 ];then
          echo -e "\e[32m 开始安装tar \e[0m"
          rpm -vih tar/tar*.rpm  --force --nodeps
          echo -e "\e[32m 成功安装tar命令  \e[0m"
        else
          echo -e "\e[33m 已安装tar命令，跳过安装 \e[0m"
        fi
        echo "开始安装"
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        systemctl stop firewalld
        systemctl disable firewalld
        sed -i "/docker-registry.supconit.com/d" /etc/hosts
        echo $HARBOR_IP docker-registry.supconit.com >>  /etc/hosts

        #安装docker
        cd shell
        sh docker.sh $DOCKER_DATA_PATH
        cd ..

        #安装docker-compose
        if [ -f "/usr/local/bin/docker-compose" ]; then
          echo "docker-compose已安装，跳过"
        else
          echo "开始安装docker-compose"
          cp docker-compose-linux-x86_64 /usr/local/bin/docker-compose
          chmod a+x /usr/local/bin/docker-compose
          docker-compose version
          echo "成功安装docker-compose"
        fi

        #安装harbor
        if [ -f "./harbor/docker-compose.yml" ]; then
          echo "harbor已安装，跳过"
        else
          echo "开始安装harbor镜像中心"
          tar zxvf harbor-offline-installer-*.tgz
          cd harbor
	  harborInstallPath=$(pwd)	
	  cp  harbor.service  /usr/lib/systemd/system/
          sed -i "s#{{ harbor_install_path }}#$harborInstallPath#g" /usr/lib/systemd/system/harbor.service         

          cp harbor.yml.tmpl harbor.yml

          sed -i "s/reg.mydomain.com/docker-registry.supconit.com/g" harbor.yml
          sed -i "s%/data%$HARBOR_DATA_PATH%g" harbor.yml

          sed -i "13s/^/#&/g" harbor.yml
          sed -i "15s/^/#&/g" harbor.yml
          sed -i "17s/^/#&/g" harbor.yml
          sed -i "18s/^/#&/g" harbor.yml

          sh install.sh
          systemctl  enable harbor
          cd ..
          echo "成功安装harbor镜像中心"
	  echo -e "\033[32m 启动命令：systemctl  start harbor \033[0m"
          echo -e "\033[32m 停止命令：systemctl  stop  harbor \033[0m"
          echo -e "\033[32m 状态命令：systemctl status harbor \033[0m"
        fi
        cp ./clean-docker-images.sh /root/
        chmod a+x /root/clean-docker-images.sh
        echo "0 2 * * *  /root/clean-docker-images.sh >> /root/clean.log 2>&1" >> /var/spool/cron/root

        #加载镜像
        # ls -F ./docker-images/*/*.tar | awk '{cmd="docker load -i "$0;print(cmd);system(cmd)}'
        #docker load -i ./docker-images/images.tar
		
		#java镜像
		docker tag java:8-jre docker-registry.supconit.com/library/java:8-jre
		docker tag java:8-jre-zh-font docker-registry.supconit.com/library/java:8-jre-zh-font
		docker tag java:8-jdk docker-registry.supconit.com/library/java:8-jdk

        #上传镜像
        cd harbor
        systemctl restart docker
        rm -rf ${HARBOR_DATA_PATH}/redis/dump.rdb
        rm -rf ${HARBOR_DATA_PATH}/database
        ./repare
        ./install.sh
        echo "准备推送镜像,请稍等,正在做最后安全核对"
        sleep 10s
        docker login docker-registry.supconit.com -u admin -p Harbor12345
        curl -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "localhost/api/v2.0/projects" -d '{"project_name":"supconit","metadata":{"public":"true"},"count_limit":-1,"storage_limit":-1}'
        for image in `docker images | grep docker-registry.supconit.com | awk '{print $1":"$2}'`; do docker push $image; done
        ;;

    [nN][oO]|[nN])
        echo "退出安装"
        ;;

    *)
        echo "无效选项"
        exit 1
        ;;
esac
