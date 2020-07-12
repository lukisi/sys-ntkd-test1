# Deploy e test #1

## Building

Compila nella directory `local_builds` che è ignorata da Git
per via del contenuto di `~/.config/git/ignore`.

Dalla directory radice del repository dare questi comandi:

```
autoreconf -f -i
SRCDIR=$(pwd)
mkdir -p local_builds
cd local_builds
export VALAFLAGS="-g"
export CFLAGS="-g -O0"
export LDFLAGS="-g"
${SRCDIR}/configure
make
```

Si ottiene l'eseguibile `sys_ntkd_test1`.

## Testing

Il test consiste nel simulare questo scenario:

```
          Nodo 123                          Nodo 456          
          --------                          --------          
   eth1  |        |  eth2            eth1  |        |  eth2   
  ---====|        |====----------------====|        |====-----
         |        |                        |        |         
          --------                          --------          
```

Nella directory dove si trova l'eseguibile, aprire
5 terminali.

Sul terminale #1 dare il comando `eth_domain -i 123_eth1 -v`.  
Il processo resta appeso.

Sul terminale #2 dare il comando `eth_domain -i 456_eth2 -v`.  
Il processo resta appeso.

Sul terminale #3 dare il comando `eth_domain -i 123_eth2 -i 456_eth1 -v`.  
Il processo resta appeso.

Sul terminale #4 dare il comando `./sys_ntkd_test1 -p 123 -i eth1 -i eth2`.  
Il processo produce alcuni output.

Sul terminale #5 dare il comando `./sys_ntkd_test1 -p 456 -i eth1 -i eth2`.  
Il processo produce alcuni output.

```
eth_domain -i 123_eth1 -v
eth_domain -i 456_eth2 -v
eth_domain -i 123_eth2 -i 456_eth1 -v
./sys_ntkd_test1 -p 123 -i eth1 -i eth2
./sys_ntkd_test1 -p 456 -i eth1 -i eth2
```

***

Appunti:

