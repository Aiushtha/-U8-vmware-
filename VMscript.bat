@echo off

::��ȡ����ԱȨ��
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
echo vm����Ŀ¼=%vmwareWorkerDirPath%
echo ������ļ�Ŀ¼=%virtualMachinePath%
echo vmrun·��=%vmrunExePath%
echo �������������=%vdiskmanagerExePath%
echo �����Ӳ���ļ�vmdk·��=%vmdkFilePath%
echo ����������ļ�vmx·��"=%vmxFilePath%
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

echo �ر������
%closeVmwareCommand%

TIMEOUT /T 30 /NOBREAK

echo ����������ļ�
%startVdiskCommand%

echo ��������
%defragCommand%

TIMEOUT /T 100 /NOBREAK

echo ���������
%startVmwareCommand%

TIMEOUT /T 300 /NOBREAK

echo ����USB
%devconRemoveUsb%
TIMEOUT /T  5
echo ���¼���USB
%devconReScanUsb%

EXIT
```