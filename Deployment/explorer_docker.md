## Start Hyperledger Fabric network

In this guide, we assume that you've already started test network by following [Hyperledger Fabric official tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html).

## Configure

* Copy the following files from repository

  - [docker-compose.yaml](https://github.com/hyperledger/blockchain-explorer/blob/main/docker-compose.yaml)
  - [examples/net1/connection-profile/test-network.json](https://github.com/hyperledger/blockchain-explorer/blob/main/examples/net1/connection-profile/test-network.json)
  - [examples/net1/config.json](https://github.com/hyperledger/blockchain-explorer/blob/main/examples/net1/config.json)


  ```
  $ wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/main/examples/net1/config.json
  $ wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/main/examples/net1/connection-profile/test-network.json -P connection-profile
  $ wget https://raw.githubusercontent.com/hyperledger/blockchain-explorer/main/docker-compose.yaml
  ```

* Copy entire crypto artifact directory (e.g. crypto-config/, organizations/) from your fabric network

* Now you should have the following files and directory structure.

    ```
    docker-compose.yaml
    config.json
    connection-profile/test-network.json
    organizations/ordererOrganizations/
    organizations/peerOrganizations/
    ```

* Edit network name and path to volumes to be mounted on Explorer container (docker-compose.yaml) to align with your environment

    ```yaml
        networks:
        mynetwork.com:
            external:
                name: net_test

        ...

        services:
          explorer.mynetwork.com:

            ...

            volumes:
              - ./config.json:/opt/explorer/app/platform/fabric/config.json
              - ./connection-profile:/opt/explorer/app/platform/fabric/connection-profile
              - ./organizations:/tmp/crypto
              - walletstore:/opt/explorer/wallet
    ```

* When you connect Explorer to your fabric network through bridge network, you need to set DISCOVERY_AS_LOCALHOST to false for disabling hostname mapping into localhost.

    ```yaml
    services:

      ...

      explorer.mynetwork.com:

        ...

        environment:
          - DISCOVERY_AS_LOCALHOST=false
    ```

* Edit path to admin certificate and secret (private) key in the connection profile (test-network.json). You need to specify with the absolute path on Explorer container.

    ```json
      "organizations": {
        "Org1MSP": {
          "adminPrivateKey": {
            "path": "/tmp/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/priv_sk"
          ...
          ...
          "signedCert": {
            "path": "/tmp/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem"
          }
    ```

## Start container services

* Run the following to start up explore and explorer-db services after starting your fabric network:

    ```shell
    $ docker-compose up -d
    ```

## Clean up

* To stop services without removing persistent data, run the following:

    ```shell
    $ docker-compose down
    ```

* In the docker-compose.yaml, two named volumes are allocated for persistent data (for Postgres data and user wallet), if you would like to clear these named volumes up, run the following:

    ```shell
    $ docker-compose down -v
    ```
