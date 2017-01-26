#!/bin/bash
echo "forwarding you to the device wall server..."
#cat "mdInstaller.sh -a bite.apk" | ssh RamonValk@192.168.13.92 /bin/bash
#scp /etc/passwd RamonValk@192.168.13.92:/etc/passwd
#scp /etc/passwd RamonValk@192.168.13.92:/tmp
ssh RamonValk@192.168.13.92 'PATH=/usr/local/bin:$PATH && /usr/local/bin/mdInstaller -a /Users/RamonValk/Google\ Drive/School/School/Jaar\ 3/Stage/APK\ Installer/Automated/tapSound.apk -s'