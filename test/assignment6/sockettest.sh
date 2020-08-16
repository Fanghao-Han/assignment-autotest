# !/bin/bash
# Tester script for sockets using Netcat

pushd `dirname $0`
target=localhost
port=9000
function printusage
{
	echo "Usage: $0 [-t target_ip] [-p port]"
	echo "	Runs a socket test on the aesdsocket application at"
	echo " 	target_ip and port specified by port"
	echo "	target_ip defaults to ${target}" 
	echo "	port defaults to ${port}" 
}

while getopts "t:p:" opt; do
	case ${opt} in
		h )
			target=$OPTARG
			;;
		p )
			port=$OPTARG
			;;
		\? )
			echo "Invalid option $OPTARG" 1>&2
			printusage
			exit 1
			;;
		: )
			echo "Invalid option $OPTARG requires an argument" 1>&2
			printusage
			exit 1
			;;
	esac
done

echo "Testing target ${target} on port ${port}"

# Tests to ensure socket send/receive is working properly on an aesdsocket utility
# running on the system
# @param1 : The string to send
# @param2 : The previous compare file
# @param3 : delay in seconds to test periodic timestamp
# Returns if the test passes, exits with error if the test fails.
function test_send_socket_string
{
	string=$1
	prev_file=$2
	new_file=`tempfile`
	expected_file=`tempfile`

	echo "sending string ${string} to ${target} on port ${port}"
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}
	cp ${prev_file} ${expected_file}
	echo ${string} >> ${expected_file}
	
	diff ${expected_file} ${new_file} > /dev/null
	if [ $? -ne 0 ]; then
		echo "Differences found after sending ${string} to ${target} on port ${port}"
		echo "Expected contents to match:"
		cat ${expected_file}
		echo "But found contents:"
		cat ${new_file}
		echo "With differences"
		diff -u ${expected_file} ${new_file}
		echo "Test complete with failure"
		exit 1
	else
		cp ${expected_file} ${prev_file}
		rm ${new_file}
		rm ${expected_file}
	fi
}

# Tests to ensure socket timer is working properly on an aesdsocket utility
# running on the system
# @param1 : delay in seconds to test periodic timestamp
# Returns if the test passes, exits with error if the test fails.
function test_socket_timer
{
	string="dummy"
	delay_secs=$1
	
	new_file=`tempfile`
	
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}

	cur_timestamp=$(grep -c "timestamp:" ${new_file})
	echo "No of timestamps currently in server file: ${cur_timestamp}"

	no_of_timestamps_during_delay=$((${delay_secs}/10))
	expected_timestamps=$((${cur_timestamp}+${no_of_timestamps_during_delay}))
	echo "No of timestamps expected after a delay of ${delay_secs} seconds is ${expected_timestamps}"

	sleep ${delay_secs}
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}

	verify_timestamps=$(grep -c "timestamp:" ${new_file})
	echo "No of timestamps found in file: ${verify_timestamps}"

	if [ ${verify_timestamps} -ge ${expected_timestamps} ]; then
		rm ${new_file}
		
	else
		echo "Differences found in the number of timestamps occurances"
		echo "Test complete with failure. Check your timer functionality"
		exit 1	
	fi
}

string1="One best book is equal to a hundred good friends, but one good friend is equal to a library"
string2="If you want to shine like a sun, first burn like a sun"
string3="Never stop fighting until you arrive at your destined place - that is, the unique you"

function test_socket_thread1
{
	for i in {1..20}
	do
		echo ${string1} | nc ${target} ${port} -w 1 > /dev/null
	done
}

function test_socket_thread2
{	
	for i in {1..20}
	do
		echo ${string2} | nc ${target} ${port} -w 1 > /dev/null
	done
}

function test_socket_thread3
{	
	for i in {1..20}
	do
		echo ${string3} | nc ${target} ${port} -w 1  > /dev/null
	done
}

# Tests to ensure socket multithreaded send/receive is working properly on an aesdsocket utility
function validate_multithreaded
{
	string="dummy"	
	new_file=`tempfile`
	
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}

	count_thread1=$(grep -o "$string1" ${new_file} | wc -l)
	count_thread2=$(grep -o "$string2" ${new_file} | wc -l)
	count_thread3=$(grep -o "$string3" ${new_file} | wc -l)

	if [ ${count_thread1} -eq 20 ] && [ ${count_thread2} -eq 20 ] && [ ${count_thread3} -eq 20 ]; then
		echo "**** END OF TEST CASES ****"
		
	else
		if [ ${count_thread1} -ne 20 ]; then
			echo "Found $count_thread1 instance of string -> $string1 "
			echo "But expected 20 instances"
		fi

		if [ ${count_thread1} -ne 20 ]; then
			echo "Found $count_thread2 instance of string -> $string2 "
			echo "But expected 20 instances"
		fi

		if [ ${count_thread3} -ne 20 ]; then
			echo "Found $count_thread3 instance of string -> $string3 "
			echo "But expected 20 instances"
		fi

		echo "Test complete with failure. Check your locking mechanism"
		exit 1		
	fi

}

comparefile=`tempfile`
test_send_socket_string "abcdefg" ${comparefile}
test_send_socket_string "hijklmnop" ${comparefile}
test_send_socket_string "1234567890" ${comparefile}
test_send_socket_string "9876543210" ${comparefile}

sleep 2s

test_send_socket_string "If your dream only includes you, it’s too small" ${comparefile}
test_send_socket_string "Don’t let anyone work harder than you do." ${comparefile}
test_send_socket_string "Life is 10% what happens to us and 90% how we react to it." ${comparefile}
test_send_socket_string "welcome to the winterland" ${comparefile}
test_send_socket_string "Harry Potter" ${comparefile}
test_send_socket_string "You may find the worst enemy or best friend in yourself." ${comparefile}
test_send_socket_string "The beauty of Taj Mahal is mind blowing" ${comparefile}
test_send_socket_string "Canberra is awesome" ${comparefile}

echo "Sending long string from long_string.txt file"
sendstring=`cat long_string.txt`
test_send_socket_string ${sendstring} ${comparefile}

sleep 2s

test_send_socket_string "Courage is the first of human qualities because it is the quality which guarantees all others" ${comparefile}
test_send_socket_string "Live each day as if your life had just begun" ${comparefile}
test_send_socket_string "What does a man project if he gains the whole world but loses his own soul" ${comparefile}

echo "Full contents sent:"
cat ${comparefile}
rm ${comparefile}

echo ""
echo "Testing the timer functionality"

test_socket_timer 20
test_socket_timer 40
test_socket_timer 80

echo ""
echo "Testing the multithreaded functionality"

test_socket_thread1&
test_socket_thread2&
test_socket_thread3&

sleep 30s

validate_multithreaded

echo "Congrats! Tests completed with success"
exit 0
