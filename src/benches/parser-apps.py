#!/usr/bin/env python

import sys
import os

apps    = ['redis','memcached','lhttpd']
envtype = ['nonscone','scone']
runtype = ['native','tx','ilr','haft']

maks_num = 30

if len(sys.argv) < 2:
    print("please add apps")
    exit

if sys.argv[1] not in apps:
    print("wrong apps")
    exit

app_target = sys.argv[1]
fres = open('thefile.log', 'w')
fres.write('num env run op-s latency kb-s\n')


def collect(filename, num, env, run):

    ops = 0.0
    lat = 0.0
    kbs = 0.0

    with open(os.path.join(app_target, filename), 'r') as f:
        lines = f.readlines()
        for l in lines:
            if "Totals" not in l:
                continue
            ops = float(l.split()[1])
            lat = float(l.split()[4])
            kbs = float(l.split()[5])
        
        fres.write("%d %s %s %f %f %f\n" %(num, env, run, ops, lat, kbs))

for env in envtype:
    for run in runtype:
        for i in range(1, maks_num+1):
            fname = app_target+"-"+env+"-"+run+"-"+str(i)+"-"
            thefile = None

            for f in os.listdir(app_target+"/"):
                if f.startswith(fname):
                    thefile = f
                    break

            if thefile is not None:
                collect(thefile,i, env, run)
            else:
                print("cannot find: "+fname)
            
fres.close()
