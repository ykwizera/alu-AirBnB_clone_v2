#!/usr/bin/env bash
# Script to set up web servers for the deployment of web_static

set -e

# Function to install nginx if not already installed
install_nginx() {
    if ! dpkg -l | grep -q nginx; then
        sudo apt-get -y update
        sudo apt-get -y install nginx
    fi
}

# Function to create directories if they don't already exist
create_directories() {
    sudo mkdir -p /data/web_static/releases/test /data/web_static/shared
}

# Function to create a fake HTML file
create_html_file() {
    echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null
}

# Function to create a symbolic link
create_symlink() {
    if [ -L /data/web_static/current ]; then
        sudo rm /data/web_static/current
    fi
    sudo ln -s /data/web_static/releases/test/ /data/web_static/current
}

# Function to set ownership of the /data/ directory
set_ownership() {
    sudo chown -R ubuntu:ubuntu /data/
}

# Function to update Nginx configuration
update_nginx_config() {
    local nginx_config="/etc/nginx/sites-available/default"
    if ! grep -q "location /hbnb_static" "${nginx_config}"; then
        sudo sed -i '/server_name _;/a \\n\tlocation /hbnb_static {\n\t\talias /data/web_static/current/;\n\t}' "${nginx_config}"
    fi
    sudo service nginx restart
}

# Main script execution
install_nginx
create_directories
create_html_file
create_symlink
set_ownership
update_nginx_config

# Output success message
echo "Nginx configuration updated and localhost/hbnb_static available"
exit 0
