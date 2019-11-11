#!/bin/bash

file=$1
project=$(echo "$2" | cut -d = -f 2)

if [[ "$file" = "" ]] ; then
    echo "Usage:  $0 <file with smatch messages> -p=<project>"
    exit 1
fi

if [[ "$project" != "kernel" ]] ; then
    exit 0
fi

outfile="kernel.rosenberg_funcs"
bin_dir=$(dirname $0)
remove=$(echo ${bin_dir}/../smatch_data/${outfile}.remove)
tmp=$(mktemp /tmp/smatch.XXXX)
tmp2=$(mktemp /tmp/smatch.XXXX)

echo "// list of copy_to_user function and buffer parameters." > $outfile
echo '// generated by `gen_rosenberg_funcs.sh`' >> $outfile
${bin_dir}/trace_params.pl $file copy_to_user 1 >> $tmp
${bin_dir}/trace_params.pl $file rds_info_copy 1 >> $tmp
${bin_dir}/trace_params.pl $file nla_put 3 >> $tmp
${bin_dir}/trace_params.pl $file snd_timer_user_append_to_tqueue 1 >> $tmp
${bin_dir}/trace_params.pl $file __send_signal 1 >> $tmp

cat $tmp | sort -u > $tmp2
mv $tmp2 $tmp
cat $tmp $remove $remove 2> /dev/null | sort | uniq -u >> $outfile
rm $tmp
echo "Done.  List saved as '$outfile'"
