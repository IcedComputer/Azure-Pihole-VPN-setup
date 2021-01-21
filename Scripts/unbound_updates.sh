## Last Updated 18 Aug 2020
## Run this at least every few months

## VARS
TEMP=/scripts/temp

## add to update Script to run every 6 months
curl --tlsv1.2 -o $TEMP/root.hints https://www.internic.net/domain/named.root
mv $TEMP/root.hints /var/lib/unbound/