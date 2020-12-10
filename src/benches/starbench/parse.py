#!/usr/bin/env python3
import re

fres = open('output.txt', 'w')
fres.write('input bench threads instructions start commit abort capacity conflict time\n')

bm_pattern = { 'c-ray-mt': '(\d+) milliseconds', 
               'kmeans': 'Computation timing\s+=\s+(\d+.\d+).*', #secs
               'md5': '^Time: (\d+.\d+)', #secs
               'rgbyuv': '^Time: (\d+.\d+)',                        #secs
               'rot-cc': '^Total: (\d+.\d+)s', #secs
               'streamcluster': '(\d+) msec',
               'tinyjpeg': '\((\d+) ms\)',
               'ray-rot': '^Total: (\d+.\d+)s', #secs
               'rotate': '^Compute: (\d+.\d+)s', #secs
}    

data = {}

def collect(filename, suffix):
    with open(filename, 'r') as f:
        prog_type   = 'DUMMY'
        benchmark   = 'DUMMY'
        num_threads = 0
        repeatnum = 0

        instructions= 0
        start       = 0
        commit      = 0
        abort       = 0
        capacity    = 0
        conflict    = 0

        time        = 0.0

        isPerf = False

        lines = f.readlines()
        for l in lines:
            if l.startswith('--- Running '):
                pp = re.compile('--- Running ([\w-]+) (\d+) (\w+) .* --- #(\d+)')
                grp = pp.search(l)

                if grp == None:
                    continue

                benchmark = grp.group(1)
                num_threads = int(grp.group(2))
                prog_type = grp.group(3)
                repeatnum = int(grp.group(4))

                # benchmark   = l.split('--- Running ')[1].split(' ')[0]
                # num_threads = int(l.split('--- Running ')[1].split(' ')[1])
                # prog_type   = l.split('--- Running ')[1].split(' ')[2]
                continue

            p = re.compile(bm_pattern[benchmark])
            res = p.search(l)
            if res == None:
                continue

            if benchmark in ["c-ray-mt","streamcluster","tinyjpeg"]:
                elapsed_time = float(res.group(1))/1000
            else:
                elapsed_time = float(res.group(1))


            print("%s,%d,%d,%s,%f" %(benchmark, repeatnum, num_threads, prog_type, elapsed_time))

            # if "Performance counter stats for" in l:
            #     isPerf = True
            #     continue

            # if isPerf and "instructions" in l:
            #     instructions = int(l.split()[0])
            #     continue

            # if isPerf and "cpu/tx-start/" in l:
            #     start = int(l.split()[0])
            #     continue

            # if isPerf and "cpu/tx-commit/" in l:
            #     commit = int(l.split()[0])
            #     continue

            # if isPerf and "cpu/tx-abort/" in l:
            #     abort = int(l.split()[0])
            #     continue

            # if isPerf and "cpu/tx-capacity/" in l:
            #     capacity = int(l.split()[0])
            #     continue

            # if isPerf and "cpu/tx-conflict/" in l:
            #     conflict = int(l.split()[0])
            #     continue

            # if isPerf and "seconds time elapsed" in l:
            #     time = float(l.split()[0])
            #     isPerf = False
                
            #     benchmark += suffix

            #     fres.write('%s %s %d %d %d %d %d %d %d %f\n' % 
            #         (prog_type, benchmark, num_threads,
            #          instructions, start, commit, abort, capacity, conflict, time))
            #     continue

fname="5.scone_hw.out.rot"
collect(fname, '')
