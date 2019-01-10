#!/usr/bin/env python3

"""Run a scenario described in a provided JSON file"""

import scenarios_mla

import os
import json

def run_policyrun(json_fname):
    """Read the provided JSON file, run policyrun()"""
    with open(json_fname) as fd:
        args=json.load(fd)

    if '_comment' in args:
        comment=args['_comment']
        del args['_comment']
    else:
        comment=''

    scenarios_mla.policyrun(**args)

if __name__=='__main__':
    import sys
    if len(sys.argv)!=2:
        print("Usage: {progname} input.json".format(progname=sys.argv[0]),file=sys.stderr)
        sys.exit(1)
    try:
        run_policyrun(sys.argv[1])
    except:
        print("There was a problem running the program", file=sys.stderr)
        raise

        
