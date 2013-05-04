#!/bin/bash
# <> prov:specializationOf <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/cr-latest-logs.sh> .
#

see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set'
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:conversion-cockpit cr:directory-of-versions"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

if [[ `is-pwd-a.sh cr:conversion-cockpit` == "yes" ]]; then

   if [ -e doc/logs/conversion-trigger-last-pulled ]; then
      find doc/logs -type f -newer doc/logs/conversion-trigger-last-pulled
   else
      ls -lt doc/logs 2> /dev/null | grep -v "total" | head -1 | awk '{print "doc/logs/"$NF}'
   fi

elif [[ `is-pwd-a.sh cr:directory-of-versions` == "yes" ]]; then
   for next in `cr-list-versions.sh | tail -1`; do
      pushd $next > /dev/null
         # Recursive call to base case 'cr:conversion-cockpit'
         $0 $*
      popd > /dev/null
   done
elif [[ `is-pwd-a.sh cr:data-root cr:source cr:directory-of-datasets` == "yes" ]]; then
   for next in `directories.sh`; do
      pushd $next > /dev/null
         # Recursive call to base case 'cr:conversion-cockpit'
         echo $next/`$0 $*`
      popd > /dev/null
   done
elif [[ `is-pwd-a.sh              cr:source                                                             ` == "yes" ]]; then
   # TODO
   pushd dataset > /dev/null
      # Recursive call to base case 'cr:conversion-cockpit'
      $0 $*
   popd > /dev/null
elif [[ `is-pwd-a.sh                                                 cr:dataset                         ` == "yes" ]]; then
   pushd version > /dev/null
      # Recursive call to base case 'cr:conversion-cockpit'
      $0 $*
   popd > /dev/null
fi
