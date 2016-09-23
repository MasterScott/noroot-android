#!/bin/bash
local="$(cd "$(dirname "$0")";pwd )"
ANDROID_STUDIO="android-studio-ide-143.3101438-linux.zip"
JAVA="jdk-8u102-linux-x64.tar.gz"

#Extraindo
if [ ! -d "$local"/android-studio ]; then unzip "$local"/"$ANDROID_STUDIO" -d "$local"; fi
if [ ! -d "$local"/java ]; then
	tar -zxf "$local"/"$JAVA" -C "$local"
	mv "$local"/jdk*/ "$local"/java
fi


#Setando 
export ANDROID_HOME="$local"/android-sdk-linux
export PATH="$local"/java/bin:"$PATH"
export JDK_HOME="$local"/java
export PATH="$local"/coreutils:"$PATH"

#Abrindo
export LD_LIBRARY_PATH="$local"
"$local"/android-studio/bin/studio.sh
