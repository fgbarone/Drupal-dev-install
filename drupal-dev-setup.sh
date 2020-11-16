# #!/bin/bash
########################################################################
# Setting up version, local host and install directory variables

read -p "Drupal version to install [9.2.x-dev]: " DRUPAL_VERSION
DRUPAL_VERSION=${DRUPAL_VERSION:-9.2.x-dev}

read -p "HTTP server root (without trailling slash)[http://localhost]: " SERVER_ROOT
SERVER_ROOT=${SERVER_ROOT:-http://localhost}

read -p "Directory name for installation [drupaldev]: " DIR_NAME
DIR_NAME=${DIR_NAME:-drupaldev}



########################################################################
# Installing Drupal core
# https://www.drupal.org/docs/develop/using-composer/using-composer-to-install-drupal-and-manage-dependencies

composer create-project --no-interaction drupal/recommended-project:^$DRUPAL_VERSION "$DIR_NAME"
cd "$DIR_NAME"


########################################################################
# Installing dev tools
# - Drush: https://www.drush.org/
# - Composer Patches: https://github.com/cweagans/composer-patches
# - Devel module: https://www.drupal.org/project/devel
# - Chaos Tools module: https://www.drupal.org/project/ctools
# - Admin toolbar module: https://www.drupal.org/project/admin_toolbar

printf "\n\nInstalling dev tools\n\n"
composer require drush/drush cweagans/composer-patches drupal/devel drupal/ctools drupal/admin_toolbar

# Creating files folder and the settings.php file
sudo mkdir -m777 ./web/sites/default/files
cp ./web/sites/default/default.settings.php ./web/sites/default/settings.php
chmod 0777 ./web/sites/default/settings.php


########################################################################
# Adds the settings for debug and trusted hosts to the settings.php file
# Setting trusted hosts
# https://www.drupal.org/docs/installing-drupal/trusted-host-settings

printf "\n\$settings['trusted_host_patterns'] = ['^localhost\$'];" >> ./web/sites/default/settings.php

# PHP and Drupal error level and output verbose
# https://www.drupal.org/forum/support/post-installation/2018-07-18/enable-drupal-8-backend-errorlogdebugging-mode

printf "\nerror_reporting(E_ALL);\nini_set('display_errors', TRUE);" >> ./web/sites/default/settings.php
printf "\nini_set('display_startup_errors', TRUE);" >> ./web/sites/default/settings.php
printf "\n\$config['system.logging']['error_level'] = 'verbose';" >> ./web/sites/default/settings.php

########################################################################
# Install drupal core and enable modules
drush site-install

sudo chmod 0555 ./web/sites/default/settings.php # changing the settings.php file's chmod for security

# Install basic dev modules
drush en admin_toolbar
drush en admin_toolbar_tools
drush en admin_toolbar_search
drush en ctools
drush en devel
drush cr # clear cache
drush uli --uri $SERVER_ROOT/$DIR_NAME/web/ # first login
