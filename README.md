# Raspbian manual


## card flashing
Na partycji boot trzeba zrobić plik o nazwie `ssh` by aktywować łączenie się przez ssh
I wrzucić plik `wpa_supplicant.conf` z ustawieniami wifi:
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=PL

network={
 ssid="nazwa"
 psk="hasło"
}
```

Kopia zapasowa karty SD:
[Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/)

## Pierwsze podłączenie
### znajdowanie raspberry w sieci
bo adresie mac Pi
```bash
arp -a | findstr b8-27-eb
```
albo po adresie anteny wifi
```bash
arp -a | findstr 00-13-ef-40-09-27
```

## Konfiguracja
1. Uruchomienie skryptu (shh, passwd, apt update/upgrade)
   ```powershell
   cd ./raspbian-manual
   ./setup.ps1
   ```
2. raspi-config  `sudo raspi-config`
   1. Strefa czasowa
   2. Włączenie interfejsów GPIO
   3. update
   4. reboot, by wdrożyć zmiany `sudo reboot`

### Venv
Tworzenie
```bash
python3 -m venv "/home/pi/nazwaProjektu/venv"
# or
python3 -m venv ./venv
```
Aktywacja linux:
```
source nazwaProjektu/venv/bin/activate
```
Aktywacja Windows:
```
# In cmd.exe
nazwaProjektu\venv\Scripts\activate.bat
# In PowerShell
nazwaProjektu\venv\Scripts\Activate.ps1
```
Dezaktywacja:
```
deactivate
```

### Network fixes
#### Static IP
1. **Determine your Raspberry PI's current IP v4 address** if you don't already know it. \
   The easiest way to do this is by using the hostname -I command at the command prompt. \
   If you know its hostname, you can also ping the Pi from a different computer on the network.
   ```
   hostname -I
   ```
2. **Get your router's IP address** if you don't already know it. \
   The easiest way to do this is to use the command ip r and take the address that appears after "default via."
   ```
   ip r
   ```
3. **Get the IP address of your DNS** (domain name server) by enter the command below. \
   This may or may not be the same as your router's IP.
   ```
   grep "nameserver" /etc/resolv.conf
   ```
4. **Open /etc/dhcpcd.conf** for editing in nano.
   ```
   nano /etc/dhcpcd.conf
   ```
5. **Add the following lines** to the bottom of the file. \
   If such lines already exist and are not commented out, remove them.

   Replace the comments in brackets in the box below with the correct information. \
   Interface will be either wlan0 for Wi-Fi or eth0 for Ethernet.
   ```
   interface [INTERFACE]
   static_routers=[ROUTER IP]
   static domain_name_servers=[DNS IP]
   static ip_address=[STATIC IP ADDRESS YOU WANT]/24
   ```
   In our case, it looked like this.
   ```
   interface wlan0
   static_routers=192.168.0.1
   static domain_name_servers=62.179.1.61 62.179.1.63
   static ip_address=192.168.0.48/24
   ```
   You may wish to substitute "inform" for "static" on the last line. \
   Using inform means that the Raspberry Pi will attempt to get the IP address you requested, \
   but if it's not available, it will choose another. If you use static, it will have no IP v4 address at all if the requested one is in use.
6. Save the file and reboot.

#### Netis WF2120 fix
Add to `/etc/network/interfaces` this fragment:
```
auto lo
iface lo inet loopback
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

#### Disable MAC address randomization
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

## Setup deamon
1. Stwórz plik `nazwa-projektu.service`
   ```
   [Unit]
   Description=nazwaProjektu
   After=network.target

   [Service]
   #EnvironmentFile=/etc/environment
   ExecStart=/home/pi/nazwaProjektu/venv/bin/python -u /home/pi/nazwaProjektu/run.py
   WorkingDirectory=/home/pi/nazwaProjektu
   StandardOutput=inherit
   StandardError=inherit
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
2. Copy service file `nazwa-projektu.service` file into `/etc/systemd/system` as root, for example:
   ```bash
   sudo cp /home/pi/nazwaProjektu/nazwa-projektu.service /etc/systemd/system/nazwa-projektu.service \
   && sudo systemctl daemon-reload
   ```
3. Test deamon
   ```bash
   sudo systemctl start nazwa-projektu.service
   ```

4. When you are happy with the process of the app, you can have it start automatically on reboot by using this command:
   ```bash
   sudo systemctl enable nazwa-projektu.service
   ```

## Przydatne

Freeze packages
```bash
pip freeze | grep -v "pkg-resources" > requirements.txt
```

## systemctl
status
```bash
sudo systemctl status <service-name>.service
```
Logs:
```bash
journalctl -u <service-name>
```
Logs for the current boot:
```bash
journalctl -b -u <service-name>
```

