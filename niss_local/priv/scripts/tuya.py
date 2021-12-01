#!/usr/bin/env python3

import argparse
import tinytuya


def parse_bool(val):
    val = str(val).upper()
    if val == "TRUE":
        return True
    elif val == "FALSE":
        return False
    else:
        raise ValueError("Received invalid bool: {}".format(val))


parser = argparse.ArgumentParser(description="Control tuya outlet")
parser.add_argument("--id")
parser.add_argument("--ip")
parser.add_argument("--key")
parser.add_argument("--status", type=parse_bool)

args = parser.parse_args()

plug = tinytuya.OutletDevice(args.id, args.ip, args.key)
plug.set_version(3.3)

plug.set_status(args.status)
