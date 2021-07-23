# 7.19 部署fabric

# go 
tar -xvf go1.15.9.linux-386.tar.gz
mkdir $HOME/gopath
export GOPATH=$HOME/gopath
export GOROOT=$HOME/go
export PATH=$PATH:$GOROOT/bin
go version


# '''搭建fabric'''
# 第一步 生成证书文件
cd /
cd home/tianze
cryptogen showtemplate
cryptogen showtemplate > crypto-config.yaml
vim crypto-config.yaml
	# 更改 11行 EnableNodeOUs: false 为 true
	# 更改组织1 28行 EnableNodeOUs: false 为 true 
	# 更改组织2 112行 EnableNodeOUs: false 为 true 
cryptogen generate --config=crypto-config.yaml # 生成配置文件

# 第二步 使用configtx.yaml 创建通道配置, 2.3 取消系统通道
# 从镜像目录复制到工作目录
cp ../../root/fabric-samples/test-network/configtx/configtx.yaml ./ 
vi configtx.yaml # fabric 2.3不需要更改profile, 2.2需要 
      # 将所有msp路径更改为项目具体路径: 
      # 28行 crypto-config/ordererOrganizations/example.com/msp
      # 55行 crypto-config/peerOrganizations/org1.example.com/msp
      # 82行 crypto-config/peerOrganizations/org2.example.com/msp
      # 改 orderer-etcdraft路径：
      # 217  crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
      # 218  crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
      # 增加AnchorPeers
      # 73   AnchorPeers:
      #          - Host: peer0.org1.example.com
      #            Port: 7051
      # 103  AnchorPeers:
      #          - Host: peer0.org2.example.com
      #            Port: 7051
# 生成创世块 
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID fabric-channel  
# 创建初始交易
configtxgen -outputCreateChannelTx ./channel-artifacts/channel.tx -profile TwoOrgsChannel -channelID mychannel
# 查看创世块
configtxgen -inspectBlock genesis.block # 在文件夹内才能打开
# 查看初始创建交易
configtxgen -inspectChannelCreateTx channel.tx # 在文件夹内才能打开
# 创建组织1锚节点
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
# 创建组织2锚节点
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

# 第三步 创建peer节点
# 为peer节点配置文件
cp ../../root/fabric-samples/test-network/docker/docker-compose-test-net.yaml ./
mv docker-compose-test-net.yaml docker-compose.yaml
vi docker-compose.yaml
 # 修改 参考docker-compose.sh 文件
#  
docker-compose up -d
docker exec -it cli1 bash

peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem 

exit

docker cp cli1:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block ./ #将容器1中的文件拷贝到本地
docker cp ./mychannel.block cli2:/opt/gopath/src/github.com/hyperledger/fabric/peer #从本地拷贝到容器2

docker exec -it cli2 bash #进入容器2
ls
peer channel join -b mychannel.block # peer2加入通道
exit
docker exec -it cli1 bash #进入容器1
peer channel join -b mychannel.block # peer1加入通道
# 更新锚节点1
peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
exit
# 更新锚节点2
docker exec -it cli2 bash
peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
exit

# 第五步 打包调用链码
cd ..
cd $HOME/fabric-samples/chaincode/sacc
cp sacc.go /home/tianze/chaincode/go/ # 复制到项目地址，地址需要改
cd /home/tianze
docker exec -it cli1 bash
cd /opt/gopath/src/github.com/hyperledger/fabric-cluster/chaincode/go
# 给go一个国内依赖包，先找国内代理员
go env -w GOPROXY=https://goproxy.cn,direct
go mod init
go mod vendor
cd /opt/gopath/src/github.com/hyperledger/fabric/peer
peer lifecycle chaincode package sacc.tar.gz --path github.com/hyperledger/fabric-cluster/chaincode/go/ --label sacc_1
exit
docker cp cli1:/opt/gopath/src/github.com/hyperledger/fabric/peer/sacc.tar.gz ./
docker cp sacc.tar.gz cli2:/opt/gopath/src/github.com/hyperledger/fabric/peer
docker exec -it cli1 bash 

#安装链码
peer lifecycle chaincode install sacc.tar.gz
exit
docker exec -it cli2 bash
peer lifecycle chaincode install sacc.tar.gz

# 批准
peer lifecycle chaincode approveformyorg --channelID mychannel --name sacc --version 1.0 --init-required --package-id sacc_1:0639ae62130fa95b5d86486c0cbdea5b08749fdd2b5685fb5f2e2f5e3baeba4a --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit
docker exec -it cli1 bash
peer lifecycle chaincode approveformyorg --channelID mychannel --name sacc --version 1.0 --init-required --package-id sacc_1:0639ae62130fa95b5d86486c0cbdea5b08749fdd2b5685fb5f2e2f5e3baeba4a --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 检查
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name sacc --version 1.0 --init-required  --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
exit
docker exec -it cli1 bash
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name sacc --version 1.0 --init-required  --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# 提交
peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name sacc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# 链码调用
peer chaincode invoke -o orderer.example.com:7050 --isInit --ordererTLSHostnameOverride orderer.example.com --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n sacc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddress peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["a","bb"]}'
exit
docker exec -it cli2 bash
peer chaincode query -C mychannel -n sacc -c '{"Args":["query","a"]}'

