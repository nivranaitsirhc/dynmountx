# Dynamic Mount ~ Changelog
## v1.2.3_beta 
- 075b080 [builder]       
    - add docs change logs exemptions (nivranaitsirhc)  
- ca383c0 [builder]       
    - apply release trim to all script instead of only the manager.sh (nivranaitsirhc)  
- df9871e [builder]       
    - apply release trim to all script instead of only the manager.sh (nivranaitsirhc)  
- 599bc7b [builder]       
    - implement new changelog generation mechanism (nivranaitsirhc)  
- 9079088 [builder]       
    - refactor build.sh to show correct changes of each tag (nivranaitsirhc)  
- 6c9c457 [core]          
    - refactor customize.sh, match the required min magisk version to proc_monitor module (nivranaitsirhc)  
- 647e180 [fix]           
    - ensure bin dir is always present in MODPATH (nivranaitsirhc)  
- 89fb936 [fix]           
    - fixed bug about install error due to incomplete removal code pertaining binaries (nivranaitsirhc)  
- 7a525e1 [repository]    
    - add .gitignore to exclude build and release folder (nivranaitsirhc)  
- 99ad4d2 [repository]    
    - add .gitignore to exclude build and release folder (nivranaitsirhc)  
- 915eeb9 bump            
    - to v1.2.2_beta (nivranaitsirhc)    
## v1.2.2_beta 
- f5ad83c remove          
    - aapt2 from build (nivranaitsirhc)  
- 7d69d3f fixed           
    - bug about install error due to incomplete removal code pertaining binaries (nivranaitsirhc)  
- 086e819 bump            
    - to v1.2.1_beta (nivranaitsirhc)    
## v1.2.1_beta 
- 6c33016 remove          
    - appt2.zip (nivranaitsirhc)  
- 37ab97a removed         
    - binaries from the module zip, internet connection is now required. (nivranaitsirhc)  
- 9fce2e7 renamed         
    - beta_channel.zip to beta-channel.zip (nivranaitsirhc)  
- f3942f5 bump            
    - to v1.2.0 (nivranaitsirhc)  
- e7a448a bump            
    - to v1.2.1_beta (nivranaitsirhc)    
## v1.2.0 
- 5ca51fa refactor        
    - module building. (nivranaitsirhc)  
- dcd93dc fix             
    - bug causing invalid json (nivranaitsirhc)  
- 69954ec fix             
    - update json format (nivranaitsirhc)  
- f4ad1c7 enable          
    - support for other archetictures (nivranaitsirhc)  
- 4a69d3a updated         
    - readme to reflect v1.1.4_beta changes' (nivranaitsirhc)  
- 572cca5 updated         
    - readme.md to reflect changes in v1.2.0 (nivranaitsirhc)  
- 7288722 updated         
    - readme.md to reflect changes of debug tag file (nivranaitsirhc)  
- 17abd31 updated         
    - readme.md to reflect the new beta and release channel (nivranaitsirhc)  
- 390abfd bump            
    - to v1.1.4_beta (nivranaitsirhc)  
- 4039ba6 bump            
    - to v1.2.0 (nivranaitsirhc)  
- d5d1dfc bump            
    - to v1.2.0_beta (nivranaitsirhc)  
- c0236a6 tweak           
    - build.sh (nivranaitsirhc)    
## v1.1.4_beta 
- c6a5da8 fixed           
    - typo path for debug tag file. (nivranaitsirhc)  
- 76eef41 enable          
    - global mirror tag rafactor tag file heirarchy split version file checking for module base and original apk (nivranaitsirhc)  
- 149be52 updated         
    - readme again (nivranaitsirhc)  
- 5ddd938 updated         
    - reame. (nivranaitsirhc)  
- a9656ff bump            
    - to v1.1.3 (nivranaitsirhc)    
## v1.1.3_beta 
- eb91d01 added           
    - check to prevent multiple manager.sh calls. (nivranaitsirhc)  
- cdb58f9 fixed           
    - typo for mounted tag file, and added return to skip the execution. (nivranaitsirhc)  
- e16269d bump            
    - to v1.1.3_beta (nivranaitsirhc)    
## v1.1.2_beta 
- 2e6f455 added           
    - send notification function (nivranaitsirhc)  
- 45f962d enabled         
    - debug tag file. refactor logging logic (nivranaitsirhc)  
- e05ab0d bump            
    - v1.1.2_beta (nivranaitsirhc)    
## v1.1.1_beta 
- d9f6405 refactor        
    - logging mechanism and made dynmount variable avaialbe globally removing the need to be defined in manager.sh (nivranaitsirhc)  
- 7dbae90 minor           
    - changes in logging to be more readable. skip loading script after app restart. (nivranaitsirhc)    
## v1.1.1 
- bc235af minor           
    - changes in logging to be more readable. (nivranaitsirhc)    
## v1.1.0 
- 337eff3 app             
    - will now restart after bind or install (nivranaitsirhc)  
- 81555e8 bump            
    - to v1.1.0 (nivranaitsirhc)  
- c4928a6 bump            
    - to v1.1.0 (nivranaitsirhc)    
## v1.0.6 
- bbed164 enable          
    - bind mode on tag file install (nivranaitsirhc)  
- 9bdabdb bump            
    - to v1.0.6 (nivranaitsirhc)    
## v1.0.5 
- fb7e83d fixed           
    - bug: version_tags are not updated resulting in loop mount (nivranaitsirhc)  
- e899e38 bump            
    - to v1.0.5 (nivranaitsirhc)  
- fcf6451 bump            
    - to v1.0.5 (nivranaitsirhc)    
## v1.0.0
- Initial Release
