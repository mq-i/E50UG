# 2025-10-13 00:17:31 by RouterOS 7.20.1
# software id = N5UH-PKFR
#
# model = E50UG
# serial number = HHC0A1DAP4J
/interface bridge
add admin-mac=F4:1E:57:7F:0D:BA auto-mac=no comment=defconf name=bridge
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-out1 use-peer-dns=yes user=\
    115235447@stc.net.sa
add disabled=no interface=ether1 name=pppoe-out2 user=115235447@stc.net.sa
add disabled=no interface=ether1 name=pppoe-out3 user=115235447@stc.net.sa
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254
/ip dhcp-server
add address-pool=default-dhcp interface=bridge name=defconf
/routing table
add disabled=no fib name=rtab-1
add disabled=no fib name=rtab-2
add disabled=no fib name=rtab-3
/disk settings
set auto-media-interface=bridge auto-media-sharing=yes auto-smb-sharing=yes
/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=ether5
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=ether1 list=WAN
add interface=pppoe-out1 list=WAN
add interface=pppoe-out2 list=WAN
add interface=pppoe-out3 list=WAN
/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=\
    192.168.88.0
/ip dhcp-client
add comment=defconf disabled=yes interface=ether1
/ip dhcp-server network
add address=192.168.88.0/24 comment=defconf dns-server=\
    84.235.57.230,84.235.6.55 gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=192.168.88.1 comment=defconf name=router.lan type=A
/ip firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related hw-offload=yes
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
/ip firewall mangle
add action=mark-connection chain=prerouting connection-mark=no-mark \
    connection-state=new in-interface=pppoe-out1 new-connection-mark=out1
add action=mark-routing chain=output connection-mark=out1 new-routing-mark=\
    rtab-1 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    connection-state=new in-interface=pppoe-out2 new-connection-mark=out2
add action=mark-routing chain=output connection-mark=out2 new-routing-mark=\
    rtab-2 passthrough=no
add action=mark-connection chain=prerouting connection-mark=no-mark \
    connection-state=new in-interface=pppoe-out3 new-connection-mark=out3
add action=mark-routing chain=output connection-mark=out3 new-routing-mark=\
    rtab-3 passthrough=no
add action=mark-connection chain=prerouting comment=\
    "Load Balance 1 Mark Connection" connection-mark=no-mark \
    connection-state=new dst-address-type=!local in-interface-list=LAN \
    new-connection-mark=out1 per-connection-classifier=\
    both-addresses-and-ports:3/0
add action=mark-routing chain=prerouting comment=\
    "Load Balance 1 Mark Routing" connection-mark=out1 in-interface-list=LAN \
    new-routing-mark=rtab-1 passthrough=no
add action=mark-connection chain=prerouting comment=\
    "Load Balance 2 Mark Connection" connection-mark=no-mark \
    connection-state=new dst-address-type=!local in-interface-list=LAN \
    new-connection-mark=out2 per-connection-classifier=\
    both-addresses-and-ports:3/1
add action=mark-routing chain=prerouting comment=\
    "Load Balance 2 Mark Routing" connection-mark=out2 in-interface-list=LAN \
    new-routing-mark=rtab-2 passthrough=no
add action=mark-connection chain=prerouting comment=\
    "Load Balance 3 Mark Connection" connection-mark=no-mark \
    connection-state=new dst-address-type=!local in-interface-list=LAN \
    new-connection-mark=out3 per-connection-classifier=\
    both-addresses-and-ports:3/2
add action=mark-routing chain=prerouting comment=\
    "Load Balance 3 Mark Routing" connection-mark=out3 in-interface-list=LAN \
    new-routing-mark=rtab-3 passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN
/ip route
add disabled=no distance=2 dst-address=0.0.0.0/0 gateway=pppoe-out1 \
    routing-table=rtab-1 suppress-hw-offload=no
add disabled=no distance=3 dst-address=0.0.0.0/0 gateway=pppoe-out2 \
    routing-table=rtab-2 suppress-hw-offload=no
add disabled=no distance=4 dst-address=0.0.0.0/0 gateway=pppoe-out3 \
    routing-table=rtab-3 suppress-hw-offload=no
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" \
    dst-port=33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=fasttrack-connection chain=forward comment="defconf: fasttrack6" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
