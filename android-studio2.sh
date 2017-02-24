#!/bin/bash
local="$(cd "$(dirname "$0")";pwd)"
site_android="https://developer.android.com/studio/index.html"
site_java="http://www.oracle.com/technetwork/pt/java/javase/downloads/index.html"

download_dir="/tmp/AS"  #local para download
mkdir -p $download_dir

if [ -z "$(which curl)" ] || [ -z "$(which unzip)" ]; then
    echo "Certifique-se que você tem instalado o curl e o unzip"
    exit 0
fi


#Getting links of Android Studio and SDK
links=( $( curl -L "$site_android" 2> /dev/null | grep -Eo 'http[s]?://([^"]*linux[^"]*)' ) ) 2>/dev/null || (echo "Erro ao tentar alcançar $site_android" && exit 0)
links_f=() # links filtrados

echo "Encontrados: "
for link in "${links[@]}"; do
	nome="$(echo $link | grep -P '([^/]*$)' -o)"
    if [ ! -z "$(echo $link | egrep studio)" ]; then
        echo -n "Android Studio: "
    elif [ ! -z "$(echo $link | egrep tools)" ]; then
        echo -n "Android Tools: "
    else
        continue #eliminando links indesejáveis
    fi
    links_f+=($link)
    echo "$link"
done
baixados=()
#Downloading Android SDK e Studio
echo -e "\nBaixando..."
for link in "${links_f[@]}"; do
	nome="$(echo $link | grep -Eo '([^/]*$)' )"
	baixados+=($nome)
	if [ ! -e "$download_dir/$nome" ]; then 
		
        (curl -L -C - "$link" -o "$download_dir/$nome") || (echo "Erro no download de $link" && exit 0)
	else
		echo "Arquivo já baixado: $nome"
		continue
	fi	
done


#Downloading java
site_java2=( $(curl -L -s "$site_java" | grep -P 'http[s]?://([^"]*jdk[0-9][0-9]?[-]downloads[^"]*)' -o | uniq) )
echo "Buscando java"
link_java=( $(curl -L -s "$site_java2" | grep -P 'http[s]?://([^"]*jdk[-][^"]*linux-x64.tar.gz)' -o) )
java="$(echo $link_java | grep -Eo '([^/]*$)' )"
echo "Java encontrado: $java"

if [ ! -e "$download_dir/$java" ]; then
    echo -e "\nBaixando... "
    curl -L -C - -H 'Cookie: oraclelicense=accept-securebackup-cookie' $link_java -o "$download_dir/$java"
else
    echo "Arquivo já baixado: $java"    
fi


#Extraindo
echo "Extraindo"
for file in "${baixados[@]}"; do
    unzip -o "$download_dir/$file" -d "$download_dir"
done
tar -zxf "$download_dir/$java" -C "$download_dir"


#Rodando o Tools para instalar o Android SDK
($download_dir/tools/android list sdk --no-ui) > "$download_dir/aux"
numeros=()
numeros+=( $(grep -E 'Repository|[tT]ools' "$download_dir/aux" | awk '{print $1}') )
numeros+=( $(grep -E -m 1 'SDK Platform Android' "$download_dir/aux" | awk '{print $1}') )

param=""
for n in "${numeros[@]}"; do
    param="${n:0:-1},$param"
done

echo 'y' | $download_dir/tools/android update sdk --no-ui -t ${param:0:-1}

#ANDROID_HOME
#export ANDROID_HOME="$local"/../../android-sdk-linux
#export PATH="$local"/../../java/bin:"$PATH"
#export STUDIO_JDK="$local"/../../java
#export HOME="$local"/../../HOME
