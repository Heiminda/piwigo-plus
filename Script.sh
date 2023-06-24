#!/bin/bash

HORIZONTALLINE="================================================================================================================="
clear
echo -e "\n$HORIZONTALLINE"
echo "                                    PIWIGO INSTALLATION PLUS"
echo -e "\n$HORIZONTALLINE"
echo -e "$HORIZONTALLINE\n"
echo "This script helps you install Piwigo Gallery easily. It will install LAMP server and configure it which"
echo "includes the database, set ufw fire wall and fail2ban."
echo "It will also install A+ valid SSL certificate with auto renewal."
echo "Install video and multiformat support for piwigo gallery."
echo "Tested to work on Piwigo 13.7.0 with Ubuntu 18.0 LTS"
echo -e "\n"
echo "Author: Vivek"
echo "Date: June 2023"
echo -e "\n$HORIZONTALLINE"
echo "  PREREQUISITES"
echo -e "\n$HORIZONTALLINE"
echo "1. Some basic knowledge. "
echo "2. Ubuntu server 18.0 or higher "
echo "3. A sudo user account."
echo "4. The A record for 'domain' and 'www' must point to your server ip."
echo "If you don't know how then read the ReadMe.txt file that is located in the script folder"
echo -e "\n$HORIZONTALLINE"
[[ "$(read -r -e -p 'Continue? [y/N]> '; echo "$REPLY")" == [Yy]* ]] && echo "Starting the installation.." || exit 1


# Prompt the user for the desired values
echo "Enter your Domain name (for example: piwigo.com): "
read -r domain
echo "Enter your sub domain (if your domain is site1.piwigo.com then site1 is sub domain, otherwise leave blank): "
read -r sub
echo "Enter your server IP: "
read -r ip

# Update /etc/hosts file
echo "$ip $domain $sub" | sudo tee -a /etc/hosts || echo "Failed to update /etc/hosts file"
echo "Updated /etc/hosts file"

# Set hostname
sudo hostnamectl set-hostname "$domain" || echo "Failed to set hostname"
echo "Hostname set to $domain"

# Updating Ubuntu
echo "Updating Ubuntu.."
sudo apt update && sudo apt upgrade -y || echo "Failed to update and upgrade Ubuntu"
echo "Ubuntu updated successfully"

# Install LAMP server
echo -e "Installing LAMP Server..\n"
sudo apt install apache2 mariadb-server php libapache2-mod-php php-common php-mbstring php-xmlrpc php-gd php-xml php-intl php-mysql php-cli php php-ldap php-zip php-curl unzip git -y || echo "Failed to install LAMP server"
echo "LAMP server installed successfully"

sudo systemctl start apache2
# Configuring PHP

# Get PHP version
php_version=$(php -v | grep -oP '(?<=PHP )\d+\.\d+')

if [[ -n $php_version ]]; then
  phpversion=${php_version:0:3}
  php_ini_path="/etc/php/$phpversion/apache2/php.ini"
else
  echo "PHP is not installed or not found."
fi

# Prompt the user for the desired PHP configuration values
echo "Enter Memory Limit for scripts (Enter 128M or 512M (any amount) depending on RAM): "
read -r new_memory_limit
echo "Enter maximum allowed size for uploaded files (100M for 100MB size): "
read -r new_upload_max_size
echo "Maximum allowed post size (must be greater than or equal to upload size, for example 150M): "
read -r new_post_max_size

echo "Configuring PHP"

# Remove '#' from the beginning of lines if present
sed -i 's/^#\(memory_limit\s*=\s*.*\)/\1/' "$php_ini_path" || echo "Failed to update php.ini"
sed -i 's/^#\(post_max_filesize\s*=\s*.*\)/\1/' "$php_ini_path" || echo "Failed to update php.ini"
sed -i 's/^#\(upload_max_filesize\s*=\s*.*\)/\1/' "$php_ini_path" || echo "Failed to update php.ini"

# Update php.ini values
sed -i "s/^\(memory_limit\s*=\s*\).*/\1$new_memory_limit/" "$php_ini_path" || echo "Failed to update php.ini"
sed -i "s/^\(post_max_filesize\s*=\s*\).*/\1$new_post_max_size/" "$php_ini_path" || echo "Failed to update php.ini"
sed -i "s/^\(upload_max_filesize\s*=\s*\).*/\1$new_upload_max_size/" "$php_ini_path" || echo "Failed to update php.ini"
echo "Updated PHP configuration in php.ini"

# Restart Apache
sudo systemctl restart apache2 || echo "Failed to restart Apache"
echo "Apache restarted successfully"

# Prompt user for database password
echo "Enter a strong password for database: "
read -r passwd

