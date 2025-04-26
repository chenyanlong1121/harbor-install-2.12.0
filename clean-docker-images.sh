#/bin/sh

echo $(date)
echo "开始清理docker镜像"

projects=`/usr/local/bin/docker images | grep /supconit/ | awk {'print $1'} | sort | uniq`

for project in $projects;do
  branchs=`/usr/local/bin/docker images |grep $project | awk {'print $2'} | awk -F_ '{print $1}' | sort | uniq`
  for branch in $branchs;do
    imageIds=`/usr/local/bin/docker images |grep $project |grep $branch |tail -n +3 | awk {'print $2'}`
    for imageId in $imageIds;do
        echo "删除镜像$project:$imageId"
        /usr/local/bin/docker rmi $project:$imageId
    done
  done
done