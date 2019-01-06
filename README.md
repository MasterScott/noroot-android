# Android noroot

Install easily in linux/macOS systems the last version of Android SDK, Android Studio and Java, without root access (or sudo password), for other softwares try the [noroot](https://github.com/wison27/noroot).

## Install Android Studio && SDK
<pre> bash ./android.sh </pre>
When conclude, reOPEN the TERMINAL and run:
<pre> studio.sh #to open the android studio </pre>

## Install only Android SDK
<pre> bash ./android.sh --sdkonly </pre>


## Usage
```
Usage: android.sh [ options ]
options:
          -s|--sdkonly   install only sdk (without android studio)
          -j|--forcejava install the java ignoring if the system already have this
          -y|--yes       positive to all questions
          -r|--remove    remove if already installed
          -h|--help      show this help
```

## macOS
At the moment only SDK install is supported

