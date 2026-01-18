#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
sudo cat > /usr/share/nginx/html/index.html << 'WEBSITE'
<html>
<head>
    <title>Maxim Lelievre website! -${environment}</title>
</head>
            <span style="font-size:75px;">Welcome to Maxim Lelievre's ${environment} website!</span>
        </span>
    </p>
</body>
</html>
WEBSITE
