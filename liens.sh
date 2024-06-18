https://videos.pexels.com/video-files/19880357/19880357-uhd_3840_2160_24fps.mp4

openssl ca -config openssl.cnf -name CA_CyberPkiRoot -in cyberPkiWebsite/CyberPkiWebsite.csr -out CyberPkiWebsite/private/cyberPkiWebSite_key.pem

$ openssl req -config openssl.cnf -new -subj "/C=FR/OU=0002 111111118/O=Cyber PKI Training/CN=Cyber PKI User CA" -key ./CyberPkiUser/private/CyberPkiUser_key.pem -out ./CyberPkiUser/CyberPkiUser.csr

$ openssl req -in ./CyberPkiWebSite/CyberPkiWebsite.csr -text on a généré les deux CSR nécessaires et vérifié le contenu de CyberPkiWebsite pour s’assurer qu'il est correct.

$ openssl req -config openssl.cnf -new -subj "/C=FR/OU=0002 111111118/O=Cyber PKI Training/CN=Cyber PKI Website CA" -key ./CyberPkiWebSite/private/CyberPkiWebsite_key.pem -out ./CyberPkiWebSite/CyberPkiWebsite.csr

$ openssl req -in ./CyberPkiUser/CyberPkiUser.csr -text

