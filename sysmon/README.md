### Install ###
Run with administrator rights
~~~~
sysmon.exe -accepteula -i sysmon-swift.xml

Uses Swift on Security by default, but has Olaf Hartong's modular variations for defender and research configs.

Quickstart: run one of the onboarding scripts ".\onboard_mde.ps1" ".\onboard_swift.pa1" ".\onboard_research.ps1"

# Install direct, If you like to party:
iwr https://raw.githubusercontent.com/mellonaut/sysmon/main/onboard_swift.ps1 | iex
iwr https://raw.githubusercontent.com/mellonaut/sysmon/main/onboard_mde.ps1 | iex
iwr https://raw.githubusercontent.com/mellonaut/sysmon/main/onboard_research.ps1 | iex

~~~~

### Update existing configuration ###
Run with administrator rights
~~~~
sysmon.exe -c sysmon-swift.xml
sysmon.exe -c sysmon-augment.xml
sysmon.exe -c sysmon-research.xml


~~~~

### Uninstall ###
Run with administrator rights
~~~~
sysmon.exe -u
~~~~


�
�
