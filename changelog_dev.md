# Dynamic Mount ~ Changelog
## v1.3.6 
- 4d6c499 [core]          
    - update service.sh to handle log more properly (nivranaitsirhc)  
- 229e4b6 [core]          
    - service.sh watch until sdcard is mounted. remove /data/apps watch (nivranaitsirhc)    
## v1.3.5 
- 38184b4 [core]          
    - wait until /data/app is available in service.sh (nivranaitsirhc)  
- ea922ac [core]          
    - fix bug causing logs to not output (nivranaitsirhc)    
## v1.3.4 
- c35915e [core]          
    - re-work service.sh (nivranaitsirhc)  
- 550b1b7 [core]          
    - respect module variables (nivranaitsirhc)  
- ef68663 [core]          
    - properly export var from dynmount.sh (nivranaitsirhc)  
- 77e2b40 [core]          
    - re-work tag parsing. merge bind_me and install_me. improve re-install handling. (nivranaitsirhc)  
- 4671b39 [core]          
    - re-work logging. debug logging will be included in releaseversion from now on. (nivranaitsirhc)  
- 3d51af9 [core]          
    - do not use magisk mirror (nivranaitsirhc)  
- c325fdc [core]          
    - reduce bootscript count to 2 instead of 10 (nivranaitsirhc)    
## v1.3.2 
- d85a0f7 [fix]           
    - update correct log function tag (nivranaitsirhc)  
- d656e1b [builder]       
    - update typo (nivranaitsirhc)  
- bf41820 [core]          
    - refactor tag checks, try to copy installed original.apk (nivranaitsirhc)    
## v1.3.1 
- 5f62607 [core]          
    - refactor install() & bind() (nivranaitsirhc)  
- a8a295c [core]          
    - refactor script exit (nivranaitsirhc)  
- a0c1bec [core]          
    - update logger to be per instance (nivranaitsirhc)    
## v1.3.0.rc.10 
- 18a9517 [fix]           
    - revert send_notification changes (nivranaitsirhc)    
## v1.3.0.rc.9 
- 9a9f7a7 [builder]       
    - change return 1 instead of exit 1 (nivranaitsirhc)  
- 6e190e1 [builder]       
    - stop building from anywhere (nivranaitsirhc)    
## v1.3.0.rc.8 
- 1793f4a [fix]           
    - fix typo causing install error (nivranaitsirhc)    
## v1.3.0.rc.7 
- 2e089f7 [core]          
    - add new tag: disable and enable. (nivranaitsirhc)  
- c0f9267 [fix]           
    - fix install error caused by typo. capture stderr to stdout in logging install and bind commands. refactor start_me() to accect noRestart flag (nivranaitsirhc)  
- 94b4a94 [fix]           
    - fix service.sh failing due to executing before bootcomplete (nivranaitsirhc)    
## v1.3.0.rc.6 
- 7900698 [core]          
    - move bootscript detection to dynmount.sh (nivranaitsirhc)    
## v1.3.0.rc.5 
- 438208b [fix]           
    - fix offline install copying bin into bin (nivranaitsirhc)    
## v1.3.0.rc.4 
- 959217a [core]          
    - utilize old bin if download of aapt2 fails (nivranaitsirhc)  
- ebcfb49 [core]          
    - add bootscript flag to prevent dynmount from running while service.sh is active (nivranaitsirhc)  
- bb66f1f [core]          
    - fix service.sh permission error and revert to ls in querying the packages (nivranaitsirhc)    
## v1.3.0.rc.3 
- 5fa35d3 [core]          
    - add tag file all, by default this prevents install to work profiles and other profiles (nivranaitsirhc)    
## v1.3.0.rc.2 
- 8fc2eab [builder]       
    - fix ./build error (nivranaitsirhc)    
## v1.3.0.rc.1 
- 660ce31 [core]          
    - prevent auto starting app after bootup (nivranaitsirhc)  
- 80607f3 [core]          
    - capture mount and install failure messages to logging (nivranaitsirhc)    
