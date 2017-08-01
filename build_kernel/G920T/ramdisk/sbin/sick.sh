#!/system/bin/sh

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# Modified by The Sickness for Twisted kernels thanks to @Noxxious

if [ ! -f /su/xbin/busybox ]; then
	BB=/system/xbin/busybox;
else
	BB=/su/xbin/busybox;
fi;

#####################################################################
# Mount root as RW to apply tweaks and settings
if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

#####################################################################
# Make Kernel Data Path

if [ ! -d /data/.sick ]; then
	$BB mkdir -p /data/.sick;
	$BB chmod -R 0777 /.sick/;
else
	$BB rm -rf /data/.sick/*
	$BB chmod -R 0777 /.sick/;
fi;

# Allow untrusted apps to read from debugfs (mitigate SELinux denials)
if [ -e /su/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app sysfs_devices_system_iosched file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow untrusted_app sysfs_display file { open read write getattr add_name setattr remove_name }" \
	"allow debuggerd app_data_file dir search" \
	"allow sensors diag_device chr_file { read write open ioctl }" \
	"allow sensors sensors capability net_raw" \
	"allow init kernel security setenforce" \
	"allow netmgrd netmgrd netlink_xfrm_socket nlmsg_write" \
	"allow netmgrd netmgrd socket { read write open ioctl }"
fi;

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
#####################################################################
# Synapse
$BB chmod -R 755 /res/*
$BB ln -fs /res/synapse/uci /sbin/uci
/sbin/uci

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;
#####################################################################
# Kernel custom test

if [ -e /data/.sick/Kernel-test.log ]; then
	rm /data/.sick/Kernel-test.log;
fi;
echo  Kernel script is working !!! >> /data/.sick/Kernel-test.log;
echo "excecuted on $(date +"%d-%m-%Y %r" )" >> /data/.sick/Kernel-test.log;


####################################################################

#####################################################################
# Default DVFS Governor
echo "interactive" > /sys/devices/14ac0000.mali/dvfs_governor;

#####################################################################
# GPU CLOCK
echo "100" > /sys/devices/platform/gpusysfs/gpu_min_clock;
echo "852" > /sys/devices/platform/gpusysfs/gpu_max_clock;

#####################################################################
# Default TCP Congestion Controller

echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control;

#####################################################################
# Arch Power

echo "0" > /sys/kernel/sched/arch_power;

#####################################################################
# Gentle Fair Sleepers

echo "0" > /sys/kernel/sched/gentle_fair_sleepers;

#####################################################################

# KNOX Remover
cd /system;
rm -rf *app/BBCAgent*;
rm -rf *app/Bridge*;
rm -rf *app/ContainerAgent*;
rm -rf *app/ContainerEventsRelayManager*;
rm -rf *app/DiagMonAgent*;
rm -rf *app/ELMAgent*;
rm -rf *app/FotaClient*;
rm -rf *app/FWUpdate*;
rm -rf *app/FWUpgrade*;
rm -rf *app/HLC*;
rm -rf *app/KLMSAgent*;
rm -rf *app/*Knox*;
rm -rf *app/*KNOX*;
rm -rf *app/LocalFOTA*;
rm -rf *app/RCPComponents*;
rm -rf *app/SecKids*;
rm -rf *app/SecurityLogAgent*;
rm -rf *app/SPDClient*;
rm -rf *app/SyncmlDM*;
rm -rf *app/UniversalMDMClient*;
rm -rf container/*Knox*;
rm -rf container/*KNOX*;
cd /;

#####################################################################
# Fixing Permissions

$BB chown -R system:system /data/anr;
$BB chown -R root:root /tmp;
$BB chown -R root:root /res;
$BB chown -R root:root /sbin;
$BB chown -R root:root /lib;
$BB chmod -R 777 /tmp/;
$BB chmod -R 775 /res/;
$BB chmod -R 06755 /sbin/ext/;
$BB chmod -R 0777 /data/anr/;
$BB chmod -R 0400 /data/tombstones;
$BB chown -R root:root /data/property;
$BB chmod -R 0700 /data/property;
$BB chmod 06755 /sbin/busybox;
$BB chmod 06755 /system/xbin/busybox;

#####################################################################

#####################################################################
# Google Services battery drain fixer by Alcolawl@xda

	# http://forum.xda-developers.com/google-nexus-5/general/script-google-play-services-battery-t3059585/post59563859
#	sleep 60
#	pm enable com.google.android.gms/.update.SystemUpdateActivity
#	pm enable com.google.android.gms/.update.SystemUpdateService
#	pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
#	pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
#	pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
#	pm enable com.google.android.gsf/.update.SystemUpdateActivity
#	pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
#	pm enable com.google.android.gsf/.update.SystemUpdateService
#	pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
#	pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

#####################################################################

#####################################################################
$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system
$BB mount -o remount,rw /data

