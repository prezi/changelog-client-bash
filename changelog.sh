#!/bin/bash
abort() {
    echo "$*"
    exit 1
}

help() {
    cat <<EOF
Usage: $0 [OPTIONS] message
Send an event to a Changelog (https://github.com/prezi/changelog) server.

Example: $0 -s5 Manually restarting all app servers.

Idea: Create a symlink pointing to this script somewhere on your path.
      Call it "clog".

Options:
 -c  Category. Default: 'misc'
 -s  Criticality (mnemonic: severity). Default: 3
 -h  Displays this text


Environment variables:

CHANGELOG_ENDPOINT
  Default: none, required
  The URL of your Changelog installation, including '/api/events'.

CHANGELOG_CURL
  Default: curl
  The command to use for sending the request to the Changelog API.
  Must support the -X, -H and -h switches of curl.
  Use-case: set it to a curl wrapper that takes care of authentication.

CHANGELOG_DEFAULT_CATEGORY
  Default: misc
  The category sent to Changelog, unless specified with -c.

CHANGELOG_DEFAULT_CRITICALITY
  Default: 3
  The criticality sent to Changelog, unless specified with -s.
EOF
    exit
}

curl=${CHANGELOG_CURL:-curl}  # Useful if you have a curl wrapper doing your authentication
endpoint=${CHANGELOG_ENDPOINT}
category=${CHANGELOG_DEFAULT_CATEGORY:-misc}
criticality=${CHANGELOG_DEFAULT_CRITICALITY:-3}

while getopts c:s:h opt; do
    case ${opt} in
    c) category=$OPTARG ;;
    s) criticality=$OPTARG ;;
    h) help ;;
    esac
done
shift $(($OPTIND - 1))
description="$*"

[ -z "${endpoint}" ] && abort "Please specify the Changelog API endpoint in the env variable CHANGELOG_ENDPOINT. It'll probably end with /api/events."
[ -z "${description}" ] && abort "No message specified."

data="{\"criticality\": \"${criticality}\", \"unix_timestamp\": \"$(date +%s)\", \"category\": \"$category\", \"description\": \"$description\"}"

echo "POSTing to ${endpoint} with ${curl}: ${data}"
${curl} ${endpoint} -X POST -H 'Content-Type: application/json' -d "$data"
echo
