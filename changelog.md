# Dynamic Mount ~ Changelog
## v1.2.3_beta 
- 647e180 [fix] ensure bin dir is always present in MODPATH
- 6c9c457 [core] refactor customize.sh, match the required min magisk version to proc_monitor module
- 89fb936 [fix] fixed bug about install error due to incomplete removal code pertaining binaries
## v1.2.2_beta 
- 7d69d3f fixed bug about install error due to incomplete removal code pertaining binaries
- f5ad83c remove aapt2 from build
## v1.2.1_beta 
- 6c33016 remove appt2.zip
- 37ab97a removed binaries from the module zip, internet connection is now required.
- 9fce2e7 renamed beta_channel.zip to beta-channel.zip
## v1.2.0 
- 7288722 updated readme.md to reflect changes of debug tag file
- 17abd31 updated readme.md to reflect the new beta and release channel
- c0236a6 tweak build.sh
- 5ca51fa refactor module building.
- dcd93dc fix bug causing invalid json
- 69954ec fix update json format
- 572cca5 updated readme.md to reflect changes in v1.2.0
- f4ad1c7 enable support for other archetictures
- 4a69d3a updated readme to reflect v1.1.4_beta changes'
## v1.1.4_beta 
- 76eef41 enable global mirror tag rafactor tag file heirarchy split version file checking for module base and original apk
- 149be52 updated readme again
- 5ddd938 updated reame.
- c6a5da8 fixed typo path for debug tag file.
## v1.1.3_beta 
- cdb58f9 fixed typo for mounted tag file, and added return to skip the execution.
- eb91d01 added check to prevent multiple manager.sh calls.
## v1.1.2_beta 
- 2e6f455 added send notification function
- 45f962d enabled debug tag file. refactor logging logic
## v1.1.1_beta 
- d9f6405 refactor logging mechanism and made dynmount variable avaialbe globally removing the need to be defined in manager.sh
- 7dbae90 minor changes in logging to be more readable. skip loading script after app restart.
## v1.1.1 
- bc235af minor changes in logging to be more readable.
## v1.1.0 
- 337eff3 app will now restart after bind or install
## v1.0.6 
- bbed164 enable bind mode on tag file install
## v1.0.5 
- fb7e83d fixed bug: version_tags are not updated resulting in loop mount
## 01.00.00 - (v1.0.0)
- Initial Release
