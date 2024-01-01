# raspbian-manual


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
2. raspi-config  `sudo raspi-config`
   1. Strefa czasowa
   2. Włączenie interfejsów GPIO
   3. update
   4. reboot by wdrożyć zmiany `sudo reboot`



### Netis WF2120 fix
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
