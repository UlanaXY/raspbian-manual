# raspbian-manual


## card flashing
Na partycji boot trzeba zrobić plik o nazwie `ssh` by aktywować łączenie się przez ssh 

## Setup
### znajdowanie raspberry w sieci
bo adresie mac Pi
```bash
arp -a | findstr b8-27-eb
```
albo po adresie anteny wifi
```bash
arp -a | findstr 00-13-ef-40-09-27
```

### ssh setup
1. Stworzyć folder `.ssh` w katalogu home
2. Perzekopiować klucz ssh (powershell)
 ```powershell
 type $env:USERPROFILE\.ssh\id_rsa.pub | ssh pi@$env:ULN_MONITOR_IP "cat >> .ssh/authorized_keys"
 ```
folder `.ssh` może nie istnieć, stedy trzeba go stworzyć

### Strefa czasowa
Można ją ustawić za pomocą `sudo raspi-config`

### Netis WF2120 fix
Add to `/etc/network/interfaces` this fragment:
```
auto lo
iface lo inet loopback
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

### Disable MAC address randomization
If you have Network-Manager installed:

To disable the MAC address randomization create the file
`/etc/NetworkManager/conf.d/100-disable-wifi-mac-randomization.conf`
with the content:
```text
[connection]
wifi.mac-address-randomization=1
 
[device]
wifi.scan-rand-mac-address=no
```
