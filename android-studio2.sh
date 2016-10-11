#!/bin/bash
site_android="https://developer.android.com/studio/index.html"
site_java="http://www.oracle.com/technetwork/pt/java/javase/downloads/index.html"
local="$(cd "$(dirname "$0")";pwd)"
root_dir="$local/"  #local de download e config

#Getting links of Android Studio and SDK
links=( $( curl "$site_android" 2> /dev/null | grep -P 'https://([^"]*linux[^"]*)' -o ) ) 2>/dev/null || (echo "Erro ao tentar alcançar $site_android" && exit 0)

echo "Encontrados: "
for link in "${links[@]}"; do
	nome="$(echo $link | grep -P '([^/]*$)' -o)"
    if [ ! -z "$(echo $link | egrep studio)" ]; then
        echo -n "Android Studio: "
    elif [ ! -z "$(echo $link | egrep sdk)" ]; then
        echo -n "Android SDK: "
    else
        continue #trash links
    fi
    echo "$link"
done

#Downloading Android SDK e Studio
echo && echo "Baixando..."
for link in "${links[@]}"; do
	nome="$(echo $link | grep -P '([^/]*$)' -o)"
	if [ ! -e "$root_dir""$nome" ]; then 
		if [ ! -z "$(echo $link | egrep studio)" ]; then
			echo "Android Studio"
		elif [ ! -z "$(echo $link | egrep sdk)" ]; then
			echo "Android SDK"
		else
			continue
		fi

    (curl "$link" -o "$root_dir""$nome") || (echo "Erro no download de $link" && exit 0)
	else
		echo "Arquivo já encontrado: $nome"
		continue
	fi	
done

#Downloading java
site_java2=( $(curl "$site_java" | grep -P 'http[s]?://([^"]*jdk[0-9][0-9]?[-]downloads[^"]*)' -o | uniq) )
#echo "$site_java2"
site_java=( $(curl "$site_java2" | grep -P 'http[s]?://([^"]*jdk[-][^"]*linux-x64.tar.gz)' -o) )

echo "$site_java"


#Extrair 
#echo 'y' | android update sdk --no-ui -t number1,number2 #(number get in android list sdk)
#android list sdk --no-ui
#android list sdk --no-ui | egrep -Ei " repo|sdk platform android 7|sdk tools|sdk platform-tools|sdk build" | awk '{print$1}' | tr '\n' ',' | sed s/-//g
#ANDROID_HOME

#https://dl.google.com/android/repository/repository-11.xml
#https://dl.google.com/android/repository/addon.xml

#https://dl.google.com/android/repository/google_m2repository_r32.zip - Google Repository
#https://dl.google.com/android/repository/android_m2repository_r36.zip - Android Support Repository

#https://dl.google.com/android/repository/platform-24_r01.zip - Android SDK Platform 24
#https://dl.google.com/android/repository/build-tools_r24-linux.zip - Android SDK Build-tools 24
#https://dl.google.com/android/repository/tools_r25.1.7-linux.zip - Android SDK Tools

#local="$(cd "$(dirname "$0")";pwd )"
#export ANDROID_HOME="$local"/../../android-sdk-linux
#export PATH="$local"/../../java/bin:"$PATH"
#export STUDIO_JDK="$local"/../../java
#export HOME="$local"/../../HOME
