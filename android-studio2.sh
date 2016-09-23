#!/bin/bash
site="https://developer.android.com/studio/index.html"
local="$(cd "$(dirname "$0")";pwd)"
root_dir="$local/"  #local de download e config

links=( $( (curl "$site" | egrep -i android[-].*[l]inux | cut -d'"' -f2 | grep ^http ) 2> /dev/null) )

#Getting links of Android Studio and SDK
for link in "${links[@]}"; do
	nome="$(echo $link | rev | cut -d'/' -f1 | rev)"
	if [ ! -e "$root_dir""$nome" ]; then 
		if [ ! -z "$(echo $link | egrep studio)" ]; then
			echo -n "Baixando Android Studio: "
		elif [ ! -z "$(echo $link | egrep sdk)" ]; then
			echo -n "Android SDK: "
		else
			continue
		fi
	echo "$link"

	(curl "$link" -o "$root_dir""$nome") || (echo "Erro no download de $link" && exit 0)
	else
		echo "Arquivo já encontrado: $nome"
		continue
	fi	

done

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
