# Android noroot

Um script para GNU/Linux que prepara o computador para trabalhar com Android. Possibilitando a instalação das últimas versões do Android SDK, Android Studio e Java automaticamente e sem precisar de acesso root, ou seja, funciona naquele computador da faculdade/escola/trabalho que você sempre achou limitado por [não conseguir instalar algo](https://github.com/wison27/noroot).

### Instalando apenas SDK
<pre> git clone https://github.com/wison27/noroot-android && cd noroot-android && bash ./android.sh sdk </pre>

### Instalação Completa
<pre> git clone https://github.com/wison27/noroot-android && cd noroot-android && bash ./android.sh </pre>

### Java
A instalação do java é feita automaticamente, quando não é encontrado o javac, em todas as formas de instalação.

### Como funciona?
O script vai até o site do Java (se necessário) e do Android, pega o link das últimas versões de softwares disponíveis e então os baixa (via curl). Depois extrai, move para um lugar e configura variáveis (PATH, ANDROID_HOME, ANDROID_SDK, ...) para dizer aonde foram instalados.
