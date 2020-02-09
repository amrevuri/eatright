#rm -R crypto-config/*

#cryptogen generate --config=crypto-config.yaml

rm config/*

configtxgen -profile EatRightOrdererGenesis -outputBlock ./config/genesis.block

configtxgen -profile EatRightOrgChannel -outputCreateChannelTx ./config/eatrightchannel.tx -channelID eatrightchannel
