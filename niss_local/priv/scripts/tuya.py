#!/usr/bin/env python3

import argparse
import tinytuya


# Parse arguments


def parse_bool(val):
    val = str(val).upper()
    if val == "TRUE":
        return True
    elif val == "FALSE":
        return False
    else:
        raise ValueError("Received invalid bool: {}".format(val))


parser = argparse.ArgumentParser(description="Control tuya outlet")
subparsers = parser.add_subparsers(dest="action")

parser.add_argument("--id", required=True)
parser.add_argument("--ip", required=True)
parser.add_argument("--key", required=True)

set_status_subparser = subparsers.add_parser("set_status")
set_status_subparser.add_argument("status", type=parse_bool)

get_status_subparser = subparsers.add_parser("get_status")

args = parser.parse_args()


# Set up plug

plug = tinytuya.OutletDevice(args.id, args.ip, args.key)
plug.set_version(3.3)


# Handle action


def set_status(plug, args):
    plug.set_status(args.status)


def get_status(plug, _args):
    status = plug.status()["dps"]["1"]
    if status:
        print("1")
    else:
        print("0")


handlers = {"set_status": set_status, "get_status": get_status}
handlers[args.action](plug, args)
