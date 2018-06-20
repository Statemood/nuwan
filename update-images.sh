#! /bin/bash


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
    	image="registry.qtt6.cn/$img"
        
        msg i "Build $image (Level: $level)"
        
    	sudo docker build --no-cache -t $image $img_dir
        
        msg i "Push $image"
        sudo docker push $image
    else
    	msg a "Directory $img_dir does not esixt"
    fi    
done
