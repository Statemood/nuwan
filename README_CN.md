# Nuwan

### 描述
- 基于Harbor的镜像漏洞自动更新模块


### 功能实现
获取镜像列表(library), 找出 '较低' 级别漏洞及以上的镜像进行自动更新(依赖 Dockerfile 中 前置 update)

#### 1. 获取镜像列表
  - 通过 API 获取指定项目下镜像列表

##### 2. 查找包含漏洞镜像
  - 过滤漏洞级别在中等及以上的镜像

##### 3. 更新镜像
  - 利用Dockerfile 中的 **update** 进行更新
  - 更新完成后 Push 至 Harbor

##### 4. 再次扫描
  - 计划弃用

### Dockerfile

##### 1. [示例文件 Dockerfile](https://github.com/Statemood/dockerfiles/tree/master/Dockerfiles)

##### 2. 期望的结构与格式如下

        library/
        ├── alpine
        │   └── 3.7
        │       ├── Dockerfile
        │       ├── files
        │       │   └── etc
        │       │       ├── apk
        │       │       │   └── repositories
        │       │       └── localtime
        │       └── README.md
        ├── busybox
        │   └── 1.28
        │       ├── Dockerfile
        │       └── README.md
        ├── centos
        │   ├── 6
        │   │   └── Dockerfile
        │   └── 7
        │       └── Dockerfile
        ├── elasticsearch
        │   └── 6.2.2
        │       ├── Dockerfile
        │       └── run.sh
        ├── redis
        │   └── 4.0.6
        │       ├── Dockerfile
        │       └── run.sh
        ├── sonarqube
        │   ├── 7.0
        │   │   ├── Dockerfile
        │   │   └── run.sh
        │   └── 7.1
        │       ├── Dockerfile
        │       └── run.sh
        └── zipkin
            ├── 2.5.1
            │   ├── Dockerfile
            │   ├── README.md
            │   └── run.sh
            └── 2.7.1
                ├── Dockerfile
                ├── README.md
                └── run.sh



#### Shell Script


        ws="$(dirname $JENKINS_HOME)/files/dockerfiles"

        cd $ws

        harbor list | awk '{print $2}' | grep '^library' | while read img
        do
	        #echo "`date +'%F %T.%N'` Processing $img"
    
            level=`harbor show $img | grep tag_scan_overview | awk -F ',' '{print $2}' | awk '{print $2}'`
    
            test -z "$level" && level=1
    
            #printf "`date +'%F %T.%N'` %-4s %-64s\n" $level $img
            # level = 1 表示无漏洞, 忽略
            test $level = 1 && continue
    
            img_dir="`echo $img | tr -t ':' '/'`"
    
            if [ -d $img_dir ]
            then
    	        image="$HARBOR/$img"
        
                echo "Build $image (Level: $level)"
        
    	        sudo docker build --no-cache -t $image $img_dir
        
                echo "Push $image"
                sudo docker push $image
            else
    	        echo "Directory $img_dir does not esixt"
            fi    
        done
