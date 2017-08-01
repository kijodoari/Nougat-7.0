#!/system/bin/sh

on property:sys.boot_completed=1
    start sysinit
    start sick
    
service sysinit /sbin/sysinit.sh
    class late_start
    user root
    group root
    seclabel u:r:init:s0
    oneshot
    disabled

service sick /sbin/sick.sh
    class late_start
    user root
    group root
    seclabel u:r:init:s0
    oneshot
    disabled
