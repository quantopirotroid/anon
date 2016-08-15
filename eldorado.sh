#!/bin/bash

SROUTE=$(ip r | grep '178.248.235.20' | sed 's/ dev [a-z0-9]*//')
COUNTER=$(ip r | grep '178.248.235.20' | sed 's/ dev [a-z0-9]*//' | sed 's/[a-z0-9. ]*\.//' | sed 's/ //')
TMP="/opt/eldorado_test/tmp/"
TF="${TMP}index.html"

access_test()
{
cd ${TMP}
wget eldorado.ru &>> /dev/null 
if [[ -a ${TF} ]]
then
	rm -f ${TF}
	return 0
else
	return 1
fi
}

access_test
RTN=$?
if [[ ${RTN} -eq 0 ]]
then
	exit 0
else
	if [[ 17 = "$COUNTER" ]]
	then
		LIST="18 19"
	elif [[ 18 = "$COUNTER" ]]
	then
		LIST="17 19"
	else
		LIST="17 18"
	fi
	while [[ 0 != "$RTN" && 54 != "$COUNTER" ]]
	do
		for RCV in ${LIST}
		do
			ip r c 178.248.235.20 via 192.168.99.${RCV}
			access_test
			RTN=$?
			COUNTER=$(( ${COUNTER} + ${RCV} ))
		done
	done
fi
access_test
if [[ 0 -eq $? ]]
then
	echo "Access granted!"
	exit 0
else
	echo 'Bad day:('
fi

