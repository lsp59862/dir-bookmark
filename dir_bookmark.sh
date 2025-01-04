#!/usr/bin/bash

# 前缀
PREFIX="BOOKMARK_"

# 主函数
function main {
	case "$1" in
		mark)
			if [ -z "$2" ]; then
				echo "Usage: mark <name> "
				return 1
			fi
			NAME=$2
			DIR=$(pwd)
			if [ ! -d "$DIR" ]; then
				echo "Error: Directory '$DIR' does not exist."
				return 1
			fi
			export "${PREFIX}${NAME}=$DIR"
			echo "'$NAME'	'$DIR'."
			;;
		goto)
			if [ -z "$2" ]; then
				echo "Usage: goto <name>"
				return 1
			fi
			NAME=$2
			TAR_ENV="${PREFIX}${NAME}"
			DIR="${!TAR_ENV}"
			if [ -z "$DIR" ]; then
				echo "Error: Bookmark '$NAME' not found."
				return 1
			fi
			cd "$DIR" || { echo "Failed to change directory to '$DIR'"; return 1; }
			;;
		list)
			# 获取所有以 PREFIX 开头的环境变量名，并去掉前缀
			bookmarks=$(env | grep "^${PREFIX}" | cut -d= -f1 | sed "s/^${PREFIX}//")
			# 检查是否找到了任何书签
			if [ -z "$bookmarks" ]; then
				echo "No bookmarks found."
			else
				echo "Bookmarks:"
				# 使用 IFS 来确保书签名被正确分割（处理包含空格的书签名）
				IFS=$'\n' # 将内部字段分隔符设置为换行符，以便 for 循环正确处理包含空格的行
				for bookmark in $bookmarks; do
					# 构造完整的变量名（如果需要加上去掉的后缀，则在这里加上）
					# 注意：这里我们不再需要去掉的后缀，因为已经在 sed 中去掉了
					full_var_name="${PREFIX}${bookmark}" # 如果 PREFIX 原本不应该有 "_"，则这里应该是 "${PREFIX}书签的实际后缀${bookmark}"
					# 使用 eval 安全地获取环境变量的值
					eval "value=\"\${$full_var_name}\""
					# 输出书签名和对应的值
					echo "  $bookmark       $value"
				done
				unset IFS # 恢复 IFS 的默认设置
			fi
			;;
		del)
			if [ -z "$2" ]; then
				echo "Usage: del <name>"
				return 1
			fi
			NAME=$2
			unset "${PREFIX}${NAME}"
			echo "Bookmark '$NAME' deleted."
			;;
		*)
			echo "Usage: $0 {mark <name> | goto <name> | list | del <name>}"
			;;
	esac
}

# 调用主函数
main "$@"
