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

curl -f -s $ethSource1 | jq '.tokens' > eth1.json || true
curl -f -s $ethSource2 | jq '.tokens' > eth2.json || true
curl -f -s $ethSource3 | jq '.tokens' > eth3.json || true
curl -f -s $ethSource4 | jq '.tokens' > eth4.json || true
# concat into one file
jq -s '.|flatten' lab10_eth_overlay.json eth1.json eth2.json eth3.json eth4.json > eth0.json
deduplicate eth0.json eth.json
# cleanup
rm -f eth?.json

echo "built eth list with $(jq '.|length' eth.json) elements"

########### XDAI ###########

xdaiSource1="https://raw.githubusercontent.com/1Hive/default-token-list/master/src/tokens/gnosis.json"

# here jq just validates the content
curl -f -s $xdaiSource1 | jq '.' > xdai1.json || true
# concat into one file
jq -s '.|flatten' lab10_xdai_overlay.json xdai1.json > xdai0.json
deduplicate xdai0.json xdai.json
# cleanup
rm -f xdai?.json

echo "built xdai list with $(jq '.|length' xdai.json) elements"

########### MATIC ############

maticSource1="https://unpkg.com/quickswap-default-token-list/build/quickswap-default.tokenlist.json"

curl -f -s -L $maticSource1 | jq '.tokens' > matic1.json || true
jq -s '.|flatten' lab10_matic_overlay.json matic1.json > matic0.json
deduplicate matic0.json matic.json
rm -f matic?.json
echo "built matic list with $(jq '.|length' matic.json) elements"

########### BSC ############

bscSource1="https://tokens.pancakeswap.finance/pancakeswap-extended.json"

curl -f -s -L $bscSource1 | jq '.tokens' > bsc1.json || true
jq -s '.|flatten' lab10_bsc_overlay.json bsc1.json > bsc0.json
deduplicate bsc0.json bsc.json
rm -f bsc?.json
echo "built bsc list with $(jq '.|length' bsc.json) elements"

########### ARBITRUM ############

arbitrumSource1="https://raw.githubusercontent.com/sushiswap/list/master/lists/token-lists/default-token-list/tokens/arbitrum.json"
arbitrumSource2="https://bridge.arbitrum.io/token-list-42161.json"

curl -f -s $arbitrumSource1 | jq '.' > arbitrum1.json || true
curl -f -s $arbitrumSource2 | jq '.tokens' > arbitrum2.json || true
# concat into one file
jq -s '.|flatten' lab10_arbitrum_overlay.json arbitrum1.json arbitrum2.json > arbitrum0.json
deduplicate arbitrum0.json arbitrum.json
rm -f arbitrum?.json
echo "built arbitrum list with $(jq '.|length' arbitrum.json) elements"

########### OPTIMISM ############

optimismSource1="https://raw.githubusercontent.com/sushiswap/list/master/lists/token-lists/default-token-list/tokens/optimism.json"
optimismSource2="https://static.optimism.io/optimism.tokenlist.json"


curl -f -s $optimismSource1 | jq '.' > optimism1.json || true
curl -f -s $optimismSource2 | jq '.tokens' > optimism2.json || true
# concat into one file
jq -s '.|flatten' lab10_optimism_overlay.json optimism1.json optimism2.json > optimism0.json
deduplicate optimism0.json optimism.json
rm -f optimism?.json
echo "built optimism list with $(jq '.|length' optimism.json) elements"

########### CELO ############

celoSource1="https://raw.githubusercontent.com/sushiswap/list/master/lists/token-lists/default-token-list/tokens/celo.json"
celoSource2="https://raw.githubusercontent.com/Ubeswap/default-token-list/master/ubeswap.token-list.json"

curl -f -s $celoSource1 | jq '.' > celo1.json || true
curl -f -s $celoSource2 | jq '.tokens' > celo2.json || true
# concat into one file
jq -s '.|flatten' lab10_celo_overlay.json celo1.json celo2.json > celo0.json
deduplicate celo0.json celo.json
rm -f celo?.json
echo "built celo list with $(jq '.|length' celo.json) elements"

########### AVALANCHE ############

avalancheSource1="https://raw.githubusercontent.com/sushiswap/list/master/lists/token-lists/default-token-list/tokens/avalanche.json"
avalancheSource2="https://raw.githubusercontent.com/traderjoe-xyz/joe-tokenlists/main/joe.tokenlist.json"
avalancheSource3="https://raw.githubusercontent.com/pangolindex/tokenlists/main/pangolin.tokenlist.json"

curl -f -s $avalancheSource1 | jq '.' > avalanche1.json || true
curl -f -s $avalancheSource2 | jq '.tokens' > avalanche2.json || true
curl -f -s $avalancheSource3 | jq '.tokens' > avalanche3.json || true
# concat into one file
jq -s '.|flatten' lab10_avalanche_overlay.json avalanche1.json avalanche2.json avalanche3.json > avalanche0.json
deduplicate avalanche0.json avalanche.json
rm -f avalanche?.json
echo "built avalanche list with $(jq '.|length' avalanche.json) elements"

########### zkSync ############

zkSyncSource1="https://raw.githubusercontent.com/muteio/token-directory/main/zksync.json"
zkSyncSource2="https://raw.githubusercontent.com/SpaceFinance/default-token-list/main/spaceswap.zksync.tokenlist.json"

curl -f -s $zkSyncSource1 | jq '.' > zksync1.json || true
curl -f -s $zkSyncSource2 | jq '.tokens' > zksync2.json || true
# concat into one file
jq -s '.|flatten' lab10_zksync_overlay.json zksync1.json zksync2.json > zksync0.json
deduplicate zksync0.json zksync.json
rm -f zksync?.json
echo "built zksync list with $(jq '.|length' zksync.json) elements"

########### ARTIS ############

# the sigma1 list is static for now
echo "validated sigma1 list with $(jq '.|length' sigma1.json) elements"

########### TESTNETS ############

# the testnets list is static for now
echo "validated kovan list with $(jq '.|length' testnets.json) elements"

########### NON-SPECIFIC NETWORK ############

nonSpecificSource1="https://raw.githubusercontent.com/superfluid-finance/tokenlist/main/superfluid.tokenlist.json"

# here jq just validates the content
curl -f -s $nonSpecificSource1 | jq '.tokens' > nonspecific1.json || true
# concat into one file
jq -s '.|flatten' lab10_nonspecific_overlay.json nonspecific1.json > nonspecific0.json
deduplicate nonspecific0.json nonspecific.json
# cleanup
rm -f nonspecific?.json

echo "built non-specific network list with $(jq '.|length' nonspecific.json) elements"

########### merge all ###########

# compile a multi-network list
jq -s '.|flatten' eth.json xdai.json sigma1.json matic.json bsc.json okex.json arbitrum.json optimism.json celo.json avalanche.json zksync.json testnets.json nonspecific.json > all.json

echo "built all list with $(jq '.|length' all.json) elements"
