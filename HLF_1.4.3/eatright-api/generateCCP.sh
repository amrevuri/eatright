#!/bin/bash
function buildConnectionJsonFile(){
echo "connection json file deployment start from here"
echo " Change line 7 & 8 for your path in the directories"
sleep 5

  NO_OF_ORDERERS=1
  echo ${NO_OF_ORDERERS}
  CPWD="/home/paperspace/workspace/cv2/HLF_1.4.3"
  SourcePATH="/home/paperspace/workspace/cv2/HLF_1.4.3/eatright-api"
  # CPWD="/usr/CLIF"
  declare -A orgDetails
  declare -A Org_Connection
  declare -A Orderer_Ca
  declare -A CHANNELS
  T_ORGS=4
  orgDetails[0,0]="fda"
  orgDetails[1,0]="arg"
  orgDetails[2,0]="bulletweights"
  orgDetails[3,0]="sfl"
  orgDetails[0,2]="FDA"
  orgDetails[1,2]="ARG"
  orgDetails[2,2]="BulletWeights"
  orgDetails[3,2]="SFL"
  orgDetails[0,1]=1
  orgDetails[1,1]=1
  orgDetails[2,1]=1
  orgDetails[3,1]=1
  CCC_NAME="eatrightcc"
  CHANNELS[0,0]="eatrightchannel"
IP=$(hostname -I|awk {'print $1'})

 Mxca=$(expr ${NO_OF_ORDERERS} - 1)
 echo "count of array" ${Mxca}
 MOPath="${CPWD}/"
  cd $MOPath
  ordererpath="${MOPath}crypto-config/ordererOrganizations/eatright.com/orderers"



  for count in `seq 0 $Mxca`  
  do 
  Orderer_Ca[${count}]="$(awk '{printf "%s\\n", $0}' ${ordererpath}/orderer.eatright.com/tls/ca.crt)"
  echo "certficate" ${Orderer_Ca[${count}]}
  done 


  maxcount1=$(expr ${T_ORGS} - 1)

  echo "Max Count >>>>>>> : " ${maxcount1}
for countcon in `seq 0 $maxcount1`
do 
 MOPATH="${CPWD}/"
 Org_Connection[${orgDetails[${countcon},0]}cacert]="$(awk '{printf "%s\\n", $0}' ${MOPATH}crypto-config/peerOrganizations/${orgDetails[${countcon},0]}.eatright.com/ca/ca.${orgDetails[${countcon},0]}.eatright.com-cert.pem)"
 Org_Connection[${orgDetails[${countcon},0]}peercert]="$(awk '{printf "%s\\n", $0}' ${MOPATH}crypto-config/peerOrganizations/${orgDetails[${countcon},0]}.eatright.com/peers/peer0.${orgDetails[${countcon},0]}.eatright.com/tls/ca.crt)"
 echo "peercert ${countcon}" ${Org_Connection[${orgDetails[${countcon},0]}peercert]}

 echo "Generating CA......." ${orgDetails[${countcon},2]} 
done


  maxcount=$(expr ${T_ORGS} - 1)

  echo "count" ${maxcount}
  for countcon in `seq 0 $maxcount`
  do 
 echo "Generating registration script......." ${orgDetails[${countcon},2]} 
  echo ${SourcePATH} "new source path"
  cd ${SourcePATH}
  cd ../
cat << EOF > ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
{
  "name": "${CCC_NAME}",
  "x-type": "hlfv1",
  "x-commitTimeout": 300,
  "version": "1.0.0",
  "client": {
    "organization": "${orgDetails[${countcon},2]}",
    "connection": {
      "timeout": {
        "peer": {
          "endorser": "300",
          "eventHub": "300",
          "eventReg": "300"
        },
        "orderer": "300"
      }
    }
  },
EOF
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
  "channels": {
    "${CHANNELS[0,0]}": {
        "orderers": [
EOF
maxorderer=$(expr ${NO_OF_ORDERERS} - 1)

for ordercount in `seq 0 $maxorderer`
do
if [ "${ordercount}" == "${maxorderer}" ];then

cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
          "orderer.eatright.com"
        ],
        "peers": {
EOF
else
  cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
          "orderer.eatright.com",
EOF
fi
done

for peer in `seq 0 $maxcount`
do
echo $maxcount

  if  [ "${peer}" == "${maxcount}" ];then
    maxpeer=$(expr ${orgDetails[${peer},1]} - 1)
    for peercount in `seq 0 $maxpeer`
    do
          if [ "${peercount}" == "${maxpeer}" ];then
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
            "peer${peercount}.${orgDetails[${peer},0]}.eatright.com": {
            "endorsingPeer": true,
            "chaincodeQuery": true,
            "eventSource": true
                  }
                }
            }
        },  
    "organizations": {      
EOF
        
  else
          
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
            "peer${peercount}.${orgDetails[${peer},0]}.eatright.com": {
            "endorsingPeer": true,
            "chaincodeQuery": true,
            "eventSource": true
          },
EOF


          fi
done
      else  
        maxpeer1=$(expr ${orgDetails[${peer},1]} - 1)
    for peercount1 in `seq 0 $maxpeer1`
    do
    
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
            "peer${peercount1}.${orgDetails[${peer},0]}.eatright.com": {
            "endorsingPeer": true,
            "chaincodeQuery": true,
            "eventSource": true
          },
EOF

  done
      fi    
done

for countorder in `seq 0 $maxcount`
do 
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json

      "${orgDetails[${countorder},2]}": {
        "mspid": "${orgDetails[${countorder},2]}MSP",
        "peers": [
EOF

  maxpeerorder=$(expr ${orgDetails[${countorder},1]} - 1)
    for peercountorder in `seq 0 $maxpeerorder`
    do
          if [ "${peercountorder}" == "${maxpeerorder}" ];then

cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json          
            "peer${peercountorder}.${orgDetails[${countorder},0]}.eatright.com"
        ],
EOF
          else
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json          
            "peer${peercountorder}.${orgDetails[${countorder},0]}.eatright.com",
EOF
          fi

done   
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json 
        "certificateAuthorities": [
          "ca.${orgDetails[${countorder},0]}.eatright.com"
        ]
EOF

if  [ "${countorder}" == "${maxcount}" ];then
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json 
    }
      },
EOF
else
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json 
    },

EOF

fi


done
IP=$(hostname -I|awk {'print$1'})
orderer_port=7050
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json 
  "orderers":{
EOF
for ordercount in `seq 0 $maxorderer`
do
  if [ "${ordercount}" != "0" ];then
      orderer_port=$(expr ${orderer_port} + 1000)
  fi

if [ "${ordercount}" == "${maxorderer}" ];then

cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json 
    "orderer.eatright.com": {
      "url": "grpc://${IP}:${orderer_port}",
      "grpcOptions": {
        "ssl-target-name-override": "orderer.eatright.com",
        "grpc.keepalive_time_ms": 600000,
        "grpc.max_send_message_length": 15728640,
        "grpc.max_receive_message_length": 15728640
      },
      "tlsCACerts": {
        "pem": "${Orderer_Ca[${ordercount}]}"
      }
    }
  },
  "peers": {
EOF
else 
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json 
      "orderer.eatright.com": {
      "url": "grpc://${IP}:${orderer_port}",
      "grpcOptions": {
        "ssl-target-name-override": "orderer.eatright.com",
        "grpc.keepalive_time_ms": 600000,
        "grpc.max_send_message_length": 15728640,
        "grpc.max_receive_message_length": 15728640
      },
      "tlsCACerts": {
        "pem": "${Orderer_Ca[${ordercount}]}"
      }
    },
EOF

fi 

done

peer_port=7051
event_port=7053

for peer in `seq 0 $maxcount`
do
  if  [ "${peer}" == "${maxcount}" ];then
    
    maxpeer=$(expr ${orgDetails[${peer},1]} - 1)
    for peercount in `seq 0 $maxpeer`
    do
    peer_port=$(expr ${peer_port} + 1000)
    event_port=$(expr ${event_port} + 1000)

      if [ "${peercount}" == "${maxpeer}" ];then

cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
      
      "peer${peercount}.${orgDetails[${peer},0]}.eatright.com": {
      "url": "grpc://${IP}:${peer_port}",
      "eventUrl": "grpc://${IP}:${event_port}",
      "grpcOptions": {
        "ssl-target-name-override": "peer${peercount}.${orgDetails[${peer},0]}.eatright.com",
        "hostnameOverride": "peer${peercount}.${orgDetails[${peer},0]}.eatright.com"
      },
      "tlsCACerts": {
        "pem": "${Org_Connection[${orgDetails[${peer},0]}peercert]}"
      }
    }
   },
    "certificateAuthorities":{
EOF

else
          
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json

      "peer${peercount}.${orgDetails[${peer},0]}.eatright.com": {
      "url": "grpc://${IP}:${peer_port}",
      "eventUrl": "grpc://${IP}:${event_port}",
      "grpcOptions": {
        "ssl-target-name-override": "peer${peercount}.${orgDetails[${peer},0]}.eatright.com",
        "hostnameOverride": "peer${peercount}.${orgDetails[${peer},0]}.eatright.com"
      },
      "tlsCACerts": {
        "pem": "${Org_Connection[${orgDetails[${peer},0]}peercert]}"
      }
    },

EOF


  fi
done
      else  
        maxpeer1=$(expr ${orgDetails[${peer},1]} - 1)

    for peercount in `seq 0 $maxpeer1`
    do
    if [ "${peercount}"  != "0" ];then
    peer_port=$(expr ${peer_port} + 1000)
    event_port=$(expr ${event_port} + 1000)
    fi
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json

     "peer${peercount}.${orgDetails[${peer},0]}.eatright.com": {
      "url": "grpc://${IP}:${peer_port}",
      "eventUrl": "grpc://${IP}:${event_port}",
      "grpcOptions": {
        "ssl-target-name-override": "peer${peercount}.${orgDetails[${peer},0]}.eatright.com"
      },
      "tlsCACerts": {
        "pem": "${Org_Connection[${orgDetails[${peercount},0]}peercert]}"
      }
    },

EOF
  done
  fi
done

ca_port=7054
for countco in `seq 0 $maxcount`
do 
  if [ "${countco}" != "0" ];then
    ca_port=$(expr ${ca_port} + 1000)
    echo "changed"
  fi
  echo "ca of ${countco}" ${Org_Connection[${orgDetails[${countco},0]}cacert]}
  if [ "${countco}" == "$maxcount" ];then
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
    "ca.${orgDetails[${countco},0]}.eatright.com": {
      "url": "http://${IP}:${ca_port}",
      "caName": "ca.${orgDetails[${countco},0]}.eatright.com",
      "httpOptions": {
        "verify": false
      },
      "tlsCACerts": {
        "pem": "${Org_Connection[${orgDetails[${countco},0]}cacert]}"
      }
    }
    }
    }
    
EOF
else 
cat <<EOF >> ${SourcePATH}/connection-${orgDetails[${countcon},2]}.json
    "ca.${orgDetails[${countco},0]}.eatright.com": {
      "url": "http://${IP}:${ca_port}",
      "caName": "ca.${orgDetails[${countco},0]}.eatright.com",
      "httpOptions": {
        "verify": false
      },
      "tlsCACerts": {
        "pem":"${Org_Connection[${orgDetails[${countco},0]}cacert]}"
      }
    },
EOF

fi

done
done
}


buildConnectionJsonFile
