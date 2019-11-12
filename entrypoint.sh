#!/bin/ash

set -e

case "$1" in
  "sh" | "ash" | "bash" | "/bin/sh" )
    exec "/bin/sh";;
  * )
    exec /usr/local/bin/sql-migrate "$@";;
esac
