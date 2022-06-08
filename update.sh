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
ethSource4="https://t2crtokens.eth.link/"

curl -f -s $ethSource1 | jq '.tokens' > eth1.json
curl -f -s $ethSource2 | jq '.tokens' > eth2.json
curl -f -s $ethSource3 | jq '.tokens' > eth3.json
curl -f -s $ethSource4 | jq '.tokens' > eth4.json
# concat into one file
jq -s '.|flatten' lab10_eth_overlay.json eth1.json eth2.json eth3.json eth4.json > eth0.json
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

########### OKEX ############

okexSource1="https://resources.jswap.finance/token-list/oec/extended.tokenlist.json"
okexSource2="https://static.kswap.finance/tokenlist/kswap-hosted-list.json"

curl -f -s $okexSource1 | jq '.tokens' > okex1.json
curl -f -s $okexSource2 | jq '.tokens' > okex2.json
# concat into one file
jq -s '.|flatten' lab10_okex_overlay.json okex1.json okex2.json > okex0.json
deduplicate okex0.json okex.json
rm -f okex?.json
echo "built okex list with $(jq '.|length' okex.json) elements"

########### ARBITRUM ############

arbitrumSource1="https://raw.githubusercontent.com/sushiswap/list/master/lists/token-lists/default-token-list/tokens/arbitrum.json"
arbitrumSource2="https://bridge.arbitrum.io/token-list-42161.json"

curl -f -s $arbitrumSource1 | jq '.' > arbitrum1.json
curl -f -s $arbitrumSource2 | jq '.tokens' > arbitrum2.json
# concat into one file
jq -s '.|flatten' lab10_arbitrum_overlay.json arbitrum1.json arbitrum2.json > arbitrum0.json
deduplicate arbitrum0.json arbitrum.json
rm -f arbitrum?.json
echo "built arbitrum list with $(jq '.|length' arbitrum.json) elements"

########### OPTIMISM ############

optimismSource1="https://raw.githubusercontent.com/sushiswap/list/master/lists/token-lists/default-token-list/tokens/optimism.json"
optimismSource2="https://static.optimism.io/optimism.tokenlist.json"


curl -f -s $optimismSource1 | jq '.' > optimism1.json
curl -f -s $optimismSource2 | jq '.tokens' > optimism2.json
# concat into one file
jq -s '.|flatten' lab10_optimism_overlay.json optimism1.json optimism2.json > optimism0.json
deduplicate optimism0.json optimism.json
rm -f optimism?.json
echo "built optimism list with $(jq '.|length' optimism.json) elements"

########### ARTIS ############

# the sigma1 list is static for now
echo "validated sigma1 list with $(jq '.|length' sigma1.json) elements"

########### merge all ###########

# compile a multi-network list
jq -s '.|flatten' eth.json xdai.json sigma1.json matic.json bsc.json okex.json > all.json

echo "built all list with $(jq '.|length' all.json) elements"
