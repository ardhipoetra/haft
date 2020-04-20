#!/bin/bash
# Name: restart-amt.sh
# Purpose : restart Intel AMT machine
# ----------------------------------------------------------------------
xIP=<theip>
xPASSWORD=<thepass>
wsman invoke -a RequestPowerStateChange -J cycle.xml http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_PowerManagementService --port 16992 -h ${xIP} --username admin -p ${xPASSWORD} -V -v
