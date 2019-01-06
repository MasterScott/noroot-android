#!/bin/bash
pkgs=( #lista de pacotes que serão instalados pelo sdkmanager
    'platforms;android-27'
    'tools'
    'platform-tools'
    'sources;android-27'
    'build-tools;27.0.3'
    'extras;google;m2repository'
    'extras;android;m2repository' 
)
site_android="https://developer.android.com/studio/index.html"
dest="$HOME"/Android #directory to install

so="$(uname | tr '[:upper:]' '[:lower:]')"
local="$(cd "$(dirname "$0")"; pwd)"

f_help=0
f_remove=0
f_sdk=0
f_java=0
f_yes=0

for param in $@; do
    case $param in
    -h|--help) 
        f_help=1
    ;;
    -r|--remove|--uninstall) 
        f_remove=1
    ;;
    -y|--yes)
        f_yes=1
    ;;
    -s|--sdkonly) 
        f_sdk=1
    ;;
    -j|--forcejava) 
        f_java=1
    ;;
    *) 
        echo 'ignoring invalid option: ' $param;;
    esac
done

if (( $f_help == 1 )); then
    echo -ne '## install android sdk to local user\n'
    echo -ne 'Usage: '$0' [ options ]\n'
    echo -ne 'options:\n'
    echo -ne '\t  -s|--sdkonly\t install only sdk (without android studio) \n'
    echo -ne '\t  -j|--forcejava install the java ignoring if the system already have this\n'
    echo -ne '\t  -y|--yes\t positive to all questions \n'
    echo -ne '\t  -r|--remove\t remove if already installed \n'
    echo -ne '\t  -h|--help\t show this help\n'
    exit 0
fi

function remove() {
    bash "$local"/java.sh -r
    rm -f $HOME/.androidrc
    if [ "$so" = "darwin" ]; then
        sed -e 's/.*[.]androidrc.*//g' -i $HOME/.bash_profile
    else
        touch $HOME/.profile
        sed -e 's/.*[.]androidrc.*//g' -i $HOME/.profile -i $HOME/.bashrc
    fi
    rm -rf ${dest:?}
    rm -rf /tmp/Android
    echo 'Android Tools Remove complete'
    exit 0
}

if (( $f_remove == 1 )); then
    remove
fi


if [ -z "$(which curl)" ] || [ -z "$(which unzip)" ]; then #verificando ferramentas
    echo "Install curl and unzip..."
    exit 1
fi

if [ "$so" = "darwin" ]; then
    f_sdk=1
fi


if [ ! -z "$(which javac 2>/dev/null)" ] && [ "$(javac -version 2>&1|  grep -iEo '[0-9]*'  | grep -E -m1 '[0-9]*')" -gt 8 ]; then
    echo 'The java installed doesnt seem compatible with android sdk, the java 8 will be download'
    f_java=1
fi

#installing java
if (( $f_java == 1 )) || [ -z "$(which javac 2>/dev/null)" ]; then 
    if [ "$so" = "darwin" ]; then
        echo "Java install not yet supported in macos :( , install this and run again."
        exit 1
    fi
    bash "$local"/java.sh -y
    source "$HOME"/.javarc
fi


#Taking care of locations for download and install
if [ -d "$dest" ];then
    if (( $f_yes == 1 )); then
        r="y"
    else
        echo -n "The install directory ($dest) already exist. Can it be deleted ? [Y/n] "
        read r
    fi
    if [ "$r" = "n" ] || [ "$r" = "N" ]; then
        echo 'Exiting...'
        exit 0
    fi
    rm -rf "${dest:?}" 2>/dev/null #cleaning
fi
mkdir -p "$dest"
trap remove INT

# Getting links of Android Studio and SDK
links=( $( curl -L "$site_android" 2> /dev/null | grep -Eo 'http[s]?://([^"]*'$so'[^"]*)' | sort | uniq ) ) 2>/dev/null || (echo "Error to reach $site_android" && exit 2)
links_f=() # filters links

echo "Founded: "
for link in "${links[@]}"; do
	nome="$(echo "$link" | grep -E '([^/]*$)' -o)"
    if (( $f_sdk == 0 )) && (echo "$link" | grep -qE studio); then
        echo -ne "\tAndroid Studio: "
    elif  echo "$link" | grep -qE tools; then
        echo -ne "\tSDK Tools: "
    else
        continue #eliminando links indesejáveis
    fi
    links_f+=($link)
    echo "$link"
done

baixados=()
# Download
echo -e "\nDownloading..."
for link in "${links_f[@]}"; do
	nome="$(echo "$link" | grep -Eo '([^/]*$)' )"
	baixados+=($nome)
    curl -L -C - "$link" -o "$dest/$nome" || (echo "Error to downloading $link" && exit 2)
done

echo "Uncompressing "
for file in "${baixados[@]}"; do
    unzip -o "$dest/$file" -d "$dest" 2>/dev/null >&2
done

# install sdk tools
mkdir -p "$dest"/Sdk && mv "$dest"/tools "$dest"/Sdk

param=""
for i in "${pkgs[@]}"; do #concatenando parâmetros para usar no sdkmanager
    param="$param "$i""
done

yes | "$dest"/Sdk/tools/bin/sdkmanager $param 

echo -e '\nOk'
rm "${dest:?}"/{*.tar.gz,*.zip} 2>/dev/null #tirando arquivos compactados
echo 'Accepting licenses...'
(yes | "$dest"/Sdk/tools/bin/sdkmanager --licenses 2>/dev/null >&2)


#ANDROID_HOME
if [ "$so" = "darwin" ]; then
    echo 'source $HOME/.androidrc' >> "$HOME"/.bash_profile
else
    echo 'source $HOME/.androidrc' >> "$HOME"/.bashrc
    echo 'source $HOME/.androidrc' >> "$HOME"/.profile
fi

rm -f "$HOME"/.androidrc #cleaning file
echo 'export ANDROID_HOME='"$dest"'/Sdk' >> "$HOME"/.androidrc
echo 'export ANDROID_SDK='"$dest"'/Sdk' >> "$HOME"/.androidrc
echo 'export PATH=$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH' >> "$HOME"/.androidrc

if [ -d "$dest/Sdk/build-tools" ]; then
    echo 'export PATH='"$dest/Sdk/build-tools/"$(ls -1 "$dest/Sdk/build-tools" | head -1)':$PATH' >> "$HOME"/.androidrc
fi

if (( $f_sdk == 0 )); then
    echo 'export PATH='"$dest"/android-studio/bin:'$PATH' >> "$HOME"/.androidrc
fi
echo -e "\nReopen the terminal in execution to apply (or do: . ~/.androidrc)."

