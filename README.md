# Android-Multiple-Device-Installer
Script voor het installeren en openen van een apk op een android device via adb.

### sshTool
Deze tool kan worden gebruikt om een ssh sessie met de installatie server op te zetten en automatisch een apk te pushen, de flags bedoeld voor "mdInstaller" kunnen ook met deze tool gebruikt worden omdat ze worden doorgestuurd. Begin wel altijd met de -a flag! Gebruik: tool.sh -a [apk] flags
### Automated
De automatische installer voor de commandline, gebruik: "sh mdInstaller.sh [file.apk]". Kan "isDeviceOn.sh" gebruiken door deze boolean op true te zetten.

### Site
De automatische installer met een bijgevoegd php script voor het uploaden van een apk, gebruik: upload via de upload knop, de automated installer word server side uitgevoerd.

### Standalone
De originele versie van de installer, dit bash script vraagt tijdens het uitvoeren om bepaalde informatie.

### wSelection
Aangepaste versie van "Automated" waar een selectie menu is ingebouwd, hiermee is het mogelijk om bepaalde aangesloten devices uit te sluiten van installatie, gebruik: " sh test.sh [file.apk]"
