@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot
set boot_Magiskpatched=.\boot
set Magisk_source=.\source\Magisk_flies
set aria=.\source\aria2
set payload=.\source\payload
set 7z=.\source\7zip

:start
CLS
rd /s /q %Magisk_source%\Magisk
del /q %Magisk_source%\magisk_lib.zip
set /p payload_file=请输入您的payload.bin路径:
title 全自动刷入magisk_V2---by badnng
echo.
echo.          全自动刷入magisk_V2
echo.                               by badnng
echo.按A键开始进行内核版本小于5.15版本的boot全自动刷入~
echo.按B键开始进行内核版本大于或等于5.15版本的init_boot全自动刷入~

:Nopatch_flies
echo.
echo.获取最新文件
%aria%\aria2c.exe -x 16 -c --file-allocation=none -o magisk_lib.zip -d %Magisk_source% https://hub.gitmirror.com/https://github.com/badnng/Tools_library_download/releases/download/test/magisk_lib.zip
%aria%\aria2c.exe -x 16 -c --file-allocation=none -o Magisk.apk -d %Magisk_source% https://hub.gitmirror.com/https://github.com/badnng/Tools_library_download/releases/download/test/Magisk.apk
echo.请输入选项:
if exist %Magisk_source%\magisk_lib.zip (
    choice /C AB /N /M ""
    goto flash_boot
    if errorlevel 2 goto flash_initboot
) else (
    goto Nopatch_flies
)

:flash_boot
CLS
echo. 正在检测授权，如未授权，会卡在这不动或报错，请知晓
%adb-tools%\adb devices
echo. 安装Magisk，如安装失败，请确保是否给电脑授权usb安装或系统管家拦截（如MIUI，HyperOS）
%adb-tools%\adb install %Magisk_flies%/Magisk.apk
echo. 解压所需文件
.\source\7zip\7z x .\source\Magisk_flies\magisk_lib.zip -o.\source\Magisk_flies && REM 解压magisk-lib文件
echo. 修补并提取boot
%adb-tools%\adb shell rm -r /data/local/tmp/Magisk
%payload%\payload-dumper-go.exe -p boot -o %boot_origin% %payload_file%
%adb-tools%\adb push .\source\Magisk_flies\Magisk\ /data/local/tmp && REM 推送脚本
%adb-tools%\adb push %boot_origin%\boot.img /data/local/tmp/Magisk && REM 推送boot
%adb-tools%\adb shell chmod +x /data/local/tmp/Magisk/* && REM 给权限
%adb-tools%\adb shell /data/local/tmp/Magisk/boot_patch.sh boot.img && REM 执行脚本
%adb-tools%\adb pull /data/local/tmp/Magisk/new-boot.img %boot_Magiskpatched%\boot.img && REM 拉取镜像
%adb-tools%\adb shell rm -r /data/local/tmp/Magisk/

echo. 刷入boot
echo. 设备将在10秒内重启进入fastboot，在此期间请不要拔出数据线!
timeout /t 10 >nul
echo. 重启进入fastboot
%adb-tools%\adb reboot bootloader
echo. 等待开机刷入boot
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot.img
echo. 重启进入设备
%adb-tools%\fastboot reboot

goto end

:flash_initboot
CLS
echo. 正在检测授权，如未授权，会卡在这不动或报错，请知晓
%adb-tools%\adb devices
echo. 安装Magisk，如安装失败，请确保是否给电脑授权usb安装或系统管家拦截（如MIUI，HyperOS）
%adb-tools%\adb install %Magisk_flies%/Magisk.apk
echo. 解压所需文件
.\source\7zip\7z x .\source\Magisk_flies\magisk_lib.zip -o.\source\Magisk_flies && REM 解压magisk-lib文件
echo. 修补并提取boot
%payload%\payload-dumper-go.exe -p init_boot -o %boot_origin% %payload_file%
%adb-tools%\adb push .\source\Magisk_flies\Magisk\ /data/local/tmp && REM 推送脚本
%adb-tools%\adb push %boot_origin%\init_boot.img /data/local/tmp/Magisk && REM 推送boot
%adb-tools%\adb shell chmod +x /data/local/tmp/Magisk/* && REM 给权限
%adb-tools%\adb shell /data/local/tmp/Magisk/boot_patch.sh init_boot.img && REM 执行脚本
%adb-tools%\adb pull /data/local/tmp/Magisk/new-boot.img %boot_Magiskpatched%\init_boot.img && REM 拉取镜像
%adb-tools%\adb shell rm -r /data/local/tmp/Magisk/

echo. 刷入boot
echo. 设备将在10秒内重启进入fastboot，在此期间请不要拔出数据线!
timeout /t 10 >nul
echo. 重启进入fastboot
%adb-tools%\adb reboot bootloader
echo. 等待开机刷入init_boot(AB通刷，支持K60U，Note13Pro+等机型)
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\init_boot.img
echo. 重启进入设备
%adb-tools%\fastboot reboot
goto end

:end
CLS
echo.    是否删除payload.bin文件？(Y删除/N不删)
choice /c YN

if errorlevel 2 (
    echo 正在删除残留文件
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
) else (
    echo 删除文件
    del /s /q %payload_file%
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
)
echo.    执行完毕，希望大大用的开心呀
echo.    有能力的话关注一下我的b站呗，或者去酷安搜索badnng关注我，如果大佬能请我喝瓶矿泉水的话，我会加倍感谢你的！
start .\source\QRCode\cd85617e1d34b8ebe63db88c22abd09.png
taskkill -f -im adb.exe
echo.    本窗口将在6秒钟关闭~
timeout /t 6 >nul
explorer "https://space.bilibili.com/355631279?spm_id_from=333.1007.0.0"
