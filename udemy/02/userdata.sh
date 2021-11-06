#! /bin/bash
#Installing and enabling nginx. Creating simple index.html

amazon-linux-extras install nginx1
systemctl enable nginx
systemctl start nginx
#PUBLIC_IP = $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Hello world from my WebSite Node with IP $PUBLIC_IP</h1>" > /usr/share/nginx/html/index.html