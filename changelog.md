# Dynamic Mount ~ Changelog
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
- ebcfb49 [core]          
    - add bootscript flag to prevent dynmount from running while service.sh is active (nivranaitsirhc)  
- bb66f1f [core]          
    - fix service.sh permission error and revert to ls in querying the packages (nivranaitsirhc)  
- 959217a [core]          
    - utilize old bin if download of aapt2 fails (nivranaitsirhc)    
## v1.3.0.rc.3 
- 5fa35d3 [core]          
    - add tag file all, by default this prevents install to work profiles and other profiles (nivranaitsirhc)    
## v1.3.0.rc.1 
- 80607f3 [core]          
    - capture mount and install failure messages to logging (nivranaitsirhc)  
- 660ce31 [core]          
    - prevent auto starting app after bootup (nivranaitsirhc)    
## v1.2.5 
- 3b12e85 [core]          
    - convert manager.sh as an executable (nivranaitsirhc)  
- 627e4a3 [core]          
    - refactor customize.sh (nivranaitsirhc)  
- a62a96d [fix]           
    - properly define MAGISKTMP and fix toxic PATH (nivranaitsirhc)    
## v1.2.4_beta 
- 8274899 [core]          
    - refactor debug messages and bind_me/install_me functions (nivranaitsirhc)  
- 55a8f96 [core]          
    - remove duplicate declaration path_file_tag_mounted (nivranaitsirhc)  
- 8aa1d73 [feature]       
    - add cache clearing stage when mounting or installing apk (nivranaitsirhc)  
- c9e5dbc [fix]           
    - fix issue of logger prematurely exiting under certain conditions (nivranaitsirhc)    
## v1.2.3_beta 
- 6c9c457 [core]          
    - refactor customize.sh, match the required min magisk version to proc_monitor module (nivranaitsirhc)  
- 647e180 [fix]           
    - ensure bin dir is always present in MODPATH (nivranaitsirhc)  
- 89fb936 [fix]           
    - fixed bug about install error due to incomplete removal code pertaining binaries (nivranaitsirhc)    
## v1.0.0
- Initial Release
