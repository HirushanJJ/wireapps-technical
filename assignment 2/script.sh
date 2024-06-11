#!/bin/bash

# Update package index
log_message "Updating package index"
sudo apt update

# Install Node.js and NPM
log_message "Installing Node.js and NPM"
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Install Nginx
log_message "Installing Nginx..."
sudo apt install -y nginx

# Define domain names
WEB_DOMAIN="web.example.com"
API_DOMAIN="api.example.com"

# Create Nginx configuration for the Web App
log_message "Creating Nginx configuration for the Web App..."
sudo tee /etc/nginx/sites-available/$WEB_DOMAIN > /dev/null <<EOL
server {
    listen 80;
    server_name $WEB_DOMAIN;

    location / {
        proxy_pass http://localhost:3000;  # Assuming the web app runs on port 3000
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Create Nginx configuration for the API
log_message "Creating Nginx configuration for the API..."
sudo tee /etc/nginx/sites-available/$API_DOMAIN > /dev/null <<EOL
server {
    listen 80;
    server_name $API_DOMAIN;

    location / {
        proxy_pass http://localhost:4000;  # Assuming the API runs on port 4000
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Enable the configurations by creating symbolic links
log_message "Enabling Nginx configuration for $WEB_DOMAIN and $API_DOMAIN..."
sudo ln -s /etc/nginx/sites-available/$WEB_DOMAIN /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/$API_DOMAIN /etc/nginx/sites-enabled/

# Test Nginx configuration
log_message "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx to apply the new configurations
log_message "Reloading Nginx..."
sudo systemctl reload nginx

# Install Certbot
log_message "Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Provision SSL certificates for both applications
log_message "Provisioning SSL certificates for $WEB_DOMAIN..."
sudo certbot --nginx -d $WEB_DOMAIN

log_message "Provisioning SSL certificates for $API_DOMAIN..."
sudo certbot --nginx -d $API_DOMAIN

# Set up automatic renewal for certificates
log_message "Setting up automatic renewal for SSL certificates..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

log_message "Environment setup completed successfully!"
