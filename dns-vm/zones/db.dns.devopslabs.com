;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	ns.dns.devopslabs.com. admin.dns.devopslabs.com. (
			      3		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
; name servers - NS records
	IN	NS	ns.dns.devopslabs.com.

; name servers - A records
ns.dns.devopslabs.com.                IN     A      192.168.56.16  

; 192.168.0.0/16 - A records
ansible-vm.dns.devopslabs.com.       		  IN     A      192.168.56.10  
gitlab-vm.dns.devopslabs.com.         	          IN     A      192.168.56.11 
gitlab.devopslabs.com.dns.devopslabs.com.         IN     A      192.168.56.11 
host-win.dns.devopslabs.com.          		  IN     A      192.168.0.133
