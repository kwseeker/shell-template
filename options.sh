#!/bin/bash
# Author: ArvinLee

COMMAND=

# $0: 第一个参数：执行脚本本身
usage()
{
    echo "
Usage:
    $0 [-h] [--versions] [-c]

Options and Arguments:
 -h,--help                	Print usage
 --versions					Print version

EXAMPLES:
  $0 -h
  $0 --version
  $0 -c CMD
"
}

list_versions()
{
	echo "show version ..."
}

# $# 所有参数个数
parse_arguments()
{
    while [[ $# -gt 0 ]]
    do
		key="$1"
		# echo "current first param: $1"

		case $key in
			-h | --help)
				usage
				exit 0
				;;
			--versions)
				list_versions
				exit 0
				;;
			-c | --command)
				COMMAND="$2"
				shift # $1...$n参数全部左移一位，相当于清除原$1指向的参数
				# echo "after shift: " "${@}"
				shift
				# echo "after shift: " "${@}"
				;;
			*)    # unknown option
				POSITIONAL+=("$1") # save it in an array for later
				shift # past argument
				;;
		esac
    done

    set -- "${POSITIONAL[@]}" # restore positional parameters
}

do_biz() {
	echo "do biz ..."

	if [ "${COMMAND}" ] ; then
		echo "command: ${COMMAND}"
	fi
}

main()
{
	# ${@}不包含$0
	# echo "${@}"	
	parse_arguments "${@}"

	# 根据参数执行业务逻辑
	do_biz
}

main "${@}"
