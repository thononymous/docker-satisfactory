#!/bin/bash

set -euxo pipefail

# default uid and gid
: "${UID:=1000}"
: "${GID:=$UID}"

# subcommands
usage() {
  >&2 echo "subcommands:"
  >&2 echo "      defconfig - copy default config to /saves"
  >&2 echo "             -- - exec the following"
  >&2 echo "              * - run the server with the provided arguments"
  exit 1
}

fixperms() {
  # fix uid and gid of all the shit
  groupmod -g $GID sat
  usermod -u $UID sat
  find / -xdev -uid 9999 -print0 | xargs -r -0 -- chown -c -h --from=9999 $UID
  find / -xdev -gid 9999 -print0 | xargs -r -0 -- chown -c -h --from=:9999 :$GID
}

# parse args
echo $#

if [[ $# -ge 1 ]]; then
  while [[ $# -ge 1 ]]; do
    case "$1" in
      -h)
        usage
        exit 1
        ;;
      --)
        shift
        fixperms
        break
        ;;
      *)
        fixperms
        if [[ $# -ge 1 ]]; then
          set -- /home/sat/Steam/steamapps/common/SatisfactoryDedicatedServer/FactoryServer.sh "$@"
        else
          set -- /home/sat/Steam/steamapps/common/SatisfactoryDedicatedServer/FactoryServer.sh
        fi
        break
        ;;
    esac
  done
else
  set -- /home/sat/Steam/steamapps/common/SatisfactoryDedicatedServer/FactoryServer.sh
fi

# drop root and GOOOOO
set -- sue $UID:$GID "$@"
echo "$@"
exec "$@"

# vim: set ts=2 sw=2 expandtab:
