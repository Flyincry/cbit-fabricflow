# Setup envs and build for dev

make orderer peer configtxgen
# Building build/bin/orderer
# GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/orderer
# Building build/bin/peer
# GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/peer
# Building build/bin/configtxgen
# GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/configtxgen

export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
# generate gensis block
configtxgen -profile SampleDevModeSolo -channelID syschannel -outputBlock genesisblock -configPath $FABRIC_CFG_PATH -outputBlock "$(pwd)/sampleconfig/genesisblock"
# 2020-09-14 17:36:37.295 EDT [common.tools.configtxgen] doOutputBlock -> INFO 004 Generating genesis block
# 2020-09-14 17:36:37.296 EDT [common.tools.configtxgen] doOutputBlock -> INFO 005 Writing genesis block


# Start orderer
ORDERER_GENERAL_GENESISPROFILE=SampleDevModeSolo orderer
# 2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00b Starting orderer:
#  Version: 2.3.0
#  Commit SHA: 298695ae2
#  Go version: go1.15
#  OS/Arch: darwin/amd64
# 2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00c Beginning to serve requests

# Start peer in another terminal windows
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
FABRIC_LOGGING_SPEC=chaincode=debug CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 peer node start --peer-chaincodedev=true
# 2020-09-14 17:38:45.324 EDT [nodeCmd] serve -> INFO 00e Running in chaincode development mode
# ...
# 2020-09-14 17:38:45.326 EDT [nodeCmd] serve -> INFO 01a Started peer with ID=[jdoe], network ID=[dev], address=[192.168.1.134:7051]


# Create channel and join peer in a new terminal
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
configtxgen -channelID ch1 -outputCreateChannelTx ch1.tx -profile SampleSingleMSPChannel -configPath $FABRIC_CFG_PATH
peer channel create -o 127.0.0.1:7050 -c ch1 -f ch1.tx
# 2020-09-14 17:42:56.931 EDT [cli.common] readBlock -> INFO 002 Received block: 0
peer channel join -b ch1.block
# 2020-09-14 17:43:34.976 EDT [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel

# Build Chaincode
go build -o simpleChaincode ./integration/chaincode/simple/cmd
# go build -o simpleChaincode /usr/local/gopath/src/github.com/hyperledger/fabric-cluster/chaincode/go/
# Start the chaincode
CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 ./simpleChaincode -peer.address 127.0.0.1:7052
# CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 ./mycc/mycc -peer.address 127.0.0.1:7052
# CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 /usr/local/gopath/src/github.com/hyperledger/fabric-cluster/chaincode/go/mycc -peer.address 127.0.0.1:7052
# 2020-09-14 17:53:43.413 EDT [chaincode] sendReady -> DEBU 045 Changed to state ready for chaincode mycc:1.0
# Approve and commit
peer lifecycle chaincode approveformyorg  -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')" --package-id mycc:1.0
peer lifecycle chaincode checkcommitreadiness -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')"
peer lifecycle chaincode commit -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')" --peerAddresses 127.0.0.1:7051
# 2020-09-14 17:56:30.820 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [f22b3c25dfea7fe0b28af9ee818056db81e29a9421c83fe00eb22fa41d1d1e21] committed with status (VALID) at
# Chaincode definition for chaincode 'mycc', version '1.0', sequence '1' on channel 'ch1' approval status by org:
# SampleOrg: true
# 2020-09-14 17:57:43.295 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [fb803e8b0b4eae6b3a9ed35668f223753e1a34ffd2a7042f9e5bb516a383eb32] committed with status (VALID) at 127.0.0.1:7051

# Test: Invoke
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["init","a","100","b","200"]}' --isInit
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["invoke","a","b","10"]}'
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["query","a"]}'

# 2020-09-14 18:15:00.034 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
# 2020-09-14 18:16:29.704 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
# 2020-09-14 18:17:42.101 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 payload:"90"