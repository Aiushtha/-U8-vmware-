因为节省升级费用与特殊要求业务环境要求使用虚拟机
但是使用过程中总是出现磁盘空间被占满
为了保证机器最大性能运转,研究了一下解决方案


在现有不更换设备下的方案解决办法（主机是win10系统如果是其他系统请注意代替方案和参数修改）

  * ###解决方案
     * ### 方案1:将虚拟机移动到机械硬盘设置内存替换I/O读写提高性能
     * ### 方案2:虚拟机放在固态硬盘,用脚本拷贝出备份文件并自动整理虚拟机磁盘碎片并自动压缩整理然后自动重启
         * 定时脚本
         * 环境配置
         * 通过共享文件移动备份文件
         * U8重启脚本
         
方案2流程图  
![IMAGE](resources/4CBD58E1B181B0AC0822DDFB2524AA88.jpg =914x374)

#### ================================我是分割线================================


## 方案1
  * 将虚拟移动到机械硬盘,但虚拟机运行将会变得卡顿
  * 关闭虚拟机添加参数(用内存代替I/O读写)重启虚拟机
  
这个方案虽然可以保证虚拟机运行稳定及时I/O读写占满100%但毕竟使用机械硬盘性能方面依然不是最佳

修改虚拟机下面.vmx 文件
追加参数内存替换I/O读写 (注意这个选项在VM15以上可在选项里选择)
```
 mainMem.useNamedFile="FALSE"
 MemTrimRate="0"
 prefvmx.useRecommendedLockedMemSize="true"
 MemAllowAutoScaleDown="FALSE"
 
```

mainMem.useNamedFile: 把这个参数的值设为 "FALSE" 可以让 VMware 不再创建 .vmem 文件。这样有助于减少虚拟机关机时的硬盘操作，但这么做只对 Windows 宿主系统有效。如果你的宿主系统是 Linux，建议用这个配置：mainmem.backing = "swap"。
MemTrimRate: 这项优化会使客机释放的内存在宿主机得不到释放。
prefvmx.useRecommendedLockedMemSize: 很遗憾，这项优化没给出什么解释。貌似会阻止宿主系统把客机系统的部分内存进行内存换页。
MemAllowAutoScaleDown: 阻止 VMware 在申请不到内存的时候自动调整虚拟机的内存大小。
sched.mem.pshare.enable: 如果同时有多台虚拟机运行，VMware 会尝试找到它们之间相同的内存页，并且在共享这些页。但这是个 I/O 消耗很大的操作。
添加参数

参考网站:https://wiki.archlinux.org/index.php/VMware/Installing_Arch_as_a_guest_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

![IMAGE](resources/7BB98A0B9ADB6F70A19F28E36E45E833.jpg =1491x582)



如下图 将虚拟机放在机械盘为修改参数前 读写占到100%
![IMAGE](resources/0A8E3C85AC1BBB1EC74C9DDD25E90125.png =400x300)

修改完参数以后峰值明显下降,即便I/O读写到100% 操作以后也不会出现阻塞
![IMAGE](resources/F2AFACFE1D88D0CBA695E69A8FF0E620.png =400x300)



#### ================================我是分割线================================


## 方案2

* 步骤
  * 1 将现有的win10系统激活 卸载主机上无用的软件 
  * 2 并作磁盘整理 （修改虚拟机上文件格式修改合并为单个文件）
  * 3 对现有虚拟机进行磁盘整理和压缩
  * 4 将虚拟机从机械硬盘拷贝到固态硬盘C盘或者修改配置详情见https://www.cnblogs.com/jerryqi/p/9613641.html
  * 5 使用脚本自动对虚拟机进行磁盘自动整理
  * 6 设置共享文件夹将虚拟机中的脚本将重要的大文件数据移动到机械硬盘

* 其他相关问题处理
  * 将U盘默认设置连接虚拟机 https://jingyan.baidu.com/article/5d368d1e87cb023f60c057e4.html



