# hadoop-docker
Hadoop/YARN on Docker

## Usage
`git clone https://github.com/xpspectre/hadoop-docker`, configure, and `run-hadoop.sh <args>`

Default mode is "single-node" with no arguments.

"master name" argument should be the FQDN of the master.

## Caveats
Right now, SSH is set up but not actually used. Need to be careful with ports.

All hosts (servers, VMs, etc.) need to have valid hostnames (DNS forward and reverse lookup need to work), as usual for Hadoop.

## References
Draws heavily from:

https://github.com/sticksnleaves/docker-hadoop-single-node

http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/
