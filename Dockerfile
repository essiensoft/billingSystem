# PHPNuxBill - Production Docker Image
# Includes all security fixes and optimizations

FROM php:8.2-apache

LABEL maintainer="PHPNuxBill Security Team"
LABEL version="1.0-secure"
LABEL description="PHPNuxBill Billing System with Security Fixes"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    curl \
    git \
    unzip \
    mariadb-client \
    freeradius-utils \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    mbstring \
    zip \
    xml \
    opcache \
    bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules
RUN a2enmod rewrite headers ssl expires

# Configure PHP for production
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.validate_timestamps=0'; \
    echo 'expose_php=Off'; \
    echo 'display_errors=Off'; \
    echo 'log_errors=On'; \
    echo 'error_log=/var/log/php_errors.log'; \
    echo 'max_execution_time=300'; \
    echo 'memory_limit=256M'; \
    echo 'upload_max_filesize=20M'; \
    echo 'post_max_size=25M'; \
    echo 'session.cookie_httponly=1'; \
    echo 'session.cookie_secure=1'; \
    echo 'session.cookie_samesite=Strict'; \
    echo 'session.use_strict_mode=1'; \
    } > /usr/local/etc/php/conf.d/production.ini

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy application files (includes scripts/ directory)
COPY . /var/www/html/

# Set proper permissions
RUN mkdir -p /var/www/html/ui/compiled \
    && mkdir -p /var/www/html/ui/cache \
    && mkdir -p /var/www/html/system/uploads \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/ui/compiled \
    && chmod -R 777 /var/www/html/ui/cache \
    && chmod -R 777 /var/www/html/system/uploads

# Set global ServerName to suppress Apache FQDN warning
RUN echo "ServerName mulanet.cloud" >> /etc/apache2/apache2.conf

# Create backup of uploads directory (for volume mounting) - MUST BE AFTER ALL APT OPERATIONS
RUN mkdir -p /var/www/html_backup/system/uploads \
    && cp -rv /var/www/html/system/uploads/* /var/www/html_backup/system/uploads/ \
    && echo "Backup created. Files in backup:" \
    && ls -la /var/www/html_backup/system/uploads/ \
    && echo "Total files backed up:" \
    && find /var/www/html_backup/system/uploads/ -type f | wc -l


# Create encryption key if not exists
RUN if [ ! -f /var/www/html/.encryption_key ]; then \
    php -r "echo bin2hex(random_bytes(32));" > /var/www/html/.encryption_key; \
    chmod 600 /var/www/html/.encryption_key; \
    chown www-data:www-data /var/www/html/.encryption_key; \
    fi

# Apache configuration for security
RUN { \
    echo '<Directory /var/www/html>'; \
    echo '    Options -Indexes +FollowSymLinks'; \
    echo '    AllowOverride All'; \
    echo '    Require all granted'; \
    echo '    # Security headers'; \
    echo '    Header always set X-Frame-Options "SAMEORIGIN"'; \
    echo '    Header always set X-Content-Type-Options "nosniff"'; \
    echo '    Header always set X-XSS-Protection "1; mode=block"'; \
    echo '    Header always set Referrer-Policy "strict-origin-when-cross-origin"'; \
    echo '    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"'; \
    echo '</Directory>'; \
    echo ''; \
    echo '# Disable directory listing'; \
    echo 'Options -Indexes'; \
    echo ''; \
    echo '# Protect sensitive files'; \
    echo '<FilesMatch "\\.(htaccess|htpasswd|ini|log|sh|sql|key)$">'; \
    echo '    Require all denied'; \
    echo '</FilesMatch>'; \
    } > /etc/apache2/conf-available/security-headers.conf

RUN a2enconf security-headers

# Copy Apache SSL configuration
COPY apache-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Enable SSL site and required modules
RUN a2ensite default-ssl \
    && a2enmod ssl \
    && a2enmod http2

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80 443

# Set entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# Start Apache
CMD ["apache2-foreground"]