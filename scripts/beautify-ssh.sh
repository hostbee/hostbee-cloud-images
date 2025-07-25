#!/bin/bash

cat >/etc/motd <<EOF
      :::    :::  ::::::::   :::::::: ::::::::::: :::::::::  :::::::::: :::::::::: 
     :+:    :+: :+:    :+: :+:    :+:    :+:     :+:    :+: :+:        :+:         
    +:+    +:+ +:+    +:+ +:+           +:+     +:+    +:+ +:+        +:+          
   +#++:++#++ +#+    +:+ +#++:++#++    +#+     +#++:++#+  +#++:++#   +#++:++#      
  +#+    +#+ +#+    +#+        +#+    +#+     +#+    +#+ +#+        +#+            
 #+#    #+# #+#    #+# #+#    #+#    #+#     #+#    #+# #+#        #+#             
###    ###  ########   ########     ###     #########  ########## ##########       

Welcome! Have a great day!
EOF

echo "==> setting up root login"
ALLOW_ROOT_LOGIN=${ROOT_FLAG:-true}
ALLOW_PASSWORD_LOGIN=${PASSWORD_FLAG:-false}
if [ "$ALLOW_ROOT_LOGIN" == "true" ]; then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
fi
if [ "$ALLOW_PASSWORD_LOGIN" == "true" ]; then
      sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
      sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
fi
systemctl restart sshd

sed -i 's/^disable_root: true/disable_root: false/' /etc/cloud/cloud.cfg
