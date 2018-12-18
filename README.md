VPS Deploy
==========

Copyright (c) 2018 Ripple Software. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; version 2 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

## Overview Description

VPS Deploy is to quickly deploy a CentOS VPS as a web-server. Steps are listed below and detailed descriptions of each element of VPS_deploy. Security is the focus of VPS_deploy.  Several files must be configured before loading (encrypting a payload) and deploying to a server.

### Things you need to do:

1. Setup a VPS server with SSH access for root
2. Configure settings for several files in the payloads directory
3. Encrypt the payload using **VPS_deploy -load -p \<password\>**
4. Deploy the payload **VPS_deploy -remotedeploy -p \<password\>**

**WARNING - you need to securely store the critical information output from the -load option used in step 3**

### What VPS_deploy will do:

1. **VPS_deploy.py -remotedeploy -p \<password\>** will prepare the CentOS package configuration to run VPS_deploy, move the encrypted payload and script to the server.
*TODO* does grub need to be configured for CentOS??????
2. The payload will be decrypted and script initiated (All stdout output will be stored to VPS_deploy.log in the root home directory)
3. New non-root users will be created and SSH for remote access will be removed
4. Firewall will be installed, configured and installed as a service
5. **LAMP** stack will be installed, configured and installed as service
6. SELinux will be configured to allow interoperability of the **LAMP** stack
7. **git** will be installed and connection made to GitHub to clone your website to the web-directory
8. An SSL certificate will be generated from Let's Encrypt Certificate Authority
9. Additional security packages **rkhunter** and **chkrootkit** will be installed and added to crontab for root
10. A database backup user will be added and backups will be added to crontab
11. They payload will be deleted from the server (TODO: memory space will be overwritten)
13. *Optional* the server will be powered down so you can make an image of it.

*NOTE: script can be edited in payloads/VPS_deploy.sh*

## Detailed Payload Description

### Brief File Descriptions:

### Configuration Files Details

*Non-root User Details*

**MUST** You must add credentials to the required_files userdata file.  Copy the two lines below and replace the username_default and password with your own username and password.  So, the file is simply two lines of text.  If you want other users added to the server, you can add lines to the file.

username_default dont_use_this_password

*SSH Configuration*

*Config Files*

A modified copy of ssh_config and sshd_config files have been added to required_files. You should check them out. They have been modified with some standard security concerns in mind such as:

1. **root** login has been disabled
2. Encryption cipher has been modified demand the most secure cipher available
3. Password based login has been disabled
4. A secure cipher-suite has been selected

*SSH Keys*

New SSH keys will be generated on the VPS for the new user and root SSH keys will be deleted. You will be provided with the server public key after VPS_deploy has finished and you try to connect to the server for the first time.

If you also want to replace the SSH public key that you used when created server, you should create a new RSA public key-pair on your and add the public key named id_rsa.pub to the require_files directory.  If a file named id_rsa.pub is found in the required_files directory and the file is not empty, that file will be placed into the /home/user/.ssh directory of the
non-root user created during setup.

*GitHub Keys*

VPS_deploy can download a GitHub repository to be automatically downloaded and installed into the web-root directory, you need to first create an RSA key-pair (ssh-keygen -t rsa -b 4096 -C "your_email@example.com").  Create the key named as id_rsa_github with no passphrase.  After the private and public key have been created, save copies of them in the require_files directory, and load the public key into your GitHub account. Log in, go to -> Settings -> SSH and GPG Keys -> New SSH Key.  Paste the public key into your account.    

*Apache Configuration*

A modified Apache config (httpd.conf) file for Centos is also located in the payloads directory. It has been modified for improved security to disabling indexing for all directories, forwarding all error messages to 500 error page to obfuscate the details of error messages. However, you will need to modify the file to allow access to any required asset/resource directories such as css files, javascript files, or images.  You may also want to otherwise configure the httpd.conf file as per your requirements.

Finally, the VPS_deploy script will encrypt the httpd.conf file after Apache has been started since it is not needed once Apache has been started.  The commands to decrypt the file to edit it and re-encrypt the file are included in the critical_information.txt file.

*PHP Configuruation*

A modified PHP config (php.ini) file for Centos is also located in the payloads directory. It has been modified for improved security by disabling some features of PHP that are not required for normal website operation such as remove file operations, remote PHP commands, ftp, etc. However, you will need to modify the file to allow access to any required asset/resource directories such as css files, javascript files, or images.  You may also want to otherwise configure the httpd.conf file as per your requirements.

*MySQL/MariaDB Configuration*

VPS_deploy.sh will automatically install and configure MySQL/MariaDB.  Standard security practices for MySQL are employed.  Also a backup user is created with only read permissions to all databases and a full database backup is added to the cron scheduler.

## Other Configuration Details

*Let's Encrypt Certbot*

In the VPS_deploy.sh script, a SSL/TLS certificate is automatically installed onto the server for the domain specified in the serverdata file in the root directory of VPS_deploy as the line DomainName yourdomain.com.  The following flags/settings are currently used when obtaining a SSL/TLS certificate and more information can be obtained from the Let's Encrypt website (https://certbot.eff.org/docs/using.html).

-- redirect : all http requests are forwarded to https

-- hsts : https is used for all outgoing traffic forcing browsers to always use SSL/TLS for the domain.  

--uir : users browsers are forced to use https for all http content (such as images and links)

Finally, an certificate renewal is added to the cron scheduler.

