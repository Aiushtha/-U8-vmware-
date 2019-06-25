
详细说明见：https://blog.csdn.net/b275518834/article/details/93627798

 ![image](http://aiushtha-mybook.stor.sinaapp.com/U8-Vmware/resources/4CBD58E1B181B0AC0822DDFB2524AA88.jpg)


```
@echo off
::获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"
rem

set vmwareWorkerDirPath=D:\\Program Files (x86)\\VMware\VMware Workstation
set virtualMachinePath=F:\\Windows Server 2008 R2 x64
set vmrunExePath=%vmwareWorkerDirPath%\\vmrun.exe
set vdiskmanagerExePath=%vmwareWorkerDirPath%\\vmware-vdiskmanager.exe
set vmdkFilePath=%virtualMachinePath%\\Windows Server 2008 R2 x64.vmdk
set vmxFilePath=%virtualMachinePath%\\Windows Server 2008 R2 x64.vmx

set defragCommand=defrag F: /U /V
set closeVmwareCommand="%vmrunExePath%" stop "%vmxFilePath%"  gui
set startVmwareCommand="%vmrunExePath%" start "%vmxFilePath%" gui
set startVdiskCommand="%vdiskmanagerExePath%" -k "%vmdkFilePath%"


set devconExePath=C:\Users\linxingzhu\Desktop\devcon\devcon_x64_without_ddk.exe
set usbDeviceID="USB\VID_0E0F&PID_0001"


set devconRemoveUsb="%devconExePath%" remove USB\*
set devconReScanUsb="%devconExePath%" rescan USB\*


echo ==========================
echo vm工作目录=%vmwareWorkerDirPath%
echo 虚拟机文件目录=%virtualMachinePath%
echo vmrun路径=%vmrunExePath%
echo 虚拟机磁盘整理=%vdiskmanagerExePath%
echo 虚拟机硬盘文件vmdk路径=%vmdkFilePath%
echo 虚拟机配置文件vmx路径"=%vmxFilePath%
echo ==========================
echo defragCommand=%defragCommand%
echo closeVmwareCommand=%closeVmwareCommand%
echo startVmwareCommand=%startVmwareCommand%
echo startVdiskCommand=%vdiskmanagerExePath%
echo ==========================
echo devconRemoveUsb=%devconRemoveUsb%
echo devconReScanUsb=%devconReScanUsb%
echo ==========================


TIMEOUT /T 10 /NOBREAK

echo 关闭虚拟机
%closeVmwareCommand%

TIMEOUT /T 30 /NOBREAK

echo 整理虚拟机文件
%startVdiskCommand%

echo 磁盘整理
%defragCommand%

TIMEOUT /T 100 /NOBREAK

echo 开启虚拟机
%startVmwareCommand%

TIMEOUT /T 300 /NOBREAK

echo 弹出USB
%devconRemoveUsb%
TIMEOUT /T  5
echo 重新加载USB
%devconReScanUsb%

EXIT
```