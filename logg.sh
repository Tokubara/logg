# logg kv 读tracker
# logg finish/或者fi
# logg -h

log_file=~/.logg 

print_usage() {
  cat <<- EOF
example
logg kv,debug 读tracker
logg fi[nish]
logg -h
logg clean
EOF
exit 0
}

finish() {
  last_line=$(tail -1 ${log_file}) # 得到了最后一行
  # 检查last_line字段数是否为3
  nf=$( echo $last_line | awk -F ';' '{print NF}')
  # echo $nf
  if (( nf>3  )) ; then
    echo "have finish"
    echo $last_line
    exit 1
  fi
  last_time=$(echo $last_line | cut -d ';' -f 1 )
  last_time_in_seconds=$( date -u -d "$last_time" +"%s" )
  cur_time="$(date +'%H:%M %m/%d/%Y')"
  cur_time_in_seconds=$( date -u -d "$cur_time" +"%s" ) # 这里是错误, 应该会是起始日期, 而不是当前日期
  diff_time="$(date -u -d "0 $cur_time_in_seconds seconds - $last_time_in_seconds seconds" +'%H:%M')" # 注意这里前面的seconds不可省略, 有2个seconds
  sed -i "$ d" $log_file
  echo $last_line | awk -v last_time="$last_time" -v cur_time="$cur_time" -v diff_time="$diff_time" 'BEGIN{FS=OFS=";"}{$1=last_time ";" cur_time ";" diff_time ; print $0}' >> $log_file
}

if [[ "$1" == fi* ]]; then
  finish
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]];then
  print_usage
elif [[ "$1" == "clean" ]];then
  rm $log_file
else
  last_line=$(tail -1 ${log_file}) # 得到了最后一行
  # 检查last_line字段数是否为3
  nf=$( echo $last_line | awk -F ';' '{print NF}')
  # echo $nf
  if (( nf<5  )) ; then
    echo "haven't finish"
    echo $last_line
    exit 1
  fi
  tag=$1
  description=$2
  cur_time="$(date +'%H:%M %m/%d/%Y')"
  echo "$cur_time;$tag;$description" >> $log_file
fi





