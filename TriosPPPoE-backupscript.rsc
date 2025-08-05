# TriosPPPoE-backupscript

/interface pppoe-client
add disabled=no interface=bridge name=pppoe-out1 user=000000000@stc.net.sa
add disabled=no interface=bridge name=pppoe-out2 user=000000000@stc.net.sa
add disabled=no interface=bridge name=pppoe-out3 user=000000000@stc.net.sa
/routing table
add disabled=no fib name=rtab-1
add disabled=no fib name=rtab-2
add disabled=no fib name=rtab-3
/interface bridge port
add bridge=bridge interface=ether1
/ipv6 settings
set disable-ipv6=yes
/interface list member
add interface=pppoe-out1 list=WAN
add interface=pppoe-out2 list=WAN
add interface=pppoe-out3 list=WAN
/ip dhcp-server network
add address=192.168.88.0/24 dns-server=84.235.57.230,84.235.6.55 gateway=\
    192.168.88.1 netmask=24
/ip dns
set allow-remote-requests=yes servers=84.235.57.230,84.235.6.55
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
/ip route
add disabled=no distance=2 dst-address=0.0.0.0/0 gateway=pppoe-out1 \
    routing-table=rtab-1 suppress-hw-offload=no
add disabled=no distance=3 dst-address=0.0.0.0/0 gateway=pppoe-out2 \
    routing-table=rtab-2 suppress-hw-offload=no
add disabled=no distance=4 dst-address=0.0.0.0/0 gateway=pppoe-out3 \
    routing-table=rtab-3 suppress-hw-offload=no
/ip upnp
set enabled=yes
