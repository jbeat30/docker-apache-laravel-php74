# Base image
FROM php:7.4-apache

# Install necessary packages and PHP extensions
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install apt-utils  \
    libonig-dev \
    curl \
    zip \
    unzip && \
    docker-php-ext-install pdo pdo_mysql mysqli mbstring gettext

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Change document root to Laravel public directory
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

 # Set the label public directory as the root of Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configure Apache
RUN echo '<Directory /var/www/html/public>\n\
    Options FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf && \
    a2enmod mpm_prefork rewrite

# Configure PHP settings
RUN echo "date.timezone = Asia/Seoul" > /usr/local/etc/php/php.ini && \
    sed -i 's/short_open_tag = Off/short_open_tag = On/' /usr/local/etc/php/php.ini

# Copy application files to container and set proper permissions
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Expose port 80 for web access
EXPOSE 80

# Start Apache server
CMD ["apachectl", "-D", "FOREGROUND"]