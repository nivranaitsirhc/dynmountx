# **Dynamic Mount Module for Magisk Android**

## Description
Dynamically Mount Revanced App.  
Assist Revanced Manager App in mounting when Detach is failing.  
Expanded approach with flexibility in mind.  
Requires Magisk Process Monitor Tool (Dynamic Mount) v2+.  

## Features
* Add any patched App.
* Run checks at every managed app process starts.
* Retainability.

## Requirements
* [Magisk](https://github.com/topjohnwu/Magisk) v25
* [Magisk Process Monitor Tool](https://github.com/Magisk-Modules-Alt-Repo/magisk_proc_monitor) v2+ by HuskyDG *(Can be Installed later but required for the the module to function)*
* [Dynamic Detach Module for Magisk Android](https://github.com/nivranaitsirhc/dyndetachx)
* ARM64 (for the moment)

## How to Install
1. Download the latest release
2. Install via Magisk Manager or Third Party Module Manager
3. create a folder in InternalStorage/DynamicMountX/apps. e.g. com.google.android.youtube
4. create a tag file in this folder named "install"
5. place your patached apk here and renamed it as base.apk, also place the original apk as original.apk
6. create a tag file in InternalStorage/DynamicMountX and named it enabled.
7. if your apk is not yet installed install it now manually.
8. Reboot


## How to Manage your patched Apps
- **UNDER CONSTRUCTION**


## Support
This script is provided as-is without warranty, but reporting bugs is highly appreciated.

## Donate
*A ``thank you`` can go beyond a thousand miles. Gestures are also highly appreciated.*
* [Buy Me a Coffee](https://www.buymeacoffee.com/caccabo "A caffine of excitement")
* [Paypal](https://paypal.me/caccabo "PayPal")

## Credits & Thanks
* [Magisk](https://github.com/topjohnwu/Magisk)
* [Magisk Process Monitor Tool](https://github.com/Magisk-Modules-Alt-Repo/magisk_proc_monitor)
