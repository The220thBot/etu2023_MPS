# Install

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
sudo apt install winetricks
```

[См. тут](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/) более подробно или для других дистрибутивов.

# Configure

Создайте папку `$HOME/shit`.

Разорхивируйте `ADUC.zip` в папку: `$HOME/shit`.

Создайте папку `$HOME/shit/pfx`.

Запустите:

``` bash
WINEPREFIX=$HOME/shit/pfx WINEARCH="win32" winecfg
```

Предложат установить `Wine Mono Installer`, отклоните. Далее выбирите Windows Version: `Windows XP`.

Закройте `winecfg`.

Создайте папку: `$HOME/shit/pfx/drive_c/shit`.

Выполните команды:

``` bash
cp -r $HOME/shit/ADUC/ADSIM812/ $HOME/shit/pfx/drive_c/shit
cp -r $HOME/shit/ADUC/ASM51/ $HOME/shit/pfx/drive_c/shit
mkdir $HOME/shit/pfx/drive_c/shit/work
cp $HOME/shit/ADUC/TEST/MOD* $HOME/shit/pfx/drive_c/shit/work
# Возможно что-то ещё надо
```

# Запуск эмулятора ADSIM812.EXE

Попробуйте запустить:

``` bash
cd "$HOME/shit/pfx/drive_c/shit/work"
WINEPREFIX=$HOME/shit/pfx WINEARCH="win32" wine "$HOME/shit/pfx/drive_c/shit/ADSIM812/ADSIM812.EXE"
```

Если получилось, то переходим дальше, иначе пробуем дебажить, иначе ставим Windows XP на виртуалку.

# Компиляция

Создайте тестовый файл `$HOME/shit/pfx/drive_c/shit/work/test.asm`:

``` asm
$mod52

	ORG 0h
M1:
        MOV 	DPTR, #init
	MOV 	R0, #8
	MOV 	R1, #20h
LOOP:
	MOV 	A, #0
	MOVC 	A, @A+DPTR
	MOV 	@R1, A
	INC 	DPTR
	INC 	R1
	DJNZ 	R0,LOOP
	JMP 	M1

	ORG 1000h
init:
	DB 1,2,3,4,5,6,7,8
	END
```

## Тихая без интерактива

Создайте скрипт `$HOME/shit/start.sh` со следующим содержимым:

``` bash
#!/bin/bash
export LABFILE=test.asm
cp "$HOME/shit/pfx/drive_c/shit/work/$LABFILE" "$HOME/shit/pfx/drive_c/shit/ASM51/$LABFILE"
cd "$HOME/shit/pfx/drive_c/shit/ASM51"
WINEPREFIX=$HOME/shit/pfx WINEARCH="win32" wine ASM51.EXE $LABFILE
export LABFILE_NAME="${LABFILE%.*}"
export LABFILE_BIG_NAME=${LABFILE_NAME^^}
cp $LABFILE_BIG_NAME.??? ../work
# В папке work будут "TEST.HEX" и "TEST.LST" файлы.
echo "Look $LABFILE_BIG_NAME.HEX and $LABFILE_BIG_NAME.LST in $HOME/shit/pfx/drive_c/shit/work/"
export COMPILE_RES=$(cat $HOME/shit/pfx/drive_c/shit/work/$LABFILE_BIG_NAME.LST | grep "0 ERRORS FOUND")
if [ -z "$COMPILE_RES" ]
then
      echo "!!!Error while compile!!!"
      echo "Content of $LABFILE_BIG_NAME.LST:"
      echo "\"\"\""
      echo $(cat $HOME/shit/pfx/drive_c/shit/work/$LABFILE_BIG_NAME.LST)
      echo "\"\"\""
      echo "Compilled: ERROR"
else
      echo "Compilled: OK"
fi
```

Чтобы скомпилировать положите в папку `$HOME/shit/pfx/drive_c/shit/work/` файл `test.asm` (или другой, поменяйте строку `export LABFILE=test.asm`, как необходимо, в скрипте выше). И запустите:

``` bash
bash $HOME/shit/start.sh
```

Если ошибок нет, то в файле `$HOME/shit/pfx/drive_c/shit/work/TEST.LST` можно найти строку `VERSION 1.2h ASSEMBLY COMPLETE, 0 ERRORS FOUND`:

``` bash
cat $HOME/shit/pfx/drive_c/shit/work/TEST.LST

# look line:
#      "VERSION 1.2h ASSEMBLY COMPLETE, 0 ERRORS FOUND"
```

Иначе есть ошибки, смотри файл `$HOME/shit/pfx/drive_c/shit/work/TEST.LST` полностью.
