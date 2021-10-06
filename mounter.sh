#!/bin/sh

if [ -z "${DRIVE_FS}" ]; then
     echo "DRIVE_FS is not set, unable to continue"
     exit 1
fi

DRIVE_MOUNT=${DRIVE_MOUNT:-${DRIVE_FS}}

AUTH="--rc-addr=rclone:5572  --rc-user=$WEB_ADMIN_USER --rc-pass=$WEB_ADMIN_PASSWORD"
mount_dir="/mnt/${DRIVE_MOUNT}"

echo "hello, AUTH:${AUTH} mount_dir:${mount_dir} whoami:`whoami`, DRIVE_FS:${DRIVE_FS} DRIVE_MOUNT:${DRIVE_MOUNT}"

sleep 3

[ ! -d "${mount_dir}" ] && mkdir $mount_dir || true

function cleanup {
     echo "cleaning up, umounting drive:${mount_dir}"
     rclone rc fscache/entries $AUTH
     rclone rc mount/unmount fs=${DRIVE_FS} mountPoint="${mount_dir}" $AUTH
     rclone rc fscache/clear $AUTH
     fusermount -uq ${mount_dir} || true
     umount -f ${mount_dir} || umount -l ${mount_dir} || true
     sleep 3
     echo "cleaning up drive:${mount_dir} umounted"
}



echo "mounting drive:${DRIVE_FS} into ${mount_dir}..."

rclone rc options/set --json '{"vfs": {"CacheMode": 3, "UID": '$PUID', "GID": '$PGID', "Umask": 23}, "mount": {"AllowOther": true}}' $AUTH 
# rclone rc mount/mount fs=${DRIVE_FS}: mountPoint=${mount_dir} $AUTH 

rclone rc mount/mount fs=${DRIVE_FS}: mountPoint="${mount_dir}" \
     vfsOpt='{"CacheMode": 3, "GID": '$PGID', "UID": '$PUID', "Umask": 0 }' \
     mountOpt='{ "AllowNonEmpty": true, "AllowOther": true, "AsyncRead": true, "Daemon": true, "DaemonTimeout": 0, "DebugFUSE": true, "DefaultPermissions": false, "ExtraFlags": [ "use-mmap", "v", "debug-fuse" ], "ExtraOptions": [ "dir-perms=2777", "file-perms=2777" ], "MaxReadAhead": 1048576, "NoAppleDouble": true, "NoAppleXattr": false, "VolumeName": "${DRIVE_FS}", "WritebackCache": true }' \
     $AUTH 

sleep 3


echo "mounting finished"
rclone rc core/version $AUTH 
rclone rc options/get  $AUTH 
# rclone rc --loopback operations/fsinfo fs=${DRIVE_FS}: $AUTH 
rclone rc mount/listmounts $AUTH 


trap cleanup EXIT TERM INT; sleep infinity & wait