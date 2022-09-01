#!/bin/bash
# Author: ArvinLee

# shell脚本中执行sql
# 软件测试经常需要制造测试数据,清除测试数据等等

IPADDR=127.0.0.1
USER=root
PASSWD=123456
SCHEMA=daily_quiz

MODE_VIEW="VIEW"
MODE_EXEC="EXEC"
SQL_COMMAND_PREFIX="mysql -h$IPADDR -u$USER -p$PASSWD $SCHEMA -e"
SPACE_ID=0
BEGIN_TIME=
END_TIME=
MODE=

# $0: 第一个参数：执行脚本本身
usage()
{
    echo "清除某空间指定时段的小问答答题测试数据
Usage:
    $0 [-h] [-v <space_id> <begin_time> <end_time>] [-e <space_id> <begin_time> <end_time>]

Options and Arguments:
  -h                帮助
  -v                预览SQL(不执行)
                    <space_id>      用户空间ID
                    <begin_time>    开始时间,格式 yyyy-MM-dd HH:mm:ss
                    <end_time>      结束时间,格式 yyyy-MM-dd HH:mm:ss
  -e                执行SQL                 
                    <space_id>      用户空间ID
                    <begin_time>    开始时间,格式 yyyy-MM-dd HH:mm:ss
                    <end_time>      结束时间,格式 yyyy-MM-dd HH:mm:ss

EXAMPLES:
  $0 -h
  $0 -v 985162617603909 '2022-09-01 00:00:00' '2022-09-02 00:00:00' 
  $0 -e 985162617603909 '2022-09-01 00:00:00' '2022-09-02 00:00:00' 
"
}

# 删除某空间ID某时段的测试数据
delete_today_record() 
{
    table_suffix=$((SPACE_ID%100))
    begin_time=$(($(date -d "$BEGIN_TIME" +%s)*1000))
    end_time=$(($(date -d "$END_TIME" +%s)*1000))
    # echo "$begin_time $end_time"

    sql="$SQL_COMMAND_PREFIX 'select * from daily_quiz_answer_process_$table_suffix where space_id = $SPACE_ID and add_time < $end_time and add_time > $begin_time;'"
    echo "$sql"
    result=$($SQL_COMMAND_PREFIX "select * from daily_quiz_answer_process_$table_suffix where space_id = $SPACE_ID and add_time < $end_time and add_time > $begin_time;")
    ids=$(echo "$result" | awk 'NR>1 {print $1}')
    # echo "$ids"
    params=""
    for id in $ids  
    do
        if [ "$params" == "" ]; then
            params="$params$id"
            continue
        fi 
        params="$params,$id"
    done

    if [ "$MODE" == $MODE_VIEW ] && [ "$params" != "" ]; then
        item=$(echo "$result" | awk 'NR>1 {print $0}')
        echo "$item"
        del_sql="$SQL_COMMAND_PREFIX 'delete from daily_quiz_answer_process_$table_suffix where id in ($params);'"
        echo "$del_sql"
    fi
    if [ "$MODE" == $MODE_EXEC ] && [ "$params" != "" ]; then
        del_sql="$SQL_COMMAND_PREFIX 'delete from daily_quiz_answer_process_$table_suffix where id in ($params);'"
        echo "$del_sql"
        $SQL_COMMAND_PREFIX "delete from daily_quiz_answer_process_$table_suffix where id in ($params);"
        # echo $?
        # [ $? -eq 0 ] && echo "success" || echo "failed"   # 变量（比如$val）可以这么写，但是执行结果返回值不能这么写，不知为何，这语法有点恶心
        print_result
    fi
    

    sql="$SQL_COMMAND_PREFIX 'select * from daily_quiz_answer_record_$table_suffix where space_id = $SPACE_ID and add_time < '$END_TIME' and add_time > '$BEGIN_TIME';"
    echo "$sql"
    result=$($SQL_COMMAND_PREFIX "select * from daily_quiz_answer_record_$table_suffix where space_id = $SPACE_ID and add_time < '$END_TIME' and add_time > '$BEGIN_TIME';")
    ids=$(echo "$result" | awk 'NR>1 {print $1}')
    # echo "$ids"
    params=""
    for id in $ids  
    do
        if [ "$params" == "" ]; then
            params="$params$id"
            continue
        fi 
        params="$params,$id"
    done

    if [ "$MODE" == $MODE_VIEW ] && [ "$params" != "" ]; then
        item=$(echo "$result" | awk 'NR>1 {print $0}')
        echo "$item"
        del_sql="$SQL_COMMAND_PREFIX 'delete from daily_quiz_answer_record_$table_suffix where id in ($params);'"
        echo "$del_sql"
    fi
    if [ "$MODE" == $MODE_EXEC ] && [ "$params" != "" ]; then
        del_sql="$SQL_COMMAND_PREFIX 'delete from daily_quiz_answer_record_$table_suffix where id in ($params);'"
        echo "$del_sql"
        $SQL_COMMAND_PREFIX "delete from daily_quiz_answer_record_$table_suffix where id in ($params);"
        print_result
    fi
}

print_result() 
{
    if [ $? -eq 0 ]; then
        echo "success"
    else 
        echo "failed"
    fi
}

# $# 所有参数个数
parse_arguments()
{
    case $1 in
    -h | --help)
        usage
        exit 0
        ;;
    -v)
        MODE=$MODE_VIEW
        ;;
    -e)
        MODE=$MODE_EXEC
        ;;
    *)  # unknown option
        usage
        exit 0
        ;;
    esac

    if [ $# -ne 4 ]; then
        echo "Err: invalid args!"
        usage
        exit 1
    fi

    echo "args: $1 $2 '$3' '$4', MODE: $MODE"
    tmp=$(echo "$2" | sed -n 's/[0-9]//g')
    # echo "tmp: $tmp"
    if [ -n "$tmp" ]; then
        echo "Err: <space_id> not numberic value"
        exit 1
    fi  
    SPACE_ID=$2
    BEGIN_TIME=$3
    END_TIME=$4
}

main()
{
	parse_arguments "${@}"

	delete_today_record
}

main "${@}"
