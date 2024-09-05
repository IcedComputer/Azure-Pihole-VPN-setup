## Last Updated 2024-09-05
## Run this at least every few months

## VARS
TEMP=/scripts/temp

## add to update Script to run every 6 months
curl --tlsv1.3 -o $TEMP/root.hints https://www.internic.net/domain/named.root
mv $TEMP/root.hints /var/lib/unbound/