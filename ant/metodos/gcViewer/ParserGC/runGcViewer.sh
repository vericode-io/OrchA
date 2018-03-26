#!/bin/bash

startGeral=$(date +%s)

msg() {
    echo -e "$(date +%F-%T.%N) SHELL: $*"
}

if [ ! -d "${1}" ]; then
    echo "ERRO: passar o diretorio onde estao os logs de gc como primeiro parametro"
    exit 11
fi

if [ "${2}" == "" ]; then
    echo "ERRO: passar o diretorio onde sera criados os outputs do parser "
    exit 11
fi

#inputDir="/home/aci/ParsersCiclo3/aci/"
inputDir="${1}"
outputDir="${2}"

#java -jar gcviewer-1.3x.jar gc.log summary.csv [chart.png] [-t PLAIN|CSV|CSV_TS|SIMPLE|SUMMARY]
javaHome=../tools/jre8/jre1.8.0_60_linux_x64
jarFile=gcviewer-1.35-SNAPSHOT.jar

for i in $(find "${inputDir}" -type f)
do

    fileFullPath="$(readlink -f ${i})"
    fileName="$(basename ${i})"
    dirName="$(dirname ${i})"
    msg "Processando arquivo '${fileFullPath}'..."

    for types in PLAIN CSV CSV_TS SIMPLE SUMMARY
    do
        if [ "${types}" == "PLAIN" ]; then
            image="${outputDir}/${dirName}/${fileName}_chart_${types}.png"
        else
            image=""
        fi

        mkdir -p "${outputDir}/${dirName}"

        "${javaHome}/bin/java" -Xmx150M -jar $jarFile ${fileFullPath} ${outputDir}/${dirName}/${fileName}_summary_${types}.csv ${image} -t ${types}

    done

done