# Create a Database for Piwigo
mysql <<EOF
CREATE DATABASE piwigo;
CREATE USER 'piwigo'@'localhost' IDENTIFIED BY '$passwd';
GRANT ALL ON piwigo.* TO 'piwigo'@'localhost' IDENTIFIED BY '$passwd' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
EOF
echo "Created Piwigo database"
echo "Your database details is as folllows"
echo "Username: piwigo"
echo "Database Name: piwigo"
echo "Password: "$passwd""
echo "Please save these details before you continue"
[[ "$(read -r -e -p 'Proceed with installation? [y/N]> '; echo "$REPLY")" == [Yy]* ]] && echo "Continuing the installation.." || exit 1



# Install Piwigo
echo "Downloading Piwigo.."
sudo curl -o piwigo.zip "https://piwigo.org/download/dlcounter.php?code=latest" || echo "Failed to download Piwigo"
sudo unzip piwigo.zip || echo "Failed to unzip Piwigo"
sudo mv piwigo /var/www/$domain || echo "Failed to move Piwigo to /var/www/$domain"
# Install dependency for video
sudo apt install ffmpeg exiftool mediainfo -y
echo "Adding Videojs plugin"
sudo git https://github.com/Piwigo/piwigo-videojs.git /var/www/$domain/plugins/piwigo-videojs
echo "Adding video and multiformat support configuration.."
sudo cp config.inc.php /var/www/$domain/local/config
echo "Setting permissions for folders.."
sudo chown -R www-data:www-data /var/www/$domain/ || echo "Failed to set ownership of /var/www/$domain"
sudo chmod -R 755 /var/www/$domain/ || echo "Failed to set permissions for /var/www/$domain"
echo "Piwigo added successfully"

# Configure Apache for Piwigo
echo "Configuring Apache for Piwigo.."
sudo cp http_apache_config.conf "/etc/apache2/sites-available/$domain.conf" || echo "Failed to copy Apache configuration"
sudo sed -i "s/domain_name/$domain/g" "/etc/apache2/sites-available/$domain.conf" || echo "Failed to update Apache configuration"
# Server information leakage disabling
echo "ServerSignature Off" | sudo tee -a /etc/apache2/apache2.conf || echo "Failed to update apache config"
echo "ServerTokens Prod" | sudo tee -a /etc/apache2/apache2.conf || echo "Failed to update apache config"
echo "Configured Apache for Piwigo"

# Enable the Piwigo site
sudo a2ensite "$domain.conf" || echo "Failed to enable the Piwigo site"
sudo a2enmod rewrite || echo "Failed to enable Apache rewrite module"
sudo a2dissite 000-default.conf || echo "Failed to disable the default site"
sudo systemctl restart apache2 || echo "Failed to restart Apache"
echo "Enabled Piwigo site and restarted Apache"

# Check Apache configuration
sudo apache2ctl configtest || echo "Apache configuration test failed"
echo "Apache configuration test passed"

# Enable Apache at startup
sudo systemctl enable apache2 || echo "Failed to enable Apache at startup"
echo "Enabled Apache at startup"

# Begining of SSL installation
echo -e "\nInstalling SSL certificate.."

# Install certbot
sudo apt install certbot -y || echo "Failed to install certbot"

# Generate Diffie–Hellman key
echo "Generating Diffie–Hellman encryption key.. This may take a while.."
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 || echo "Failed to generate Diffie–Hellman encryption key"
echo "Generated Diffie–Hellman encryption key and added to configuration"

# Setting permissions
sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chgrp www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt

# Copying configurations
sudo cp letsencrypt.conf /etc/apache2/conf-available/letsencrypt.conf
sudo cp ssl-params.conf /etc/apache2/conf-available/ssl-params.conf

# Enabling configurations
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enconf letsencrypt
sudo a2enconf ssl-params
sudo a2enmod http2

sudo systemctl reload apache2 || echo "Failed to restart Apache"

# Prompt for an email for registering SSL
echo "Enter your email for registering to Let's Encrypt SSL: "
read -r email

sudo certbot certonly --agree-tos --email $email --webroot -w /var/lib/letsencrypt/ -d $domain -d www.$domain || echo "Failed to generate SSL certificate. Check your DNS settings."
echo "SSL Certficate is issued to your domain successfully"
echo "SSL certificate saved to /etc/letsencrypt/live/$domain. You may need to back that up."
sudo cp https_apache_config.conf "/etc/apache2/sites-available/$domain.conf" || echo "Failed to copy Apache configuration"
sudo sed -i "s/domain_name/$domain/g" "/etc/apache2/sites-available/$domain.conf" || echo "Failed to update Apache configuration"
sudo systemctl reload apache2
echo "Test your domain using the SSL Labs Server Test https://www.ssllabs.com/ssltest/, you’ll get an A+ grade"
echo "Your piwigo gallery is up and running at https://$domain"
echo "Enter the database details and create an admin account to begin using piwigo gallery"
echo "Don't forget to enable videoJs plugin from administration."

