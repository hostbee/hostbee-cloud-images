#!/bin/bash

cat > /etc/motd <<EOF
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
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