## v1.2.5 
- 3b12e85 [core]          
    - convert manager.sh as an executable (nivranaitsirhc)  
- 627e4a3 [core]          
    - refactor customize.sh (nivranaitsirhc)  
- a62a96d [fix]           
    - properly define MAGISKTMP and fix toxic PATH (nivranaitsirhc)  
- d3db936 [builder]       
    - remove sort from generating changelog_dev to preserve a sense of chronological history (nivranaitsirhc)  
- 23f4f19 [configs]       
    - fix typo update_beta.json pointing to changelog.md (nivranaitsirhc)    
## v1.2.4_beta 
- 9b31c52 [builder]       
    - include changelog_dev.md to release commit (nivranaitsirhc)  
- 8274899 [core]          
    - refactor debug messages and bind_me/install_me functions (nivranaitsirhc)  
- 55a8f96 [core]          
    - remove duplicate declaration path_file_tag_mounted (nivranaitsirhc)  
- c9e5dbc [fix]           
    - fix issue of logger prematurely exiting under certain conditions (nivranaitsirhc)  
- 8aa1d73 [feature]       
    - add cache clearing stage when mounting or installing apk (nivranaitsirhc)  
- c1731ae [builder]       
    - apply the same changelog stye to main (nivranaitsirhc)  
- bad8713 [builder]       
    - fix typo in build.sh beta update link still point to main (nivranaitsirhc)  
- 1bed53b [builder]       
    - update build.sh to new changelog format, now changelog and update stable will only point to main branch and beta will point to bleeding (nivranaitsirhc)  
- e9e2c65 [docs]          
    - update readme.md (nivranaitsirhc)  
- fbebd59 [configs]       
    - fix module.prop typo (nivranaitsirhc)  
- 5645a5c [builder]       
    - forgot to change echo to git (nivranaitsirhc)  
- 89644e3 [builder]       
    - fix typo during copy paste of module_beta.prop (nivranaitsirhc)  
- 1363608 [repository]    
    - add new meta to module.prop (nivranaitsirhc)  
- b4dd332 [builder]       
    - target changelog link to bleeding branch (nivranaitsirhc)  
- 67fd38c [builder]       
    - update changelog style and format (nivranaitsirhc)  
- 422d460 [builder]       
    - redirect update.json to bleeding branch. only stable will point to main. add relase param to build sh to auto commit changelog (nivranaitsirhc)  
- 82bf171 [builder]       
    - bump to v1.2.3_beta with fixes (nivranaitsirhc)  
- 99e93bc [docs]          
    - update readme.md (nivranaitsirhc)    
## v1.2.3_beta 
- 647e180 [fix]           
    - ensure bin dir is always present in MODPATH (nivranaitsirhc)  
- 075b080 [builder]       
    - add docs change logs exemptions (nivranaitsirhc)  
- 9079088 [builder]       
    - refactor build.sh to show correct changes of each tag (nivranaitsirhc)  
- 599bc7b [builder]       
    - implement new changelog generation mechanism (nivranaitsirhc)  
- 6c9c457 [core]          
    - refactor customize.sh, match the required min magisk version to proc_monitor module (nivranaitsirhc)  
- 99ad4d2 [repository]    
    - add .gitignore to exclude build and release folder (nivranaitsirhc)  
- ca383c0 [builder]       
    - apply release trim to all script instead of only the manager.sh (nivranaitsirhc)  
- 89fb936 [fix]           
    - fixed bug about install error due to incomplete removal code pertaining binaries (nivranaitsirhc)  
- 7a525e1 [repository]    
    - add .gitignore to exclude build and release folder (nivranaitsirhc)  
- df9871e [builder]       
    - apply release trim to all script instead of only the manager.sh (nivranaitsirhc)  
- 915eeb9 bump            
    - to v1.2.2_beta (nivranaitsirhc)    
## v1.2.2_beta 
- 7d69d3f fixed           
    - bug about install error due to incomplete removal code pertaining binaries (nivranaitsirhc)  
- f5ad83c remove          
    - aapt2 from build (nivranaitsirhc)  
