#!/bin/bash

# Calculate hikvision mtd checksum 
# Mark Boyce mark@darkorigins.com

# ... yes this probably could be done in a single line of
# awk, perl or python but wanted to keep it in bash 
# and make it obvious what it's doing

# Related useful stuff 
# https://ipcamtalk.com/threads/r0-ds-2cd2x32-brickfixv2-brick-recovery-and-full-upgrade-tool-enhanced.24343/

# Usage 
# Pass filename or pipe to stdin
# 
# % ./mtd_checksum.sh mtd6ro_orig
# HikVision Checksum : 01 07
# 
# % ./mtd_checksum.sh < mtd6ro_orig
# HikVision Checksum : 01 07

# From either filename or std in
#
# Read 0xF4 bytes from 0x09-0xFC and calculate a checksum-16
# (ignoring carry digits over 0xFFFF as there's not enough data to get there)

# Print out 
# Checksum result in little endian (low byte, high byte)


# Filename or stdin?
if [ "$1" ] ; then exec < "$1" ; fi


# Read a single byte from the input stream and return it formatted as a number
read_a_byte() {
	local _return_var=${1:-_read_a_byte_return} _byte_read LANG=C IFS=
        read -r -d '' -n 1 _byte_read
	printf -v $_return_var %d \'$_byte_read
}

# Skipping first 9 bytes
for((_position=0;_position<$((0x09));_position++)) do read_a_byte; done

# Our checksum total
_running_total=0

# Cycle over 0x09 to 0xFC (0xF4 bytes)
for((_position=$((0x09));_position<=$((0xfc));_position++))
    do
	    read_a_byte _new_value
	    (( _running_total = _running_total + _new_value ))
    done

# printf "Checksum  : %04x\n" ${_running_total}
printf "HikVision Checksum : %02X %02X\n" $(( _running_total & 255 )) $(( _running_total >> 8 ))


