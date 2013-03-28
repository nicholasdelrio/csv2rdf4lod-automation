#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/o-of-p.sh>;
#3> <> prov:wasDerivedFrom   <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/p-and-c.sh> .
#
# Print the objects of the given predicate in the given RDF file.
#
# To handle more files than 'ls' can provide:
#   find . -name "[^.]*" | xargs      nt-nodes.sh > nodes.txt

if [[ $# -eq 0 || "$1" == "--help" ]]; then
   echo
   echo "usage: `basename $0` [--as-ttl [type-uri]] --inverse-of <predicate> <some.rdf>*"
   echo "  Print the URI subjects and objects of the given RDF file."
   echo "  --as-ttl [class-uri] - output the list as a valid Trutle file, where the nodes are typed to rdfs:Resource."
   echo "           [class-uri] - use this class instead of rdfs:Resource (must be full URI, no <>)"
   exit
fi

as_ttl=''
class="rdfs:Resource"
if [[ "$1" == "--as-ttl" ]]; then
   as_ttl="$2"
   if [[ "$#" -gt 1 && ! -e "$2" ]]; then
      class=$2
      shift
   fi
   shift
fi

inverse=""
if [[ "$1" == "--inverse-of" ]]; then
   inverse="yes"
   shift
fi

predicate="`prefix.cc $1`" # http://www.w3.org/1999/02/22-rdf-syntax-ns#type
shift

total=$#
while [ $# -gt 0 ]; do
   file="$1" 

   if [ ! -f $file ]; then
      continue
   fi

   if [[ -n "$as_ttl" ]]; then
      echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
      echo
      $0 $predicate $* | awk -v class=$class '$1 ~ /^</ {print $1,"a",class,"."}'
   else
      if [[ $total -eq 1 && `gzipped.sh $file` == "yes" && `guess-syntax.sh $file mime` == "text/plain" ]]; then
         # Avoids dumping to an intermediate file.
         # e.g. 2.0 GB unzipped ntriples file can be done in 1.5 minutes (as opposed to 4.5 minutes).
         gunzip -c             $file | awk -v p="<$predicate>" so="3" '{if($2 == p){ gsub("<",""); gsub(">",""); print $so }}'
         if [[ -n "$inverse" ]]; then
            gunzip -c             $file | awk -v p="<$predicate>" so="1" '{if($2 == p){ gsub("<",""); gsub(">",""); print $so }}'
         fi
      else
         #echo ".${total}. .`gzipped.sh $file`. .`guess-syntax.sh $file mime`." >&2
         # Handles any syntax, compressed or not.
         rdf2nt.sh --version 2 $file | awk -v p="<$predicate>" so="3" '{if($2 == p){ gsub("<",""); gsub(">",""); print $so }}'
         if [[ -n "$inverse" ]]; then
            rdf2nt.sh --version 2 $file | awk -v p="<$predicate>" so="1" '{if($2 == p){ gsub("<",""); gsub(">",""); print $so }}'
         fi
      fi
   fi

   shift
done
