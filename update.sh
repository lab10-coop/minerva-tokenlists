#!/bin/bash

# fetches a given set of token lists and compiles new list files per network as expected by Minerva
# requires jq (apt install jq)

set -euo pipefail

ethSource1="http://tokens.1inch.eth.link/"
ethSource2="https://tokens.coingecko.com/uniswap/all.json"

curl -f -s $ethSource1 | jq '.tokens' > eth1.json
curl -f -s $ethSource2 | jq '.tokens' > eth2.json
# concat into one file
jq -s '.|flatten' eth1.json eth2.json > eth.json
# cleanup
rm -f eth?.json

echo "built eth list with $(jq '.|length' eth.json) elements"


xdaiSource1="https://raw.githubusercontent.com/1Hive/default-token-list/master/src/tokens/xdai.json "

# here jq just validates the content
curl -f -s $xdaiSource1 | jq '.' > xdai.json

echo "built xdai list with $(jq '.|length' xdai.json) elements"


# do nothing for sigma1 for now
echo "validated sigma1 list with $(jq '.|length' sigma1.json) elements"


jq -s '.|flatten' eth.json xdai.json sigma1.json > all.json

echo "built all list with $(jq '.|length' all.json) elements"
