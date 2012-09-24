#!/bin/bash

curl -d @- -X POST -H 'Content-Type: application/json' http://localhost:8080/log << EOF
{
  "connected_devices": [ "e4:d5:3d:testmac", "e4:d5:3d:testmac2", "e4:d5:3d:testmac3"],
  "hostname": "ml-a215-ope",
  "relay_timestamp": $(date +%s),
  "relay_puavo_domain": "esbo.opinsys.fi",
  "type": "wlan",
  "wlan_event": "hotspot_state",
  "wlaninterface": "wlan0"
}
EOF
