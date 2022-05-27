#!/bin/bash

OTNODE_DIR="/root/ot-node/current"
DATABASE="blazegraph"

clear

cd /root

echo "Creating default noderc config${N1}"

read -p "Enter the operational wallet address: " NODE_WALLET
echo "Node wallet: $NODE_WALLET"

read -p "Enter the private key: " NODE_PRIVATE_KEY
echo "Node private key: $NODE_PRIVATE_KEY"


CONFIG_DIR=$OTNODE_DIR/../

cp $OTNODE_DIR/.origintrail_noderc_example $CONFIG_DIR/.origintrail_noderc

jq --arg newval "$NODE_WALLET" '.blockchain[].publicKey |= $newval' $CONFIG_DIR/.origintrail_noderc >> $CONFIG_DIR/origintrail_noderc_temp
mv $CONFIG_DIR/origintrail_noderc_temp $CONFIG_DIR/.origintrail_noderc

jq --arg newval "$NODE_PRIVATE_KEY" '.blockchain[].privateKey |= $newval' $CONFIG_DIR/.origintrail_noderc >> $CONFIG_DIR/origintrail_noderc_temp
mv $CONFIG_DIR/origintrail_noderc_temp $CONFIG_DIR/.origintrail_noderc

if [[ $DATABASE = "blazegraph" ]]; then
    jq '.graphDatabase |= {"implementation": "Blazegraph", "url": "http://localhost:9999/blazegraph"} + .' $CONFIG_DIR/.origintrail_noderc >> $CONFIG_DIR/origintrail_noderc_temp
    mv $CONFIG_DIR/origintrail_noderc_temp $CONFIG_DIR/.origintrail_noderc
fi

if [[ $DATABASE = "fuseki" ]]; then
    jq '.graphDatabase |= {"name": "node0", "implementation": "Fuseki", "url": "http://localhost:3030"} + .' $CONFIG_DIR/.origintrail_noderc >> $CONFIG_DIR/origintrail_noderc_temp
    mv $CONFIG_DIR/origintrail_noderc_temp $CONFIG_DIR/.origintrail_noderc
fi

service otnode restart
