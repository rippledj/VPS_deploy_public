# Move the payload and main script to the server, and run remotely
echo "[Backing-up the database...]"
if [ -s payloads/id_rsa_backup ]
then
    echo "[Starting to process database backups...]"
    # Make a ssh directory and set permissions
    mkdir /root/.ssh
    # Add the ssh identity file to root to configure connection to github
    echo "[Adding identify files to root...]"
    /bin/cp payloads/ssh_identity_file /root/.ssh/
    mv /root/.ssh/ssh_identity_file /root/.ssh/config
    chmod 0400 /root/.ssh/config
    echo "[Adding backup IP address as known host to root...]"
    # Add github.com to the known_hosts file
    ssh-keyscan -H github.com >> /root/.ssh/known_hosts
    # Copy the id_rsa_backup and id_rsa_backup.pub to /root/.ssh directory
    echo "[Moving backup SSH keys to root...]"
    /bin/cp payloads/id_rsa_backup /root/.ssh
    /bin/cp payloads/id_rsa_backup.pub /root/.ssh
    # Modify permissions
    chmod 0400 /root/.ssh/id_rsa_backup
    chmod 0400 /root/.ssh/id_rsa_backup.pub
    # Copy the id_rsa_backup and id_rsa_backup.pub to /root/.ssh directory
    echo "[Adding backup SSH keys to root ssh agent...]"
    eval `ssh-agent -s`
    ssh-add /root/.ssh/id_rsa_backup
    echo "[Sending database backups to remote server...]"
    while read -r -a backupdata
    do
      # Eliminate all comment lines
      if [[ ${backupdata[0]:0:1} != "#" && ! -z "${backupdata[0]}" ]]; then
        # Move the MySQL backup file to remote server
        scp /var/www/backups/db_backup_\$(date +\%m_\%d_\%Y).sql.gz ${backupdata[1]}:~/
      fi
    done < payloads/backup_serverdata
fi
echo "[VPS_deploy has sent a backup of the database to backup the server...]"
# Clear the command line history
echo "[Removing command line history...]"
history -c
echo "[Command line history removed...]"
echo "[Removing SSH directory...]"
rm -rf /root/.ssh
echo "[SSH directory removed...]"
# Send a success exit code
exit 0
