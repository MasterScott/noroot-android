#!/bin/bash
pkgs=( #lista de pacotes que serão instalados pelo sdkmanager
    'platforms;android-25'
    'tools'
    'sources;android-25'
    'build-tools;25.0.3'
    'extras;google;m2repository'
    'extras;android;m2repository' 
)

site_android="https://developer.android.com/studio/index.html"
site_java="http://www.oracle.com/technetwork/pt/java/javase/downloads/index.html"

if [ -z "$(which curl)" ] || [ -z "$(which unzip)" ]; then #verificando ferramentas
    echo "Certifique-se que esteja instalado o curl e o unzip."
    exit 1
fi

sdk=0 #indica se baixara soh o sdk
if [ "$1" = "sdk" ]; then
    sdk=1
fi

javac=0
if [ "$2" = "jdk" ]; then
    javac=1
fi

#Cuidando dos locais para download e instalação
dest="$HOME"/Android #diretório para instalação
if [ -d "$dest" ];then
    echo -n "O diretório para instalação ($dest) já existe. Ele pode ser apagado? [Y/n] "
    read r
    if [ "$r" = "n" ] || [ "$r" = "N" ];then
        echo -ne "\nOk, escolha outro: "
        read dest
        while [ -e "$dest" ]; do
            echo -en "\nDiretório já existe. Tente novamente: "
            read dest
        done
    fi
    echo "Ok"
    rm -rf "${dest:?}" 2>/dev/null #limpando a casa
fi

download_dir="/tmp/Android"  #local para download
rm -rf "${download_dir:?}"/* 2>/dev/null #limpando
mkdir -p $download_dir #confirmando a existência


#Getting links of Android Studio and SDK
links=( $( curl -L "$site_android" 2> /dev/null | grep -Eo 'http[s]?://([^"]*linux[^"]*)' | sort | uniq ) ) 2>/dev/null || (echo "Erro ao tentar alcançar $site_android" && exit 2)
links_f=() # links filtrados

echo "Encontrados: "
for link in "${links[@]}"; do
	nome="$(echo "$link" | grep -P '([^/]*$)' -o)"
    if [ $sdk = 0 ] && (echo "$link" | grep -qE studio); then
        echo -n "Android Studio: "
    elif  echo "$link" | grep -qE tools; then
        echo -n "SDK Tools: "
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
	nome="$(echo "$link" | grep -Eo '([^/]*$)' )"
	baixados+=($nome)
	if [ ! -e "$download_dir/$nome" ]; then 
		
        (curl -L -C - "$link" -o "$download_dir/$nome") || (echo "Erro no download de $link" && exit 2)
	else
		echo "Arquivo já baixado: $nome"
		continue
	fi	
done

if [ -z "$( which javac 2>/dev/null)" ]; then #verificando se precisa do jdk
    javac=1
fi
if [ $javac = 1 ]; then
    #Downloading java
    site_java2=( $(curl -L -s "$site_java" | grep -P 'http[s]?://([^"]*jdk[0-9][0-9]?[-]downloads[^"]*)' -o | uniq) )
    echo "Buscando java"
    link_java=( $(curl -L -s "$site_java2" | grep -P 'http[s]?://([^"]*jdk[-][^"]*linux-x64.tar.gz)' -o) )
    java="$(echo "$link_java" | grep -Eo '([^/]*$)' )"
    echo "Java encontrado: $java"

    if [ ! -e "$download_dir/$java" ]; then
        echo -e "\nBaixando... "
        curl -L -C - -H 'Cookie: oraclelicense=accept-securebackup-cookie' "$link_java" -o "$download_dir/$java"
    else
        echo "Arquivo já baixado: $java"    
    fi
fi

echo "Extraindo "
for file in "${baixados[@]}"; do
    unzip -o "$download_dir/$file" -d "$download_dir" 2>/dev/null >&2
done

if [ $javac = 1 ]; then
    tar -zxf "$download_dir/$java" -C "$download_dir" ; mv "$download_dir"/jdk*/ "$download_dir"/jdk
fi

#Instalando ferramentas do SDK
mkdir -p $download_dir/Sdk && mv $download_dir/tools $download_dir/Sdk
param=""
for i in "${pkgs[@]}"; do #concatenando parâmetros para usar no sdkmanager
    param="$param $i"
done
echo 'Serão instalados:'$param

(echo y | $download_dir/Sdk/tools/bin/sdkmanager $param 2>/dev/null >&2) &

#verificando se sdk ainda está baixando
while (ps auxw | grep -qi sdkmanage[r] 2>/dev/null); do
    echo -n '.'
done
echo -e '\nOk'
rm "${download_dir:?}"/{*.tar.gz,*.zip} 2>/dev/null #tirando arquivos compactados
(mv "$download_dir" "$dest") || (echo "Não foi possível instalar em $dest." && exit 4) #movendo para destino final


#ANDROID_HOME
echo 'source $HOME/.androidrc' >> "$HOME"/.bashrc
echo 'source $HOME/.androidrc' >> "$HOME"/.profile

> "$HOME"/.androidrc #limpando arquivo
echo 'export ANDROID_HOME='"$dest"'/Sdk' >> "$HOME"/.androidrc
echo 'export ANDROID_SDK='"$dest"'/Sdk' >> "$HOME"/.androidrc
if [ $javac = 1 ];then
    echo 'export JDK_HOME='"$dest"'/jdk' >> "$HOME"/.androidrc
    echo 'export JAVA_HOME='"$dest"'/jdk' >> "$HOME"/.androidrc
    echo 'export PATH=$JDK_HOME/bin:$PATH' >> "$HOME"/.androidrc
fi
echo 'export PATH=$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH' >> "$HOME"/.androidrc
if [ "$sdk" = 0 ];then
    echo 'export PATH='"$dest"/android-studio/bin:'$PATH' >> "$HOME"/.androidrc
fi
echo -e "\nReabra os terminais em execução para atualizar."
#export STUDIO_JDK="$local"/../../java
#export HOME="$local"/../../HOME
