# A runing IKEv2 VPN's container on alpine linux system
## Overview ##
Let the IKEv2 vpn service run in the Docker container, do not need too much configuration, you just take the mirror on the Docker server, then run a container, the container generated certificate copy installed on your client, you can connect vpn The server. Welcome everyone's discussion！:blush:

## Features
* based on alpine image and Using supervisor to protect the IPSec process
* StrongSwan provides ikev2 VPN service
* In addition to Android and Linux, but other devices(Winodws 7+,Mac,iOS) by default comes with IKEv2 dial clients
* When the container is run, the certificate file is dynamically generated based on the environment variable (last version)
* Combined with Freeradius achieve Authentication, authorization, and accounting (AAA) (Done -> v0.1)

## Prerequisites
* The host can use physical machines, virtual machines, and VPS.
* The host machines and containers must be opened within ip_forward （net.ipv4.ip_forward）
* The host machines Install Docker engine.
* Support eap authentication radius server(EAP-RADIUS)

## Usage examples
### Install From Script `recommended approach`

1. As follows
```bash
# ./onekey_run_vpnserver.sh 'new_vpnuser' 'new_password'
```

`$1:` vpn user

`$2:` vpn password

*`WARNING`: As root privileged running*

### Install From Git source

1. Make a Image

[Method 1] Using git source code

```Bash
# git clone https://github.com/aliasmee/alpine-ikev2-vpn.git
```

build image:

```Bash
# cd alpine-ikev2-vpn/
# docker build -t ikev2 .
```

[Method 2] Using `docker pull` download images to the local from dockerhub
```Bash
# docker pull hanyifeng/alpine-ikev2-vpn
```

After building the image, run `docker run` command.

2. Start the service with the following command (Support radius AAA)

* eap-mschapv2 mode
```bash
# docker run --restart=always -itd --privileged -v /lib/modules:/lib/modules -e HOST_IP='Your's Public network IP' -e VPNUSER=jack -e VPNPASS="jack&opsAdmin" -p 500:500/udp -p 4500:4500/udp --name=ikev2-vpn ikev2
```

`HOST_IP:` Public network must be your host IP

`VPNUSER & VPNPASS :` The function is to customize the user name and password to connect to the VPN service.[Optional env]

Defalut vpnuser is `testUserOne`,passwd is `testOnePass`

* eap-radius mode
```bash
# docker run -itd --privileged -v /lib/modules:/lib/modules -e HOST_IP='Your's Public network IP' -e ACCOUNTING='yes' -e RADIUS_PORT='1812' -e RADIUS_SERVER='Your's radius server IP' -e RADIUS_SECRET='xxxxxxx' -e EAP_TYPE='eap-radius' -p 500:500/udp -p 4500:4500/udp --name=ikev2-vpn ikev2
```

`ACCOUNTING:` eap-radius mode Required.Value must be 'yes'

`RADIUS_PORT:` radius server running port. Required.

`RADIUS_SERVER:` radius server ip. Required.

`RADIUS_SECRET`: radius nas client psk. Required.

`EAP_TYPE`: ikev2 auth mode. Required.

