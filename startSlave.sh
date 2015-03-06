#! /bin/bash

host=$1
slave=$2
secret=$3
home=$4

java -jar ${home}/master/slave.jar -jnlpUrl ${host}/computer/${slave}/slave-agent.jnlp -secret ${secret} >> ${home}/temp/workAround.txt 2>&1 &

echo $!
