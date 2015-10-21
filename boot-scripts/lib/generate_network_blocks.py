#!/usr/bin/env python

# Copyright 2015: CloudCoreo Inc
# License: Apache License v2.0
# Author(s):
#   - Paul Allen (paul@cloudcoreo.com)
# Example Usage:

from optparse import OptionParser
from netaddr import IPNetwork

version = "0.0.1"

NETWORK_LIST = []

def parseArgs():
    parser = OptionParser("usage: %prog [options]")
    parser.add_option("--version",           dest="version",        default=False, action="store_true",     help="Display the version and exit")
    parser.add_option("--master-cidr-block", dest="masterCidrBlock",default="",                             help="A CIDR in which all kubernetes routes will exist")
    parser.add_option("--cidr-divider",      dest="cidrDivider",     default=26,                             help="A block size to subdivide the master list into")
    return parser.parse_args()

def main():
    masterNetwork = IPNetwork(options.masterCidrBlock)
    minMasterNetwork = list(masterNetwork)[0]
    maxMasterNetwork = list(masterNetwork)[-1]
    for ipaddr in list(masterNetwork):
        ipaddrNetString = "%s/%s" % (ipaddr, options.cidrDivider)
        ipaddrNetwork = IPNetwork(ipaddrNetString)
        if ipaddrNetwork.network not in NETWORK_LIST:
            NETWORK_LIST.append(ipaddrNetwork.network)
    for net in NETWORK_LIST:
        print net

(options, args) = parseArgs()

try:
    main()
except Exception as e:
    print("ERROR: %s" % str(e))
