#!/bin/bash
local="$(cd "$(dirname "$0")";pwd)"
site_android="https://developer.android.com/studio/index.html"
site_java="http://www.oracle.com/technetwork/pt/java/javase/downloads/index.html"
dest="$HOME"/Android
download_dir="/tmp/Android"  #local para download
mkdir -p $download_dir

if [ -z "$(which curl)" ] || [ -z "$(which unzip)" ]; then
    echo "Certifique-se que esteja instalado o curl e o unzip."
    exit 0
fi

sdk=0 #indica se baixara soh o sdk
if [ "$1" = "sdk" ]; then
    sdk=1
fi

#Getting links of Android Studio and SDK
links=( $( curl -L "$site_android" 2> /dev/null | grep -Eo 'http[s]?://([^"]*linux[^"]*)' | sort | uniq ) ) 2>/dev/null || (echo "Erro ao tentar alcançar $site_android" && exit 0)
links_f=() # links filtrados

echo "Encontrados: "
for link in "${links[@]}"; do
	nome="$(echo $link | grep -P '([^/]*$)' -o)"
    if [ $sdk = 0 ] && [ ! -z "$(echo $link | egrep studio)" ]; then
        echo -n "Android Studio: "
    elif [ ! -z "$(echo $link | egrep tools)" ]; then
        echo -n "Android SDK: "
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

if [ -z "$( which javac 2>/dev/null)" ]; then
    javac=1
fi
if [ $javac = 1 ]; then
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
fi

#Extraindo
echo "Extraindo"
for file in "${baixados[@]}"; do
    unzip -o "$download_dir/$file" -d "$download_dir"
done

if [ "$javac" = 1 ]; then
    tar -zxf "$download_dir/$java" -C "$download_dir"
fi

#Instalando o SDK
echo 'O sdk será instalado.'
mkdir -p $download_dir/sdk
mv $download_dir/tools $download_dir/sdk
echo 'y' | $download_dir/sdk/tools/bin/sdkmanager 'platforms;android-25' 'tools' 'build-tools;25.0.3' 'extras;google;m2repository' 'extras;android;m2repository'
#TODO: verificar com ps processo rodando

rm "${download_dir:?}"/{*.tar.gz,*.zip} 2>/dev/null #tirando arquivos compactados
mv "$download_dir" "$dest" #movendo para destino final

#ANDROID_HOME
export ANDROID_HOME="$dest/sdk"
#export PATH="$local"/../../java/bin:"$PATH"
#export STUDIO_JDK="$local"/../../java
#export HOME="$local"/../../HOME
