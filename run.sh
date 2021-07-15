#!/bin/sh

logsdir=logs
jarsdir=jars

taplint_flags="stages='cap avv'"

usage="
   Usage: $0 [-v <release-version>|-jar <stilts-jar>] [-label <version-label>]
"

stilts="stilts"

while [ $# -gt 0 ]
do
   key="$1"
   case $key in
      -v|-version)
         version="$2"
         shift
         shift
         ;;
      -label)
         label="$2"
         shift
         shift
         ;;
      -jar)
         stilts="java -jar $2"
         shift
         shift
         ;;
      -h|--help)
         echo "$usage"
         exit 0
         ;;
      *)
         echo "$usage"
         exit 1
         ;;
   esac
done

if [ -n "$version" ]
then
   vjar=$jarsdir/stilts-${version}.jar  
   mkdir -p $jarsdir
   if [ ! -f $vjar ]
   then
      curl http://andromeda.star.bris.ac.uk/releases/stilts/v${version}/stilts.jar -o $vjar || exit 1;
   fi
   stilts="java -jar $vjar"
fi

if [ -z "$label" ]
then
   if [ "$stilts" = "stilts" ]
   then
      label=`cd /mbt/starjava/source; git show -s --format=%h`
   else
      label=`$stilts -version | awk '/STILTS version/{print $3}'`
   fi
fi

echo "stilts: $stilts"
echo "label: $label"
echo


logdir="$logsdir/$label"
mkdir -p $logdir
for record in `cat tapurls.txt`
do
   url=`echo $record | sed 's/.*,//'`
   label=`echo $record | sed 's/,.*//'`
   fname="${logdir}/${label}.taplint"
   echo $fname
   cmd="$stilts taplint $taplint_flags tapurl=$url >$fname"
   echo "$cmd"
   eval $cmd
done
