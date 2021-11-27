

rm -rf fabric
git clone https://github.com/hyperledger/fabric.git

#go to the fabric folder
cd fabric

# build the binaries for orderer, peer, and configtxgen
make orderer peer configtxgen

#配置环境变量
#Set the PATH environment variable to include orderer and peer binaries:
export PATH=$(pwd)/build/bin:$PATH
#Set the FABRIC_CFG_PATH environment variable to point to the sampleconfig folder:
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
#Generate the genesis block for the ordering service.  Run the following command to generate the genesis block and store it in $(pwd)/sampleconfig/genesisblock so that it can be used by the orderer in the next step when the orderer is started.
configtxgen -profile SampleDevModeSolo -channelID syschannel -outputBlock genesisblock -configPath $FABRIC_CFG_PATH -outputBlock "$(pwd)/sampleconfig/genesisblock"
#如果报错cli, 查看现有的容器
#docker ps -a
#关掉所有镜像
#docker stop container id
'''
1. Start the orderer
'''
#start the orderer with the SampleDevModeSolo profile and start the ordering service:
ORDERER_GENERAL_GENESISPROFILE=SampleDevModeSolo orderer
#可能会遇到bug：failed to listen
#sudo lsof -i :7050
#kill -9 pid
'''
2. start the peer node
'''
#打开新的terminal
cd fabric
#配置环境变量
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
FABRIC_LOGGING_SPEC=chaincode=debug CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 peer node start --peer-chaincodedev=true
#falling back to auto-detected address: 149.28.156.145:7051
#可能会遇到端口被占用问题：Error: failed to initialize operations subsystem: listen tcp 127.0.0.1:9443: bind: address already in use
cd sampleconfig
vi core.yaml 
#修改729行：9443为10443
#不小心改了其他配置导致文档出错的话：
#git checkout sampleconfig/core.yaml
#vi sampleconfig/core.yaml
#回到fabric文件夹下
cd ..
#FABRIC_LOGGING_SPEC=chaincode=debug CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 peer node start --peer-chaincodedev=true

'''
3. Create channel and join peer
'''
#打开新的terminal
cd fabric
#配置环境变量

export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
configtxgen -channelID ch1 -outputCreateChannelTx ch1.tx -profile SampleSingleMSPChannel -configPath $FABRIC_CFG_PATH
peer channel create -o 127.0.0.1:7050 -c ch1 -f ch1.tx
#join the peer to the channel
peer channel join -b ch1.block

'''
4.build the chaincode
'''

#初次把链码从github拉下来
cd ..#到github.com文件夹下
#把github中文件拉下来
git clone https://github.com/Flyincry/cbit-fabricflow.git
#找到rigelynn分支
git checkout rigelynn
#看到如下结果
#Branch 'rigelynn' set up to track remote branch 'rigelynn' from 'origin'.
#Switched to a new branch 'rigelynn'
cd cbit-fabricflow/SC_CODE/IFC/
#如果需要修改文件内容
cd inventoryfinancingpaper
vim InventoryFinancing.go
vim InventoryFinancingPaper.go
#在当前文件夹下
go build -o simpleChaincode ./
#查看是否已经存在simpleChaincode文件
ls
#把simpleChaincode文件复制到fabric下
cp simpleChaincode ../../../../fabric
#去fabric文件夹下
cd ../../../../fabric
#start the chaincode
CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 ./simpleChaincode -peer.address 127.0.0.1:7052


'''
5. approve and commit the chaincode definition
'''
# 打开新的terminal
cd fabric
#配置环境
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
#approve and commit the chaincode definition to the channel
peer lifecycle chaincode approveformyorg  -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 5 --init-required --signature-policy "OR ('SampleOrg.member')" --package-id mycc:1.0
peer lifecycle chaincode checkcommitreadiness -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 5 --init-required --signature-policy "OR ('SampleOrg.member')"
peer lifecycle chaincode commit -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 5 --init-required --signature-policy "OR ('SampleOrg.member')" --peerAddresses 127.0.0.1:7051


#验证代码

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["InitLedger"]}' --isInit

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Apply","112","linlin","120000","202111"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["OfferProductInfo","112","linlin","TIKA","Crystal","20000","202109","202111"]}'
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["OfferLisenceInfo","112","linlin","Lao FengXiang","kaka","202102","202209","202111"]}'
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Receive","112","linlin","HengSeng","202111"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Evaluate","112","linlin","haha","Crystal","99%","120000","202111"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["ReadyRepo","112","linlin","nini","202111"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["PutInStorage","linlin","112","loca","120000","Crystal","Street 111 Road 12","202311","202111"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Accept","112","linlin","202111"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Supervise","linlin","112","loca"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Payback","linlin","112","20221112"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["Default","112","linlin","2022"]}'

CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["QueryPaper","linlin","112"]}'
