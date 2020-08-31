#! /bin/sh

printf '%6s\n' "$(ifstat | grep -P '^enp4s0' | awk '{print $6}')"
