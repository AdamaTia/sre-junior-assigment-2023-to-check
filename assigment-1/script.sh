#!/bin/bash
# This script can: 
# - by default: count requests by IP address, 
# - by choosing --user-agent option: count requests by IP address but specificly to defined user agent,
# - by choosing --method option: count requests but by method  

usage() {
  # Display the usage and exit.
  echo "Usage of ${0}"
  echo 'Count requests by valid choice:'
  echo '  --default  Default option: it will count by IP adressess.'
  echo '  --user-agent  It will count requests by IP adresses but restricts to specific user-agent.'
  echo '  --method  It will count requests but by used method.' 
  exit 0
}

if [[ $1 -eq 0 ]]
then
  echo "You didn't make a choice!"
  usage
  exit 1
fi
# We use "${@}" instead of "${*}" to preserve argument-boundary information
ARGS=$(getopt --options 'd,u:m' --longoptions 'default,user-agent:,method' -- "${@}") || exit
eval "set -- ${ARGS}"

while true; do
    case "${1}" in
        (-m | --method)
            # STEP 1: Tar this file
              tar -xf logs.tar.bz2
            # STEP 2: Go to file and get what you want
              cd logs
              echo "REQUESTS  METHOD  IP" && cat logs.log | awk '{gsub("\"","",$0); print $6, $14}' | sort -n | uniq -c | sort -nr
            # STEP 3: Delete logs
              cd ..
              rm -r logs
            shift
        ;;
        (-d | --default)
            # STEP 1: Tar this file
              tar -xf logs.tar.bz2
            # STEP 2: Go to file and get what you want
              cd logs
              echo "  REQUESTS  ADDRESS" && cat logs.log | awk '{gsub("\"","",$0); print $14}' | sort -n | uniq -c | sort -nr
            # STEP 3: Delete logs
              cd ..
              rm -r logs
            shift 2
        ;;
        (-u | --user-agent)
              echo "You chose "${2}" user agent."
            # STEP 1: Tar this file
              tar -xf logs.tar.bz2
            # STEP 2: Go to file and get what you want
              cd logs
              echo "  REQUESTS  ADDRESS" && cat logs.log | grep ${2} | awk '{gsub("\"","",$14); print $14}' | sort -n | uniq -c | sort -nr
            # STEP 3: Delete logs
              cd ..
              rm -r logs
          #  done
            shift 2
        ;;
        (--)
            shift
            break
        ;;
        (?)
            usage
            exit 1    # error
        ;;
        (*)
            exit 0    # success
        ;;
    esac
done

remaining_args=("${@}")
