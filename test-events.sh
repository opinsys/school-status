#!/bin/bash


curl -d @- -X POST -H 'Content-Type: application/json' http://localhost:8080/log << EOF
{
  "type": "wlan",
  "date": "1348134879",
  "wlaninterface": "wlan0",
  "event": "AP-STA-CONNECTED",
  "mac": "e4:d5:3d:testmac",
  "relay_hostname": "ltsp11",
  "relay_puavo_domain": "esbo.opinsys.fi",
  "hostname": "ml-a215-ope",
  "relay_timestamp": 1348134880,
  "client_manufacturer": "Hon Hai Precision Ind. Co.,Ltd.",
  "school_id": "11121",
  "school_name": "Mattlidens skola"
}
EOF


sleep 2

curl -d @- -X POST -H 'Content-Type: application/json' http://localhost:8080/log << EOF
{
  "type": "wlan",
  "date": "1348134880",
  "wlaninterface": "wlan0",
  "event": "AP-STA-DISCONNECTED",
  "mac": "e4:d5:3d:testmac",
  "relay_hostname": "ltsp11",
  "relay_puavo_domain": "esbo.opinsys.fi",
  "hostname": "ml-a215-ope",
  "relay_timestamp": 1348134880,
  "client_manufacturer": "Hon Hai Precision Ind. Co.,Ltd.",
  "school_id": "11121",
  "school_name": "Mattlidens skola"
}
EOF
