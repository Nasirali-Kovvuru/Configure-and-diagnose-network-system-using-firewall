#!/bin/sh
IPT=/sbin/iptables
# NAT interface NIF=enp0s9
# NAT IP address NIP='10.0.98.100'
# Host-only interface HIF=enp0s3
# Host-only IP addres HIP='192.168.60.100'
# DNS nameserver NS='10.0.98.3'
#########33NS='8.8.8.8'
## Reset the firewall to an empty, but friendly state
# Flush all chains in FILTER table $IPT -t filter -F
####$sudo iptables -A INPUT -p tcp --dport 80 -j REJECT ##sudo $IPT -t filter -A INPUT -p tcp --dport 80 -j REJECT
# Delete any user-defined chains in FILTER table
#$IPT -t filter -X
# Flush all chains in NAT table $IPT -t nat -F
# Delete any user-defined chains in NAT table $IPT -t nat -X
# Flush all chains in MANGLE table
$IPT -t mangle -F
# Delete any user-defined chains in MANGLE table $IPT -t mangle -X
# Flush all chains in RAW table
$IPT -t raw -F
# Delete any user-defined chains in RAW table $IPT -t mangle -X
# Default policy is to send to a dropping chain
####$IPT -t filter -P INPUT ACCEPT
#$IPT -t filter -P INPUT ACCEPT
####TASK14##$IPT -t filter -A OUTPUT -s 127.0.0.0/24 -p tcp --dport 80 -j REJECT
#$IPT -t filter -P OUTPUT ACCEPT
#$IPT -t filter -P FORWARD ACCEPT
##TASK15##
####$IPT -t filter -P INPUT DROP ##1
####$IPT -t filter -I INPUT -p icmp -j ACCEPT ##2
####$IPT -t filter -I OUTPUT -p icmp -j ACCEPT ##2
####$IPT -t filter -P OUTPUT DROP ##1 ####$IPT -t filter -P FORWARD DROP ##1
##TASKS17-20#####
$IPT -t filter -P INPUT DROP
$IPT -t filter -I INPUT -p icmp -j ACCEPT ##1
$IPT -t filter -A INPUT -s 127.0.0.0/24 -p tcp -j ACCEPT ##2
##$IPT -t filter -A INPUT -s 10.0.98.3 -p udp --dport 53 -j ACCEPT
#$IPT -t filter -A INPUT -s 10.0.98.2 -p udp --dport 53 -j ACCEPT
#$IPT -t filter -A INPUT -s 10.0.98.100 -p udp --dport 53 -j ACCEPT
#$IPT -t filter -A INPUT -s 10.0.98.3 -p tcp --dport 53 -j ACCEPT
#$IPT -t filter -A INPUT -s 10.0.98.2 -p tcp --dport 53 -j ACCEPT #$IPT -t filter -A INPUT -s 10.0.98.100 -p tcp --dport 53 -j ACCEPT $IPT -t filter -A INPUT -s 10.0.98.100 -j ACCEPT ##3
$IPT -t filter -A INPUT -s 10.0.98.3 -j ACCEPT ##3 #$IPT -t filter -A INPUT -p tcp -j ACCEPT ##4##20
$IPT -t filter -A INPUT -p tcp -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT ##20
###IPADDRHOST=192.168.0.1
###UNPRIVPORTS="1025:65535"
$IPT -t filter -A INPUT -p tcp --dport 22 -j ACCEPT ##21
###$IPT -A INPUT -i $HIP -p tcp !--syn --sport 443 -d $IPADDRHOST -- match multiport --dports $UNPRIVPORTS -j ACCEPT ##21
$IPT -t filter -A INPUT -p tcp --dport 443 -j ACCEPT ##21
$IPT -t filter -A INPUT -p icmp -s 192.168.60.111 -j ACCEPT
$IPT -t filter -A OUTPUT -p icmp -s 192.168.60.111 -j ACCEPT##22
sudo iptables -I INPUT -s 192.168.60.111 -p tcp -m tcp --dport 10022 -j ACCEPT##23
##5
###
$IPT -t filter -P OUTPUT DROP
$IPT -t filter -A OUTPUT -s 127.0.0.0/24 -p tcp -j ACCEPT ##2 $IPT -t filter -A OUTPUT -p icmp -j ACCEPT ##1
#$IPT -t filter -A OUTPUT -s 10.0.98.3 -p udp --dport 53 -j ACCEPT #$IPT -t filter -A OUTPUT -s 10.0.98.2 -p udp --dport 53 -j ACCEPT #$IPT -t filter -A OUTPUT -s 10.0.98.100 -p udp --dport 53 -j ACCEPT #$IPT -t filter -A OUTPUT -s 10.0.98.3 -p tcp --dport 53 -j ACCEPT #$IPT -t filter -A OUTPUT -s 10.0.98.2 -p tcp --dport 53 -j ACCEPT
#$IPT -t filter -A OUTPUT -s 10.0.98.100 -p tcp --dport 53 -j ACCEPT
##$IPT -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
##$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
$IPT -t filter -A OUTPUT -s 10.0.98.100 -j ACCEPT ##3 $IPT -t filter -A OUTPUT -s 10.0.98.3 -j ACCEPT ##3
#$IPT -t filter -I OUTPUT -p tcp -j ACCEPT ##4##20 #task 20
$IPT -t filter -I OUTPUT -p tcp -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
###$IPT -t filter -I OUTPUT -p tcp --dport 22 -j ACCEPT ##21
###$IPT -A OUTPUT -o $HIP -p tcp -s $IPADDRHOST -m multiport -- sports $UNPRIVPORTS --dport 443 -j ACCEPT ##21
$IPT -t filter -P FORWARD DROP
$IPT -t filter -A FORWARD -i $HIF -j ACCEPT
$IPT -t filter -A FORWARD -i $NIF -m conntrack --ctstate ESTABLISHED, RELATED -j ACCEPT ###26
$IPT -t nat -A POSTROUTING -j SNAT -o $NIF --to $NIP ##27
#### Create logging chains $IPT -t filter -N input_log $IPT -t filter -N output_log $IPT -t filter -N forward_log
# Set some logging targets for DROPPED packets
$IPT -t filter -A input_log -j LOG --log-level notice --log-prefix "input drop: "
$IPT -t filter -A output_log -j LOG --log-level notice --log-prefix "output drop: "
$IPT -t filter -A forward_log -j LOG --log-level notice --log-prefix "forward drop: "
echo "Added logging"
# Return from the logging chain to the built-in chain $IPT -t filter -A input_log -j RETURN
$IPT -t filter -A output_log -j RETURN $IPT -t filter -A forward_log -j RETURN
# These rules must be inserted at the end of the built-in
# chain to log packets that will be dropped by the default
# DROP policy
$IPT -t filter -A INPUT -j input_log
$IPT -t filter -A OUTPUT -j output_log
$IPT -t filter -A FORWARD -j forward_log
#####$ping 127.0.0.1
echo $input_log
echo $output_log
echo $forward_log