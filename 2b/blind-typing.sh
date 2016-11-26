#!/bin/bash

usage=$"$(basename "$0") -h [--help] -- program to fun

USED: spd-say. if you have less than 14.04 - please install
"

text=$1
if [[ $text = "-h" || $text = "--help" ]];then
	echo "$usage"
	exit 0
fi

text_hello="Type the phrases you hear. Type a single question mark character to repeat, empty line to finish."
spd-say -w -t female1 "$text_hello"

file_name="inphrases"
if [ ! -f $file_name ];then
	echo "File $file_name not found!"
	exit 1
fi

count_lines=$(cat $file_name | wc -l)

error_count=0
all_count=0
while :
do
	if [ ! "$user_in" == "?" ];then
		line_num=$(shuf -i 1-$count_lines -n 1)
		text_speak=$(eval awk 'NR==$line_num' $file_name)
	fi
	spd-say -w -t female1 "$text_speak"

	read -e -s user_in

	if [[ -z $user_in ]];then
		if [[ $all_count != 0 ]];then
			echo "Your error rate is $(echo "scale=2; $error_count/$all_count" | bc)%. Bye!"
		fi
		exit 0
	fi

	if [ ! "$user_in" == "?" ];then
		text_one=$(echo "$user_in" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]' | tr -s " ")
		text_two=$(echo "$text_speak" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]' | tr -s " ")

		if [ ! "$text_one" == "$text_two" ];then
			text_error="Wrong!"
			spd-say -w -t female1 "$text_error"
			echo "Expected: $text_speak"
			echo "Typed: $user_in"
			if [ ! -f "errors.log" ];then
				touch "errors.log"
			fi
			echo "Expected: $text_speak" >> "errors.log"
			echo "Typed: $user_in" >> "errors.log"		

			((error_count++))
			((all_count++))
		else
			text_ok="Well done!"
			spd-say -w -t female1 "$text_ok"

			((all_count++))
		fi
	fi
done