- 086e819 bump            
    - to v1.2.1_beta (nivranaitsirhc)    
## v1.2.1_beta 
- 6c33016 remove          
    - appt2.zip (nivranaitsirhc)  
- e7a448a bump            
    - to v1.2.1_beta (nivranaitsirhc)  
- 37ab97a removed         
    - binaries from the module zip, internet connection is now required. (nivranaitsirhc)  
- 9fce2e7 renamed         
    - beta_channel.zip to beta-channel.zip (nivranaitsirhc)  
- f3942f5 bump            
    - to v1.2.0 (nivranaitsirhc)    
## v1.2.0 
- 7288722 updated         
    - readme.md to reflect changes of debug tag file (nivranaitsirhc)  
- 17abd31 updated         
    - readme.md to reflect the new beta and release channel (nivranaitsirhc)  
- c0236a6 tweak           
    - build.sh (nivranaitsirhc)  
- 5ca51fa refactor        
    - module building. (nivranaitsirhc)  
- dcd93dc fix             
    - bug causing invalid json (nivranaitsirhc)  
- 69954ec fix             
    - update json format (nivranaitsirhc)  
- 572cca5 updated         
    - readme.md to reflect changes in v1.2.0 (nivranaitsirhc)  
- 4039ba6 bump            
    - to v1.2.0 (nivranaitsirhc)  
- d5d1dfc bump            
    - to v1.2.0_beta (nivranaitsirhc)  
- f4ad1c7 enable          
    - support for other archetictures (nivranaitsirhc)  
- 4a69d3a updated         
    - readme to reflect v1.1.4_beta changes' (nivranaitsirhc)  
- 390abfd bump            
    - to v1.1.4_beta (nivranaitsirhc)    
## v1.1.4_beta 
- 76eef41 enable          
    - global mirror tag rafactor tag file heirarchy split version file checking for module base and original apk (nivranaitsirhc)  
- a9656ff bump            
    - to v1.1.3 (nivranaitsirhc)  
- 149be52 updated         
    - readme again (nivranaitsirhc)  
- 5ddd938 updated         
    - reame. (nivranaitsirhc)  
- c6a5da8 fixed           
    - typo path for debug tag file. (nivranaitsirhc)    
## v1.1.3_beta 
- cdb58f9 fixed           
    - typo for mounted tag file, and added return to skip the execution. (nivranaitsirhc)  
- e16269d bump            
    - to v1.1.3_beta (nivranaitsirhc)  
- eb91d01 added           
    - check to prevent multiple manager.sh calls. (nivranaitsirhc)    
## v1.1.2_beta 
- e05ab0d bump            
    - v1.1.2_beta (nivranaitsirhc)  
- 2e6f455 added           
    - send notification function (nivranaitsirhc)  
- 45f962d enabled         
    - debug tag file. refactor logging logic (nivranaitsirhc)    
## v1.1.1_beta 
- d9f6405 refactor        
    - logging mechanism and made dynmount variable avaialbe globally removing the need to be defined in manager.sh (nivranaitsirhc)  
- 7dbae90 minor           
    - changes in logging to be more readable. skip loading script after app restart. (nivranaitsirhc)    
## v1.1.1 
- bc235af minor           
    - changes in logging to be more readable. (nivranaitsirhc)    
## v1.1.0 
- c4928a6 bump            
    - to v1.1.0 (nivranaitsirhc)  
- 81555e8 bump            
    - to v1.1.0 (nivranaitsirhc)  
- 337eff3 app             
    - will now restart after bind or install (nivranaitsirhc)    
## v1.0.6 
- 9bdabdb bump            
    - to v1.0.6 (nivranaitsirhc)  
- bbed164 enable          
    - bind mode on tag file install (nivranaitsirhc)    
## v1.0.5 
- fcf6451 bump            
    - to v1.0.5 (nivranaitsirhc)  
- e899e38 bump            
    - to v1.0.5 (nivranaitsirhc)  
- fb7e83d fixed           
    - bug: version_tags are not updated resulting in loop mount (nivranaitsirhc)    
## v1.0.0
- Initial Release
