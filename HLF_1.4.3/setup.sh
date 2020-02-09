echo "Setting up the network.."

echo "Creating channel genesis block.."

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=FDAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fda.eatright.com/users/Admin@fda.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.fda.eatright.com:7051" cli peer channel create -o orderer.eatright.com:7050 -c eatrightchannel -f /etc/hyperledger/configtx/eatrightchannel.tx


sleep 5

echo "Channel genesis block created."

echo "peer0.fda.eatright.com joining the channel..."
# Join peer0.fda.eatright.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=FDAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fda.eatright.com/users/Admin@fda.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.fda.eatright.com:7051" cli peer channel join -b eatrightchannel.block

echo "peer0.fda.eatright.com joined the channel"

echo "peer0.arg.eatright.com joining the channel..."

# Join peer0.arg.eatright.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=ARGMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/arg.eatright.com/users/Admin@arg.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.arg.eatright.com:7051" cli peer channel join -b eatrightchannel.block

echo "peer0.arg.eatright.com joined the channel"

echo "peer0.bulletweights.eatright.com joining the channel..."
# Join peer0.bulletweights.eatright.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=BulletWeightsMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bulletweights.eatright.com/users/Admin@bulletweights.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.bulletweights.eatright.com:7051" cli peer channel join -b eatrightchannel.block
sleep 5

echo "peer0.bulletweights.eatright.com joined the channel"

echo "peer0.sfl.eatright.com joining the channel..."
# Join peer0.sfl.eatright.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=SFLMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/sfl.eatright.com/users/Admin@sfl.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.sfl.eatright.com:7051" cli peer channel join -b eatrightchannel.block
sleep 5

echo "peer0.sfl.eatright.com joined the channel"


# install chaincode
# Install code on fda peer
echo "Installing eatright chaincode to peer0.fda.eatright.com..."

docker exec -e "CORE_PEER_LOCALMSPID=FDAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fda.eatright.com/users/Admin@fda.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.fda.eatright.com:7051" cli peer chaincode install -n eatrightcc -v 1.0 -p github.com/eatright/go -l golang

echo "Installed eatright chaincode to peer0.fda.eatright.com"

echo "Installing eatright chaincode to peer0.arg.eatright.com...."

# Install code on arg peer
docker exec -e "CORE_PEER_LOCALMSPID=ARGMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/arg.eatright.com/users/Admin@arg.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.arg.eatright.com:7051" cli peer chaincode install -n eatrightcc -v 1.0 -p github.com/eatright/go -l golang

echo "Installed eatright chaincode to peer0.arg.eatright.com"

echo "Installing eatright chaincode to peer0.bulletweights.eatright.com..."
# Install code on bulletweights peer
docker exec -e "CORE_PEER_LOCALMSPID=BulletWeightsMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bulletweights.eatright.com/users/Admin@bulletweights.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.bulletweights.eatright.com:7051" cli peer chaincode install -n eatrightcc -v 1.0 -p github.com/eatright/go -l golang

sleep 5

echo "Installed eatright chaincode to peer0.bulletweights.eatright.com"

echo "Instantiating eatright chaincode.."

echo "Installing eatright chaincode to peer0.sfl.eatright.com..."
# Install code on Sea Food Logistics  peer
docker exec -e "CORE_PEER_LOCALMSPID=SFLMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/sfl.eatright.com/users/Admin@sfl.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.sfl.eatright.com:7051" cli peer chaincode install -n eatrightcc -v 1.0 -p github.com/eatright/go -l golang

sleep 5

echo "Installed eatright chaincode to peer0.bulletweights.eatright.com"

docker exec -e "CORE_PEER_LOCALMSPID=FDAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/fda.eatright.com/users/Admin@fda.eatright.com/msp" -e "CORE_PEER_ADDRESS=peer0.fda.eatright.com:7051" cli peer chaincode instantiate -o orderer.eatright.com:7050 -C eatrightchannel -n eatrightcc -l golang -v 1.0 -c '{"Args":[""]}' -P "OR ('FDAMSP.member','ARGMSP.member','BulletWeightsMSP.member')"

echo "Instantiated eatright chaincode."

echo "Following is the docker network....."

docker ps
