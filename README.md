# PIWIGO INSTALLATION PLUS

This script helps you install Piwigo Gallery easily. It will install LAMP server and configure it which
includes the database.
It will also install A+ valid SSL certificate with auto renewal.
Install video and multiformat support for piwigo gallery.
Tested to work on Piwigo 13.7.0 with Ubuntu 18.0 LTS and higher versions.

## DISCLAIMER

This script is provided without any gaurantee or warranty. This script is provided for free. It is solely
upto you on how you use this script. I am not responsible for any losses/damages or when allegedly your 
server explodes after using this script.

## PREREQUISITES

1. Some basic knowledge. 
2. Ubuntu server 18.0 or higher. 
3. A sudo user account.
4. The A record for 'domain' and 'www' must point to your server ip.

## HOW TO SET THE DNS OR A RECORD

1. Log in to your domain registrar, hosting provider’s control panel, or DNS management interface.
2. Find the section where you can manage your DNS records, which is usually labeled “DNS Management,” “DNS Zone Editor,” or “DNS Records.”
3. Look for the option to add a new record and select “A” as the record type.
4. Enter the subdomain or domain name for which you want to create the A record.
5. Enter the IP address of server in the appropriate field.
6. Set the TTL (time-to-live) value or leave it at default.
7. Create another A record by repeating the steps 4 to 6 with www as value instead of your sub domain or domain name.
8. Save the 2 new A records.

If you want you can also add AAAA record the similar way for ipv6 address but it is not necessary for the script.

NOTE: It may take some time for the DNS record that you set to propogate or take effect so wait for an hour before you run the script to play safe and avoid error. 

## HOW TO RUN SCRIPT

1. Clone the script to your server
   ```git clone https://github.com/Heiminda/piwigo-plus.git
   ```
3. Change to script directory
   ```cd piwigo-plus
   ```
5. Make script executable
   ```sudo chmod +x p-plus.sh
   ```
7. Run the script
   ```./p-plus.sh
   ```

Hit y and enter to start the script, you will be asked to enter some details. Enter them when asked and hit enter.

 
