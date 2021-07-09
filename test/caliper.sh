# Clone a fixed version of the Hyperledger Fabric samples repo
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
git checkout 22393b629bcac7f7807cc6998aa44e06ecc77426
# Install the Fabric tools and add them to PATH
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.0 1.4.8 -s
export PATH=$PATH:$(pwd)/bin
# Create and initialize the network
cd test-network
./network.sh up createChannel
./network.sh deployCC -ccn basic -ccl javascript

# Create Caliper Workspace
npm install --only=prod @hyperledger/caliper-cli@0.4.2
npx caliper bind --caliper-bind-sut fabric:2.2
