# Android noroot

Um script para GNU/Linux que prepara o computador para trabalhar com Android. Possibilitando a instalação das últimas versões do Android SDK, Android Studio e Java automaticamente e sem precisar de acesso root, ou seja, funciona naquele computador da faculdade/escola/trabalho que você sempre achou limitado por [não conseguir instalar algo](https://github.com/wison27/noroot).

### Instalando apenas SDK
Para instalar apenas o SDK basta passar o parâmetro 'sdk'.
<pre> git clone https://github.com/wison27/android-noroot && cd android-noroot && bash ./android.sh sdk </pre>

### Instalação Completa
E para instalar o SDK e o Android Studio só isso.
<pre> git clone https://github.com/wison27/android-noroot && cd android-noroot && bash ./android.sh </pre>

### Java
A instalação do java é feita automaticamente se necessário em todas as formas de instalação.

### Como funciona?
O script vai até o site do java e do Android, pega o link das últimas versões de softwares disponíveis e então os baixa (tudo via curl). Depois só extrai, move para um lugar e configura variáveis (PATH, ANDROID_HOME, ANDROID_SDK, ...) para dizer aonde ele foi instalado.
