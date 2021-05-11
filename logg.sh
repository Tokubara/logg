# logg kv 读tracker
# logg finish/或者fi
# logg -h

log_file=~/.logg 

# TODO 看看支持的time格式
print_usage() {
  cat <<- EOF
example
logg kv,debug 读tracker
logg fi[nish] [time(12:23|5/10 12:23|yesterdat 12:23)] [description]
logg add start_time end_time tags(splitted by ,) description
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
# 会设置description, cur_time两个变量
finish_parse_arg() {
while (($#))
do
	case "$1" in
		-d|--description)
			description="$2"
			shift 2
		;;
		-t|--time)
			cur_time="$2"
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

  cur_time="$(date +'%H:%M %m/%d/%Y')" # 是那种写法, 不确定后面会不会被改写, 就这样先写着
  description=$( echo $last_line | awk -F ';' '{print $3}') # 本来description是第3字段
  finish_parse_arg $* # 获得了description和cur_time

  last_time=$(echo $last_line | cut -d ';' -f 1 )
  last_time_in_seconds=$( date -u -d "$last_time" +"%s" )
  cur_time_in_seconds=$( date -u -d "$cur_time" +"%s" )
  diff_time="$(date -u -d "0 $cur_time_in_seconds seconds - $last_time_in_seconds seconds" +'%H:%M')" # 注意这里前面的seconds不可省略, 有2个seconds

  sed -i "$ d" $log_file

  echo $last_line | awk -v last_time="$last_time" -v cur_time="$cur_time" -v diff_time="$diff_time" -v description="$description" 'BEGIN{FS=OFS=";"}{$1=last_time ";" cur_time ";" diff_time ; $3=description; print $0}' >> $log_file
}

# 格式会是: 时间;tag;描述
add_now() {
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
  tag=$1
  description=$2
  cur_time="$(date +'%H:%M %m/%d/%Y')"
  echo "$cur_time;$tag;$description" >> $log_file
}

# TODO 用case语句改
if [[ "$1" == fi* ]]; then
  shift
  finish $*
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]];then
  print_usage
elif [[ "$1" == "clean" ]];then
  rm $log_file
else
  add_now $*
fi





