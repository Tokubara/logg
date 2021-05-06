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
  last_time=$(echo $last_line | cut -d ';' -f 1 )
  last_time_in_seconds=$( date -u -d "$last_time" +"%s" )
  cur_time="$(date +'%H:%M %m/%d/%Y')"
  cur_time_in_seconds=$( date -u -d "$cur_time" +"%s" ) # 这里是错误, 应该会是起始日期, 而不是当前日期
  diff_time="$(date -u -d "0 $cur_time_in_seconds seconds - $last_time_in_seconds seconds" +'%H:%M')" # 注意这里前面的seconds不可省略, 有2个seconds
  echo $last_line | awk -v last_time="$last_time" -v cur_time="$cur_time" -v diff_time="$diff_time" '{FS=OFS=";"}{$1=last_time ";" cur_time ";" diff_time ; print $0}' >> $log_file
}

if [[ "$1" == fi* ]]; then
  finish
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]];then
  print_usage
elif [[ "$1" == "clean" ]];then
  rm $log_file
else
  tag=$1
  description=$2
  cur_time="$(date +'%H:%M %m/%d/%Y')"
  echo "$cur_time;$tag;$description" >> $log_file
fi