这是压缩前的我拷到移动硬盘上的
![IMAGE](resources/33B8669D3B116DC73535B5AA203E58D7.jpg =402x540)
这是实际压缩后的大小

![IMAGE](resources/542B6A8C39225613FDDA6DF96234199A.jpg =399x537)



自动化脚本指令如下


具体代码如下
在"我的电脑" D盘下 新建VMScript.bat文件内容如下
>将以下的文件路径修改为自己本机的对应文件的路径 
>有加密狗的话安装devcon.exe来自动化usb问题 

```
@echo off
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
##环境配置:

按下win+R输入taskschd.msc打开计划任务将刚才的VMScript.bat加入到计划任务,选择触发时间

选择不管用户是否登录都要运行的选项的时候，一定不能选不记住密码，一定要把密码添加上，否则就会不好用。
![IMAGE](resources/62EBA04124A6CDDBFE073C9AB48C6CA9.jpg =1003x777)




加密狗解决方案:

需要安装Windowsdrivers-Windows驱动程序工具包(WDK)-Windowsdrivers下载地址见
https://docs.microsoft.com/zh-cn/windows-hardware/drivers/download-the-wdk

如果觉得devcon.exe太大可以下载devcon_x64_without_ddk绿色版,指令是一样的


这是我用devcon_x64_without_ddk.exe模拟弹出“大白菜U盘”  效果图 在主机上亲测可用 如下 
![GIF.gif](resources/860EBC8BA7F8EC3B65E4378A9A6F6353.gif =412x303)


首先点击vmware左上角菜单栏点击编辑和查看->首选项(部分VM版本是右键虚拟机->设置->USB)
选择将设备
![IMAGE](resources/A5F360F1693AE0ED48880C983AE3CCE2.jpg =728x461)

弹出所有USB并重新加载(注意别复制脚本里运行,不然你鼠标键盘不能动就没法再输入命令了)
代码:
>devcon remove USB\*
>devcon rescan USB\*



## 通过共享文件移动备份文件

虚拟机里会定时产生备份文件大的有几十G影响性能 我们可以把它从虚拟机里移动到主机的机械盘上
可以用DOS编写定时计划任务
首先右键虚拟机选择主机共享文件夹添加主机共享给虚拟机并映射为Z盘

![IMAGE](resources/66BAA9D6360445828AF7EA98232C10C4.jpg =642x705)



调用命令示例
>xcopy  D:\\xxx Z:\\xxx  /y /e /i /q
>del D:\\xxx /f /s /q


## 关闭window上优化器
按下win+R(mac版键盘按fn+command+x)
cleanmgr
输入dfrgui点击优化 弹出界面 如下图
然后将自动优化驱动器等设置关闭掉(我们已经用bat脚本执行defrag C: /U /V定时更新)


![IMAGE](resources/58A6147A95540818D99A0FAF861138B8.jpg =698x513)
![IMAGE](resources/4DBCFFB4CEEF62D4EAE29A0CD4E72FCA.jpg =453x292)



## U8重启脚本

压缩虚拟机以后U8有时会无法启动找不到数据源需要等虚拟机加载运行几分钟就正常了。
打开虚拟机右下角小图标里有一个U8小图标点全部暂停服务再点全部启动就可以使用了
重启U8服务即可 代码网上抄的如下
```
将以下代码复制到记事本中，另存为.BAT或.CMD文件。 
双击运行即可启动U8 服务。 
———————————————————— 
@title U8 Starting...
@net start U8AuthServer
@net start U8DispatchService
@net start U8KeyManagePool
@net start U8MPool
@net start U8SCMPool
@net start U8TaskService
@net start UFReportService
@title U8 Started.
@pause 
———————————————————— 
将以下代码复制到记事本中，另存为.BAT或.CMD文件。 
双击运行即可停止U8 服务。 
———————————————————— 
@title U8 Stopping...
@net stop U8AuthServer
@net stop U8DispatchService
@net stop U8KeyManagePool
@net stop U8MPool
@net stop U8SCMPool
@net stop U8TaskService
@net stop UFReportService
@title U8 Stopped.
@pause
```