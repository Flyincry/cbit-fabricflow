# 7.20 explorer：docker方法

# 准备工作
cd /home/tianze
mkdir testbe
wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/main/examples/net1/config.json
wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/main/examples/net1/connection-profile/test-network.json -P connection-profile
wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/main/docker-compose.yaml

# 证书文件夹复制过来
cp crypto-config ./testbe 
mv crypto-config organizations #改名

# 在connection-profile下增加org1-network.json 和 org2-network.json

# organization文件夹中
