# A runing IKEv2 VPN's container on alpine linux system
## Overview ##
Let the IKEv2 vpn service run in the Docker container, do not need too much configuration, you just take the mirror on the Docker server, then run a container, the container generated certificate copy installed on your client, you can connect vpn The server. Welcome everyone's discussion！:blush:

## Features
* based on alpine image and Using supervisor to protect the IPSec process
* StrongSwan provides ikev2 VPN service
* In addition to Android and Linux, but other devices(Winodws 7+,Mac,iOS) by default comes with IKEv2 dial clients
* When the container is run, the certificate file is dynamically generated based on the environment variable (last version)
* Combined with Freeradius achieve Authentication, authorization, and accounting (AAA) (last version)

## Prerequisites
* The host can use physical machines, virtual machines, and VPS.
* The host machines and containers must be opened within ip_forward （net.ipv4.ip_forward）
* The host machines Install Docker engine.

## Usage examples
1. Clone git
```Bash
# git clone https://github.com/aliasmee/alpine-ikev2-vpn.git
```
Or use `docker pull` to download images to the local
```Bash
# docker pull hanyifeng/alpine-ikev2-vpn
```
Then run `docker run` command.


2. Using docker build can create an automated build image,Then use the following command to run
```Bash
# cd alpine-ikev2-vpn/
# docker build -t ikev2 .
# docker run -itd --privileged -v /lib/modules:/lib/modules -e HOSTIP='Your's Public network IP' -e VPNUSER=jack -e VPNPASS="jack&opsAdmin" -p 500:500/udp -p 4500:4500/udp --name=ikev2-vpn ikev2
```
    **HOSTIP :Public network must be your host IP**
    **[$VPNUSER] & [$VPNPASS] env Optional,The function is to customize the user name and password to connect to the VPN service.**
    **Defalut vpnuser is testUserOne,passwd is testOnePass**


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
    **Pattern: testUserOne %any : EAP "testOnePass" **
## Plan list
* Dynamically generated based on the environment variable （Completed）

## Currently supported client device 
Only test for the following client device system，You can test on the other system versions and feedback ！<br>
`Mac`:	10.11.4<br>
`iOS`:	10.2<br>
`Windows`:	10<br>
`Centos`:	6.8<br>
`Android`：(Download strongSwan APK)

## Authors
Name:	Yifeng Han<br>
e-mail:	 xhanyifeng@gmail.com

## Licensing
This project is licensed under the GNU General Public License - see the [LICENSE.md](https://github.com/aliasmee/IKEv2-radius-vpn/blob/master/LICENSE) file for details

## Acknowledgments
https://www.strongswan.org/

