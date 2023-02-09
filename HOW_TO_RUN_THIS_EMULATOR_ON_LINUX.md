# Установка wine

Установите `wine`.

`Arch`:

``` bash
sudo pacman -Sy
sudo pacman -S wine-staging winetricks
sudo pacman -S giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader cups samba dosbox
```

`Ubuntu`:

``` bash
sudo dpkg --add-architecture i386
sudo apt update && sudo apt upgrade
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/'
sudo apt update
sudo apt install --install-recommends winehq-staging
sudo apt install dosbox winetricks
```

[См. тут](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/) более подробно или для других дистрибутивов.



# Запуск всего этого вот

## Инициализация

Разорхивируйте `ADUC.zip` куда-нибудь.

Запустите скрипт `start.sh` (его можно запускать в любой директории):

``` bash
bash start.sh # menu item "Init prefix"
```

В меню выберите пункт `Init prefix`. Предложат установить `Wine Mono Installer`, отклоните. Подождите чуть-чуть. Далее выберите Windows Version: `Windows XP`. Закройте окошко.

## Запуск эмулятора

Запустите скрипт, выберите пункт `Run ADSIM812.EXE`:

``` bash
bash start.sh # menu item "Run ADSIM812.EXE"
```

## Компиляция файла

Скопируйте ваш код в файл `./work/code.asm`.

Запустите скрипт, выберите пункт `Compile ./work/code.asm`.

``` bash
bash start.sh # menu item "Compile ./work/code.asm"
```

Компилироваться будет **ТОЛЬКО** файл `./work/code.asm`!

Если ошибок нет, то в файле `./work/CODE.LST` можно найти строку `VERSION 1.2h ASSEMBLY COMPLETE, 0 ERRORS FOUND`:

``` bash
bash start.sh # menu item "Check ./work/CODE.LST"
```

Иначе есть ошибки, смотри файл `./work/CODE.LST` полностью. Удачи.