```
luca@dell:~/github/sys-ntkd-test1/local_builds$ ./sys_ntkd_test1 -p 456 -i eth1 -i eth2
$ sysctl net.ipv4.ip_forward=1
$ sysctl net.ipv4.conf.all.rp_filter=0
INFO: mac for 456,eth1 is fe:aa:aa:74:18:40.
$ sysctl net.ipv4.conf.eth1.rp_filter=0
$ sysctl net.ipv4.conf.eth1.arp_ignore=1
$ sysctl net.ipv4.conf.eth1.arp_announce=2
$ ip link set dev eth1 address fe:aa:aa:74:18:40
$ ip link set dev eth1 up
started datagram_system_listen recv_456_eth1 send_456_eth1 fe:aa:aa:74:18:40.
$ ip address add 169.254.247.99 dev eth1
Neighborhood: [18:2.5527899]: Signal nic_address_set 169.254.247.99.
started stream_system_listen conn_169.254.247.99.
INFO: linklocal for fe:aa:aa:74:18:40 is 169.254.247.99.
INFO: mac for 456,eth2 is fe:aa:aa:57:78:43.
$ sysctl net.ipv4.conf.eth2.rp_filter=0
$ sysctl net.ipv4.conf.eth2.arp_ignore=1
$ sysctl net.ipv4.conf.eth2.arp_announce=2
$ ip link set dev eth2 address fe:aa:aa:57:78:43
$ ip link set dev eth2 up
started datagram_system_listen recv_456_eth2 send_456_eth2 fe:aa:aa:57:78:43.
$ ip route add 169.254.22.58 dev eth1 src 169.254.247.99
$ ip address add 169.254.131.208 dev eth2

** (sys_ntkd_test1:380345): ERROR **: 21:18:02.588: neighborhood_helpers.vala:70: not in this test
Trace/breakpoint trap (core dumped)
luca@dell:~/github/sys-ntkd-test1/local_builds$ 



luca@dell:~/github/sys-ntkd-test1/local_builds$ ./sys_ntkd_test1 -p 123 -i eth1 -i eth2
$ sysctl net.ipv4.ip_forward=1
$ sysctl net.ipv4.conf.all.rp_filter=0
INFO: mac for 123,eth1 is fe:aa:aa:94:27:42.
$ sysctl net.ipv4.conf.eth1.rp_filter=0
$ sysctl net.ipv4.conf.eth1.arp_ignore=1
$ sysctl net.ipv4.conf.eth1.arp_announce=2
$ ip link set dev eth1 address fe:aa:aa:94:27:42
$ ip link set dev eth1 up
started datagram_system_listen recv_123_eth1 send_123_eth1 fe:aa:aa:94:27:42.
$ ip address add 169.254.231.143 dev eth1
Neighborhood: [29:52.984952]: Signal nic_address_set 169.254.231.143.
started stream_system_listen conn_169.254.231.143.
INFO: linklocal for fe:aa:aa:94:27:42 is 169.254.231.143.
INFO: mac for 123,eth2 is fe:aa:aa:72:69:61.
$ sysctl net.ipv4.conf.eth2.rp_filter=0
$ sysctl net.ipv4.conf.eth2.arp_ignore=1
$ sysctl net.ipv4.conf.eth2.arp_announce=2
$ ip link set dev eth2 address fe:aa:aa:72:69:61
$ ip link set dev eth2 up
started datagram_system_listen recv_123_eth2 send_123_eth2 fe:aa:aa:72:69:61.
$ ip address add 169.254.22.58 dev eth2
Neighborhood: [29:53.022672]: Signal nic_address_set 169.254.22.58.
started stream_system_listen conn_169.254.22.58.
INFO: linklocal for fe:aa:aa:72:69:61 is 169.254.22.58.
INFO: nodeid for 123_0 is 1575385657.
INFO: 123_0 has address {"pos":[0,1,1,0],"sizes":[2,2,2,4]} and fp {"id":166941834,"level":0,"elderships":[0,0,0,0],"elderships-seed":[]}.
[29:53.029842]: IpCommands.main_start: started.
$ ip address add 10.0.0.40 dev eth1
$ ip address add 10.0.0.50 dev eth1
$ ip address add 10.0.0.62 dev eth1
$ ip address add 10.0.0.6 dev eth1
$ ip address add 10.0.0.40 dev eth2
$ ip address add 10.0.0.50 dev eth2
$ ip address add 10.0.0.62 dev eth2
$ ip address add 10.0.0.6 dev eth2
$ ip address add 10.0.0.32 dev lo
$ iptables -t nat -A POSTROUTING -d 10.0.0.64/27 -j SNAT --to 10.0.0.6
$ ip rule add table ntk
$ ip route add unreachable 10.0.0.8/29 table ntk
$ ip route add unreachable 10.0.0.72/29 table ntk
$ ip route add unreachable 10.0.0.16/29 table ntk
$ ip route add unreachable 10.0.0.80/29 table ntk
$ ip route add unreachable 10.0.0.24/29 table ntk
$ ip route add unreachable 10.0.0.88/29 table ntk
$ ip route add unreachable 10.0.0.0/30 table ntk
$ ip route add unreachable 10.0.0.64/30 table ntk
$ ip route add unreachable 10.0.0.56/30 table ntk
$ ip route add unreachable 10.0.0.4/31 table ntk
$ ip route add unreachable 10.0.0.68/31 table ntk
$ ip route add unreachable 10.0.0.60/31 table ntk
$ ip route add unreachable 10.0.0.48/31 table ntk
$ ip route add unreachable 10.0.0.7/32 table ntk
$ ip route add unreachable 10.0.0.71/32 table ntk
$ ip route add unreachable 10.0.0.63/32 table ntk
$ ip route add unreachable 10.0.0.51/32 table ntk
$ ip route add unreachable 10.0.0.41/32 table ntk
[29:53.334293]: IpCommands.main_start: finished.
Qspn: [29:53.338894]: Signal qspn_bootstrap_complete: my id 1575385657 is in network_id 166941834.
$ ip route add 169.254.247.99 dev eth2 src 169.254.22.58

** (sys_ntkd_test1:482973): ERROR **: 11:30:11.353: skeleton_factory.vala:254: not in this test
Trace/breakpoint trap (core dumped)
luca@dell:~/github/sys-ntkd-test1/local_builds$ 



```
