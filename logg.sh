# logg kv 读tracker
# logg finish/或者fi
# logg -h

log_file=~/.logg
# log_file=logg.txt

# TODO 看看支持的time格式
print_usage() {
  cat <<- EOF
time format: 12:23|5/10 12:23|yesterdat 12:23
tags is splitted by ,

logg tags description
logg fi[nish] [-t time] [-d description]
logg add start_time end_time tags description
logg now: echo the last event
logg -h
logg clean
EOF
exit 0
}

# 调用条件: 需要先设置好last_line
# 功能: 如果log文件不存在或者最后一行字段数>3(表明是已完成的记录), exit 1
finish_validate() {
  # 检查last_line字段数是否为3
  if ! [[ -e $log_file ]]; then
    echo "log file does not exist"
    exit 1
  fi
  nf=$( echo $last_line | awk -F ';' '{print NF}')
  # echo $nf
  if (( nf>3  )) ; then
    echo "nothing is being doing"
    echo $last_line
    exit 1
  fi
}

# 使用条件: 需要finish传入它的全部参数
# 会设置description, end_time两个变量
finish_parse_arg() {
  while (($#))
  do
    case "$1" in
      -d|--description)
        description="$2"
        shift 2
        ;;
      -t|--time)
        end_time="$2"
        shift 2
        ;;
      *)
        print_usage
        ;;
    esac
  done
}

finish() {
  last_line=$(tail -1 ${log_file}) # 得到了最后一行
  finish_validate

  end_time="$(date +'%H:%M %m/%d/%Y')" # 是那种写法, 不确定后面会不会被改写, 就这样先写着
  description=$( echo $last_line | awk -F ';' '{print $3}') # 本来description是第3字段
  finish_parse_arg "$@" # 获得了description和end_time

  start_time=$(echo $last_line | cut -d ';' -f 1 )
  start_time_in_seconds=$( date -u -d "$start_time" +"%s" )
  end_time_in_seconds=$( date -u -d "$end_time" +"%s" )
  diff_time="$(date -u -d "0 $end_time_in_seconds seconds - $start_time_in_seconds seconds" +'%H:%M')" # 注意这里前面的seconds不可省略, 有2个seconds

  sed -i "$ d" $log_file

  echo $last_line | awk -v start_time="$start_time" -v end_time="$end_time" -v diff_time="$diff_time" -v description="$description" 'BEGIN{FS=OFS=";"}{$1=start_time ";" end_time ";" diff_time ; $3=description; print $0}' >> $log_file
}

# 调用不需要先得到什么变量, 也不需要传参
validate_add() {
  if [[ -e ${log_file} ]]; then
    last_line=$(tail -1 ${log_file}) # 得到了最后一行
    # 检查last_line字段数是否为3
    nf=$( echo $last_line | awk -F ';' '{print NF}')
    # echo $nf
    if (( nf<5  )) ; then
      echo "haven't finish"
      echo $last_line
      exit 1
    fi
  fi
}

# 格式会是: 时间;tag;描述
add_now() {
  if (($# != 2)); then
    print_usage
  fi
  validate_add
  tag=$1
  description=$2
  start_time="$(date +'%H:%M %m/%d/%Y')"
  echo "$start_time;$tag;$description" >> $log_file
}

add_event() {
  if (($# != 4)); then
    print_usage
  fi
  validate_add
  start_time=$1
  end_time=$2
  tag=$3
  description=$4
  start_time_in_seconds=$( date -u -d "$start_time" +"%s" )
  end_time_in_seconds=$( date -u -d "$end_time" +"%s" )
  diff_time="$(date -u -d "0 $end_time_in_seconds seconds - $start_time_in_seconds seconds" +'%H:%M')" # 注意这里前面的seconds不可省略, 有2个seconds
  echo "$start_time;$end_time;$diff_time;$tag;$description" >> $log_file
}

print_now() {
  tail -1 $log_file
}

# TODO 用case语句改
case "$1" in
  fi*)
    shift
    finish "$@"
  ;;
  -h|--help)
    print_usage
  ;;
  clean)
    rm $log_file
  ;;
  add)
    shift
    add_event "$@"
  ;;
  now)
    print_now
  ;;
  *)
    add_now "$@"
  ;;
esac

