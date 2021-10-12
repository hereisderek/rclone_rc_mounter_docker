FROM rclone/rclone:beta
# FROM rclone/rclone:latest

RUN rclone version
RUN uname -a

COPY mounter.sh /bin/mounter.sh
RUN chmod a+x /bin//mounter.sh

ENV DRIVE_FS= DRIVE_MOUNT= POST_OPTIONS_SET_JSON=


ENTRYPOINT [ "/bin/mounter.sh" ]