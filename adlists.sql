CREATE TEMP TABLE i(txt);
.separator ~
.import /etc/pihole/adlist.list i
INSERT OR IGNORE INTO adlist (address) SELECT txt FROM i;
DROP TABLE i;