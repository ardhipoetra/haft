from __future__ import print_function
import sys
from collections import namedtuple

# ---------------------------- CONSTANTS ------------------------------------- #
RESULTS   = "result-tx.txt"
MODE = {'NATIVE':1, 'SCONE-SIM':2, 'SCONE-HW':3}

# --------------------- COLLECT ALL RESULTS FROM ALL LOGS -------------------- #

log_file = ""

def collectLogs():
    # aggregated log
    aggrlog = ""

    # dict { Entry -> number }
    Entry = namedtuple("Entry", ["benchmark", "version", "hardening", "outcome"])
    resdict = {}

    logfilebody = False
    mode=-1

    program = ""
    type = ""
    index = ""
    time_real = -1
    time_user = -1
    inspercycle = -1
    insnum = -1
    nextfail = False

    for line in open(log_file):
        if line.startswith("==================="):
            mode_str = line.split(" ")[2]
            mode = MODE[mode_str]
            continue
        # if mode < 0: continue

        if line.startswith("taskset: Killed"):
            nextfail = True

        if line.startswith('--- Running '):
            logfilebody = True

            split_line = line.split(" ")
            program = split_line[2]
            type = split_line[4]
            index = split_line[3]
            continue

        if logfilebody == False:  continue

        if "insn" in line:
            inspercycle = line.split()[3]
            insnum = line.split()[0]

        if "tx-start" in line:
            tx_start = line.split()[0]
        elif "tx-abort" in line:
            tx_abort = line.split()[0]
        elif "page-faults" in line:
            page_faults = line.split()[0]
        elif "context-switches" in line:
            context_switches = line.split()[0]
        elif "L1-dcache-load" in line:
            l1_miss = line.split()[0]
            aggrlog += '{} {} {} {} {} {} {} {} {}\n'.format(insnum, program, index, type, tx_start, tx_abort,
                                                        page_faults, context_switches, l1_miss)

        

        # if "seconds" in line:
        #     if "elapsed" in line:
        #         time_real = line.split(" ")[-4]
        #     elif "user" in line:
        #         time_user = line.split(" ")[-3]
        #     else:
        #         if not nextfail:
        #             aggrlog += '-{} {} {} {} {} {} {} {}'.format(mode, program, index, type, time_real, time_user,
        #                                                         line.split((" "))[-3], inspercycle)
        #             aggrlog += '\n'
        #         else:
        #             aggrlog += '{} {} {} {} {} {} {} {}\n'.format(mode, program, index, type, -98, -99, -100, -101)

        #         nextfail = False

    with open(RESULTS, "w") as f:
        f.write("insnum program idx type tx_start tx_abort page_faults context_switches l1_miss\n")
        f.write(aggrlog)
        f.close()

def main():
    global log_file
    if len(sys.argv) < 2:
        print("Please provide the args")
        sys.exit(-1)

    log_file = sys.argv[1]
    collectLogs()

if __name__ == "__main__":
    main()
