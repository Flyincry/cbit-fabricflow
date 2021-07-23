# 7.16 ### 安装与测试网络 fabric 2.3.2

# 安装 curl
apt-get install curl
# curl sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

# 安装 nodejs ，包含了npm ，并且Add the path in npm configure file
sudo apt-get install -y nodejs
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
vim .profile
	export PATH=~/.npm-global/bin:$PATH
source ~/.profile

# 更新apt
apt update
apt upgrade

# 下载python
cd /home/tianze
apt-get install python -y
	#set default python version， python3 为默认
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2
	# 以下这个方法因为缺少distutils.util而导致报错
	# download get-pip.py file
	# wget https://bootstrap.pypa.io/get-pip.py
	# run get-pip.py
	# python get-pip.py

	# python2 和python3 都有各自对应的pip，各自不互相兼容，因为系统默认python3，所以要安装python3对应的pip
	# apt install python-pip
apt install python3-pip
pip uninstall requests -y

# 安装docker
apt install docker.io

# 安装 docker-compose
# pip install docker-compose
# sudo pip install docker-compose
python -m pip install -U pip
sudo pip install docker-compose

# 安装go
cd $HOME/ && wget https://storage.googleapis.com/golang/go1.16.6.linux-amd64.tar.gz  # 版本注意！！！
tar -xvf go1.16.6.linux-amd64.tar.gz
mkdir $HOME/gopath
export GOPATH=$HOME/gopath
export GOROOT=$HOME/go
export PATH=$PATH:$GOROOT/bin
go version

# 安装 libltdl-dev
apt-get install libltdl-dev

# 安装git
apt-get install git

# 脚本下载fabric源码，测试项目，二进制文件在bin里
cd ~
curl -sSL http://bit.ly/2ysbOFE | bash -s  # 2.3.2

# 把bin里的文件复制到usr/local/bin中
cd ~/fabric-samples/bin
cp * /usr/local/bin

# 开启测试网络
cd ..
cd test-network/
./network.sh up

# 创建通道
./network.sh createChannel
	# 通道名默认名为mychannel， 可以通过后面加 -c channel1 来命名为channel1
	# ./network.sh createChannel -c channel1

# 部署链码
cd ..
cd asset-transfer-basic/chaincode-go
go mod vendor #在该目录下安装go依赖‘vendor’,否则下面的deploy命令会报错
cd ../..
cd test-network
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go
	# ccn：chaincode name， ccp：chaincode path， ccl：chaincode language

# 在与网络交互前，需要添加环境变量
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# 初始化链码
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
# 查询链码资产列表
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
# 把asset6给Christopher
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'

# Environment variables for Org2
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# 查询asset6
peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'

#关闭网络
./network.sh down
### 配置网络结束



