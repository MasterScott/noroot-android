
dest="$HOME"/Java #directory to install

site_java="https://www.oracle.com/technetwork/pt/java/javase/downloads/index.html"

f_help=0
f_yes=0
f_remove=0

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
    *) 
        echo 'ignoring invalid option: ' $param;;
    esac
done

if (( $f_help == 1 )); then
    echo -ne '## install java to local user\n'
    echo -ne 'Usage: '$0' [ options ]\n'
    echo -ne 'options:\n'
    echo -ne '\t  -y|--yes\t positive to all questions \n'
    echo -ne '\t  -r|--remove\t remove if already installed \n'
    echo -ne '\t  -h|--help\t show this help\n'
    exit 0
fi


if (( $f_remove == 1 )); then
    rm -f $HOME/.javarc
    touch $HOME/.profile
    sed -e 's/.*[.]javarc.*//g' -i $HOME/.profile -i $HOME/.bashrc
    rm -rf ${dest:?}
    echo 'Remove complete'
    exit 0
fi


if [ -z "$(which curl)" ]; then #verify tools
    echo "Install curl..."
    exit 1
fi


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

#Downloading java
site_java2=( $(curl -L -s "$site_java" | grep -E 'http[s]?://([^"]*jdk[0-9][0-9]?[-]downloads[^"]*)' -o | uniq) )
link_java=( $(curl -L -s "$site_java2" | grep -E 'http[s]?://([^"]*jdk[-][^"]*linux-x64.tar.gz)' -o) )
link_java=${link_java[$((${#link_java[@]} - 1))]} #select the last link founded
java="$(echo "$link_java" | grep -Eo '([^/]*$)' )"
echo "Java founded: $java"

if [ ! -e "$dest/$java" ]; then
    echo -e "\nDownloading... "
    curl -L -C - -H 'Cookie: oraclelicense=accept-securebackup-cookie' "$link_java" -o "$dest/$java"
else
    echo "File already downloaded: $java"    
fi

echo "Uncompressing... "
tar -zxf "$dest/$java" -C "$dest" || (echo 'Error in extract' && exit 1)
rm "$dest/$java"
mv "$dest"/jdk*/ "$dest"/jdk || (echo 'Error to move' && exit 1)

rm -f "$HOME"/.javarc #cleaning file
echo 'export JDK_HOME='"$dest"'/jdk' >> "$HOME"/.javarc
echo 'export JAVA_HOME='"$dest"'/jdk' >> "$HOME"/.javarc
echo 'export PATH=$JDK_HOME/bin:$PATH' >> "$HOME"/.javarc
echo 'source $HOME/.javarc' >> "$HOME"/.bashrc
echo 'source $HOME/.javarc' >> "$HOME"/.profile
echo 'Ok'