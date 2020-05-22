#!/bin/sh

. ./assignment-1-test-iteration.sh

cd $1

filesdir=/tmp/aesd-data
numfiles=10
writestr="AESD_IS_AWESOME"
#TODO: Add student username for every instance
username=your-github-name-here

./writer.sh
rc=$?
if [ $rc -ne 1 ]; then
	add_validate_error "writer.sh should have exited with return value 1 if no parameters were specified"
fi

./writer.sh "$filedir"
rc=$?
if [ $rc -ne 1 ]; then
	add_validate_error "writer.sh should have exited with return value 1 if write string is not specified"
fi

./tester.sh
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "tester.sh execution failed with return code $rc"
fi

assignment_1_test_validation ${filesdir} ${numfiles} ${writestr} ${username}

rm -rf ${filesdir}

RANDOM=`hexdump -n 2 -e '/2 "%u"' /dev/urandom`
numfiles=$(( ${RANDOM} % 100 ))
randomstring=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
writestr="Random_char_string${randomstring}"

./tester.sh ${numfiles} ${writestr}
assignment_1_test_validation ${filesdir} ${numfiles} ${writestr} ${username}