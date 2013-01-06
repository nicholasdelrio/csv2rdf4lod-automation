#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/nt-nodes.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/rdf2nt.sh> .
#
# Print the URI subjects and objects of the given RDF file.
#
# To handle more files than 'ls' can provide:
#   find . -name "[^.]*" | xargs      nt-nodes.sh > nodes.txt

if [[ $# -eq 0 || "$1" == "--help" ]]; then
   echo
   echo "usage: `basename $0` [--version <version>] <some.rdf>*"
   echo "  Print the URI subjects and objects of the given RDF file."
   exit
fi

version=''
if [[ "$1" == "--version" && $# -gt 1 ]]; then
   version="$2"
   shift 2
fi

while [ $# -gt 0 ]; do
   file="$1" 

   if [ ! -f $file ]; then
      continue
   fi

   rdf2nt.sh --version 2 $file | awk '$1 ~ /^<.*/ { print $1 } $3 ~ /^<.*/ { print $3 }'

   shift
done
