# **Dynamic Mount Module for Magisk Android**

## Description
- Dynamically mount any patched apk every process start.  
- Remount patched apk when unmounted.
- Re-install apk when the app is forcefully auto-updated *(requires original apk)*.
- Expanded approach with flexibility in mind.  
- Requires Magisk Process Monitor Tool (Dynamic Mount) v2+.  

## Features
- [x] Support any patched apk.
- [x] Run checks at every app process starts.
- [x] Ensures that apk will always be mounted.
- [x] Configurable via Tag Files *(no need to access magisk module directory or terminal)*
- [x] Works without any Detach Module, but highly recommended to paired with one. *(since this module will reinstall the orignal apk once a mismatch is detected)*

## Future-Features
- [ ] Auto integration with [Dynamic Detach Module for Magisk Android](https://github.com/nivranaitsirhc/dyndetachx)


## Requirements
* [Magisk](https://github.com/topjohnwu/Magisk) *(min. v24.3)*
* [Magisk Process Monitor Tool](https://github.com/HuskyDG/zygisk_proc_monitor) v2+ by HuskyDG *(Can be Installed later but required for the the module to function)*
* **Internet connection is required when installing the module.**  
<sup>*(since v1.2.1 binaries are no longer shipped with the module to reduce the file size.)*</sup>

## Requirements (optional)
* [Dynamic Detach Module for Magisk Android](https://github.com/nivranaitsirhc/dyndetachx)

## How to Install
1. Download the latest release
    - ``Beta Channel`` - Active Changes (Prone to bugs).
    - ``Release Channel`` - Only Major Changes (Most Stable).
2. Install via Magisk Manager or Third Party Module Manager
3. create a folder in ``InternalStorage/DynamicMountX/apps``.
<br><sup>*(e.g. com.google.android.youtube)*</sup>
4. create a an empty file in this folder name it ``install``.
<br><sup>*(e.g. InternalStorage/DynamicMountX/apps/com.google.android.youtube/install)*</sup>
<br><sup>*(Note: the unpatached apk must be installed regardless of version)*</sup>
5. place your patached apk here and rename it to base.apk, also place the original & unpacthed apk to original.apk
<br><sup>*(the original apk will be used to downgrade the installed app to the correct version)*</sup>
6. create an empty file in ``InternalStorage/DynamicMountX`` and name it ``enable``.
<br><sup>*(e.g. InternalStorage/DynamicMountX/enable)*</sup>
7. if your apk is not yet installed, install it now manually.
8. Reboot
9. Start the App. (It will close and wait for it to restart.)

<sub> If you want to load the logs. create an empty file into ``InternalStorage/DynamicMountX`` and name it ``debug``. This will copy the module.log into this directory.</sub>


## How to Manage your patched Apps
You can manage your apps using tag files. Tag files are just empty files that are read by the module to perform certain operations.  
  
<sup>*Please note that enabling the tag files will create an overhead delay when starting your application. Please remove the ``enable`` tag one the operation is done.*</sup>  
<sup>*Some tag files will be removed or renamed depending on the success of the task.*</sup>
### Internal Storage Folder Structure
```
InternalStorage/
        |-DynamicMountX/                        {directory} (create this folder if not present)
               |-enable                         {tag file}
               |-mirror                         {tag file}
               |-debug                          {tag file}
               |-module.log                     {log file}
               |-apps/                          {directory} (create this folder if not present)
                    |-com.google.android.apps.youtube.music/
                    |            |-skip         {tag file}
                    |            |-......
                    |-com.google.android.youtube/
                                 |-base.apk     {patched apk for mounting}(required for install operation)
                                 |-original.apk {orignal apk for version retention}(optional)
                                 |-skip         {tag file}
                                 |-force        {tag file}(will be removed after task completes)
                                 |-mirror       {tag file}(will be removed after task completes)
                                 |-remove       {tag file}(will be replaced after task completes)
                                 |-install      {tag file}(will be removed after task completes)
```
### Tag Files - DynamicMountX
These tag file can be used only in a special folder inside your Internal Storage named ``DynamicMountX``. If not present please create it.
- ``enable``
<br><sup>This will enable the recognation of tag files, if not present all tag files will be ignored</sup>
- ``debug``
<br><sup>This will copy the module log into DynamicMountX directory. *(Note: Applicable only to Beta Channel Releases)*</sup>
- ``mirror``
<br><sup>mirror's all the pacakage name directory handled by the module into this ``apps`` directory.</sup>
### Tag Files - App Level
These tag file can be used only inside the pacakge name folder inside the ``apps`` directory.
<br><sup>(e.g. Youtube - *InternalStorage/DynamicMountX/apps/com.google.android.youtube*)</sup>
- ``skip``
<br><sup>Skip the app from any operations.</sup>
- ``force``
<br><sup>Force the app mounting. Ignores version checking and mount checking.</sup>
- ``mirror``
<br><sup>Mirror's the apps module directory into this directory.</sup>
- ``remove``
<br><sup>Remove the module apps directory. essentially permanently removing the app from the module.</sup>
- ``install``
<br><sup>Install/Re-install's the apk from this directory and replaces the module copy.</sup>
<br><sup>Note: *if only the base.apk is present, this specific app will only be in bind mode. Meaning the module will not be able maintain the app version if ever this app will be auto upgraded by playstore.*</sup>

## Warranty
This script is provided as-is without warranty.
Reporting bugs will be highly appreciated.

## Support
* [Buy Me a Coffee](https://www.buymeacoffee.com/caccabo "A caffine of excitement")
* [Paypal](https://paypal.me/caccabo "PayPal")

## Credits & Thanks
* [Magisk](https://github.com/topjohnwu/Magisk)
* [Magisk Process Monitor Tool](https://github.com/HuskyDG/zygisk_proc_monitor)
