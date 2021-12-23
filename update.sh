#!/bin/bash

# fetches a given set of token lists and compiles new list files per network as expected by Minerva
# requires jq (apt install jq)

set -euo pipefail
set -x

# takes a json file with a token list as input. Deduplicated by chainId,lowercase(address)
function deduplicate {
	infile=$1
	outfile=$2
	jq '.[].address |= ascii_downcase | unique_by(.chainId,.address)' $infile > $outfile
}

############ ETHEREUM ###########

ethSource1="http://tokens.1inch.eth.link/"
ethSource2="https://api.coinmarketcap.com/data-api/v3/uniswap/all.json"
ethSource3="https://tokens.coingecko.com/uniswap/all.json"

curl -f -s $ethSource1 | jq '.tokens' > eth1.json
curl -f -s $ethSource2 | jq '.tokens' > eth2.json
curl -f -s $ethSource3 | jq '.tokens' > eth3.json
# concat into one file
jq -s '.|flatten' lab10_eth_overlay.json eth1.json eth2.json eth3.json > eth0.json
deduplicate eth0.json eth.json
# cleanup
rm -f eth?.json

echo "built eth list with $(jq '.|length' eth.json) elements"

########### XDAI ###########

xdaiSource1="https://raw.githubusercontent.com/1Hive/default-token-list/master/src/tokens/xdai.json"

# here jq just validates the content
curl -f -s $xdaiSource1 | jq '.' > xdai1.json
# concat into one file
jq -s '.|flatten' lab10_xdai_overlay.json xdai1.json > xdai0.json
deduplicate xdai0.json xdai.json
# cleanup
rm -f xdai?.json

echo "built xdai list with $(jq '.|length' xdai.json) elements"

########### MATIC ############

maticSource1="https://unpkg.com/quickswap-default-token-list/build/quickswap-default.tokenlist.json"

curl -f -s -L $maticSource1 | jq '.tokens' > matic1.json
jq -s '.|flatten' lab10_matic_overlay.json matic1.json > matic0.json
deduplicate matic0.json matic.json
rm -f matic?.json
echo "built matic list with $(jq '.|length' matic.json) elements"

########### BSC ############

bscSource1="https://tokens.pancakeswap.finance/pancakeswap-extended.json"

curl -f -s -L $bscSource1 | jq '.tokens' > bsc1.json
jq -s '.|flatten' lab10_bsc_overlay.json bsc1.json > bsc0.json
deduplicate bsc0.json bsc.json
rm -f bsc?.json
echo "built bsc list with $(jq '.|length' bsc.json) elements"

########### ARTIS ############

# the sigma1 list is static for now
echo "validated sigma1 list with $(jq '.|length' sigma1.json) elements"

########### merge all ###########

# compile a multi-network list
jq -s '.|flatten' eth.json xdai.json sigma1.json matic.json bsc.json > all.json

echo "built all list with $(jq '.|length' all.json) elements"
