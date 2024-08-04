# Use an official PHP runtime with Apache as a parent image
FROM php:8.2-apache

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions using a script
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Set the working directory in the container
WORKDIR /var/www/html

# Install PHP extensions required by Moodle
RUN install-php-extensions gd pdo_pgsql pgsql opcache iconv mbstring curl openssl ctype zip zlib simplexml spl pcre dom xml xmlreader intl json hash fileinfo xsl soap exif yaml

# Enable Apache modules required by Moodle
RUN a2enmod rewrite

# Edit the config of php.ini of the container.
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle.ini

# Set permissions for Moodle directories
RUN chown -R www-data:www-data /var/www/html \
    && mkdir /var/www/moodledata \
    && chown -R www-data:www-data /var/www/moodledata

# Expose Apache HTTP port
EXPOSE 80

# Start Apache web server
CMD ["apache2-foreground"]
