# logg kv 读tracker
# logg finish/或者fi
# logg -h

log_file=~/.logg 

print_usage() {
  cat <<- EOF
example
logg kv 读tracker
logg fi[nish]
logg -h
EOF
exit 0
}

finish() {
  last_line=$(tail -1 ${log_file}) # 得到了最后一行
  last_time=$(echo $last_tine | cut -d ';' -f 1 )
  last_time_in_seconds=$( data -u -d "$last_time" +"%s" )
  cur_time=$(date +"%H:%M %m-%d")
  cur_time_in_seconds=$( data -u -d "$cur_time" +"%s" )
  diff_time="$(data -u -d '0 $cur_time_in_seconds - $last_time_in_seconds seconds' +'%H:%M')"
  echo $last_line | awk "{FS=:}{$1="$last_time;$cur_time;$diff_time" print $0}"
  echo 
}

if [[ "$1" == fi* ]]; then
  finish
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]];
  print_usage
else
  tag=$1
  description=$2
  cur_time=$(date +"%H:%M %m-%d")
  echo "$cur_time;$tag;$description" >> $log_file
fi