3. Use the following command to generate the certificate and view the certificate contents
```Bash
# docker exec -it ikev2-vpn sh /usr/bin/vpn
net.ipv4.ip_forward = 1
ipsec: stopped
ipsec: started
Below the horizontal line is the content of the certificate. Copy the content to a file in the .cert suffix format. Such as: vpn.cert
______________________________________________________________
-----BEGIN CERTIFICATE-----
MIIDKjCCAhKgAwIBAgIIFsVYBZlPYyQwDQYJKoZIhvcNAQELBQAwMzELMAkGA1UE
BhMCY24xDjAMBgNVBAoTBWlsb3ZlMRQwEgYDVQQDEwtqZGNsb3VkIHZwbjAeFw0x
NzA3MjkxNTQzMzVaFw0yNzA3MjcxNTQzMzVaMDMxCzAJBgNVBAYTAmNuMQ4wDAYD
VQQKEwVpbG92ZTEUMBIGA1UEAxMLamRjbG91ZCB2cG4wggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCcCRvhZImsZgIGcaR7oG9mNUJHlP3/UvpClPhWraLe
m19Vi3oumo8QZTrVDbJgih81lL8djhME7b4uWUdSJgkYw8a0UF2Y1St/17HAU161
/C6ETRCsiMFruiSjbfCiHEpegthm6740CWPk1SShRruIxsXqvPZ584M/SGmnxep+
H+bhT+SshZRsbVlQetf2dDObcEiYqGLTAVpzzhU/X3eBMx2S3Iq41CFAXBQ50vAl
q+uUzBss8GEqY9C9FZJthl+0QQbwEGxrDsGB5+VldNfwNZTv3xOf9lYvtYXDZ9iM
xeCSMsCOgyvnHWT0xAC7EcM9VLC5o38t8l1MHt9meTp9AgMBAAGjQjBAMA8GA1Ud
EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBR18mRYIT8/nCJb
AwUYb8wc+R3QsTANBgkqhkiG9w0BAQsFAAOCAQEAFaxgrbFWUkX2StkplufJiSTz
73kRgOHGoR2FnGcwK6Jh0BTFPVSxn540WFEhEgqbXOrayg2K49NdNB2HheWGZLMr
zHGyEN1oBvYno8muLiWmeP4D3ihC6o99iR+riNaRo43xoYh2ksjetdk/OkbCtSJx
FePMC0WHptGeqyhW3XJfwJ1KZGffXBbsqARXVrG2zstvTHe9vi4JoIvUoGPLNAZ9
T6JXDKrHtWpPofVKuCreJkAn4pu2et9OhOgGYCoQrECVPsuWNtxuFVFYWaok4v2V
VDqjxrbBG+NdgjQm71vCNayb0gwv0qPkU5YLnY8pqloltN6l4fBqkUEqKvqSwA==
-----END CERTIFICATE-----
```

4. Copy this certificate to the remote client and name it xxx.cert or xxx.cert（Note：Windows need to modify the suffix pem for cer can be installed）
example:<br>
![](https://github.com/aliasmee/alpine-ikev2-vpn/blob/master/IKEv2_enable_example.png?raw=true)

5. Connect vpn it！
Open the network settings, create a new IKEv2 protocol VPN, enter the default VPN account and password, or use the custom user that starts the container to connect to VPN.

Create new VPN method is not described here ^_^.

## Other Tips
1. If you want to add VPN users, you can run the following command to enter the container and edit the ipsec.secrets file.
```bash
# docker exec -it ikev2-vpn bash
bash-4.3# vi /usr/local/etc/ipsec.secrets
```

`Pattern example:`
```
testUserOne %any : EAP "testOnePass"
testUserxxx %any : EAP "testpass"
```

```bash
bash-4.3# ipsec rereadsecrets
```

## Plan list
* Dynamically generated based on the environment variable （Completed）
* Support one-click installation (Completed)
* AAA Integrate Radius provides centralized Authentication, Authorization, and Accounting (Completed)
* Clients can connect without having to install a certificate
* Support for adding and deleting user functions

## Currently supported client device
Only test for the following client device system，You can test on the other system versions and feedback ！<br>
`Mac`:	10.11.4<br>
`iOS`:	10.2<br>
`Windows`:	10<br>
`Centos`:	6.8<br>
`Android`：(Download strongSwan APK)

## Authors
Name:	aliasmee

## Licensing
This project is licensed under the GNU General Public License - see the [LICENSE.md](https://github.com/aliasmee/IKEv2-radius-vpn/blob/master/LICENSE) file for details

## Acknowledgments
https://www.strongswan.org/

## Stargazers over time

[![Stargazers over time](https://starcharts.herokuapp.com/aliasmee/alpine-ikev2-vpn.svg)](https://starcharts.herokuapp.com/aliasmee/alpine-ikev2-vpn)
