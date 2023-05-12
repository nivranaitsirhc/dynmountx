# Dynamic Mount ~ Changelog
## v1 - (v100104)
* enable global mirror tag
* refactor tag file heirarchy calls
* split version file checking for module base.apk and original.apk
## v1 - (v100103)
* added checks to prevent multiple manager.sh calls.
## v1 - (v100102)
* added debug tag file. this will transfer logging to internal storage
* added send notification function
## v1 - (v100101)
* minor changes in logging to be more readable.
## v1 - (v100100)
* app will now restart after bind or mount.
## v1 - (v100006)
* allowed tag file install of base apk only. orignal apk is now optional but it still recommended to be present. original apk is used to reinstall the base apk when google playstore forcefully update.
## v1 - (v100005)
* temporary fixed bug, version tags are not updated when install is invoke causing a loop install. a rubost checking will be added in the future.
## v1 - (v100004)
* improved code logics.
## v1 - (v100000)
* initial release.