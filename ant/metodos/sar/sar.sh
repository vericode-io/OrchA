#!/bin/bash

# PrimeUp: Outstanding IT Performance!
#
# Script SAR versao 1.6 - utilizado para monitorar contadores de sistemas operacionais
# linux durante as avaliacoes. Gera arquivos .csv que podem ser lidos pelos scripts
# do GNU-R feitos pelo Luis Felipe Faria.
#
# Autor: Caio Deutsch
# alteracao - 2014-02-15 Thiago Ruiz: colocado o script dentro do "script base"
#                        para ser possivel rodar script sem interacao humana.
# alteracao - 2015-01-09 Thiago Ruiz: adicao do stop
# alteracao - 2015-06-16 Thiago Ruiz: merge com versao do luiz e movendo script
# alteracao - 2015-10-01 Thiago Ruiz: correcao do stop e output no Inventario

#exemplo de como rodar (output dir como diretório corrente):   ./sar.sh ./--tempoExecucao=36000  --intervaloAmostragem=1  --monitorarProcessos=true  --nomeProcesso=java  --outputDir=.


if [ "x$1" == "xstop" ]; then
    MY_PID=$$
    LISTA=$(pgrep "sar|top" -u ${USER} | grep -v ${MY_PID} | grep -v grep)
    
    if [ "$LISTA" == "" ]; then
        echo "nenhum processo a ser finalizado"
        exit
    fi
    
    echo "lista de processos a serem encerrados:"
    echo "$(ps -fp ${LISTA})"
    kill -9 ${LISTA}
    exit
fi


logWrite() {
    echo "$(date "+%Y/%m/%d %H:%M:%S") SHELL - ${1}"
}

startWith()
{
    local tmp=${1:0:${#2}}
    if [ "$tmp" == "$2" ];then
        return 1
    else
        return 0
    fi
}

helpmsg()
{
    logWrite ""
    logWrite ""
    if [ "$@" != "" ]; then
        logWrite "$@"
    fi
    logWrite ""
    logWrite ""
    logWrite "os seguintes parametros podem ser passados: "
    logWrite ""

    HELP_PARAMETERS=""
    for varname in $VARIAVEIS_POSSIVEIS; do
        HELP_PARAMETERS="$HELP_PARAMETERS --$varname=<VALOR> "
    done

    logWrite " $HELP_PARAMETERS "
    logWrite ""
    logWrite "(tempos em segundos)"
    logWrite ""
    logWrite "os seguintes parametros sao opcionais: "
    logWrite " --nomeProcesso=<nome-de-um-processo> "
    logWrite " --outputDir=<diretorio> "
    logWrite ""
    logWrite ""
    logWrite "pode ser passados quantos \"--nomeProcesso\" forem necessarios"
    logWrite ""
    logWrite "caso o outputDir nao seja indicado, o diretorio corrente sera usado"
    logWrite ""
    logWrite "caso nao queira passar nenhum nome de processo para monitorar eh necessario passar o parametro:"
    logWrite " --monitorarProcessos=false "
    logWrite ""
    logWrite "se o parametro em questao possuir espacos (nomes de arquivos com espacos) "
    logWrite " passe o parametro todo entre aspas duplas: "
    logWrite ""
    logWrite " exemplo:    \"--logfile=/tmp/arquivo com espacos.log\" "
    logWrite ""

    exit

}

# passa um por um dos argumentos e tenta setar as variaveis necessarias do script
# de maneira dinamica (para mais variaveis, basta adicionar no array de variaveis necessarias
#
initParameters()
{
    for i in $VARIAVEIS_POSSIVEIS; do
        varname=$i
            for j in "$@"; do
                getParameter "$j" $varname
            done
        done
}

# pega os dois parametros passados... se o parametro 1 comecar "--<NOME_VARIAVEL_NECESSARIA>="
# entao o script seta o valor desta variavel (utilizando a substring)
#
getParameter()
{
    paramVerified="--$2="
    startWith "$1" "$paramVerified"
    if [ $? -eq 1 ]; then

        #obs.: toda variavel pode ser tratada como array em shell.. nao sabia...
        local tmp=${1:${#paramVerified}:${#1}}

        #referencia indireta... legal...
        local valorAnterior=$(eval echo \$$2)

        if [ "$valorAnterior" != "" ]; then
            local sizeAnterior=$(eval echo \${#$2[@]})
            eval "$2[$(expr $sizeAnterior + 1)]"=\"$tmp\"
        else
            eval "$2"=\"$tmp\"
        fi

    fi

}


# verificacoes nos parametros... infelizmente este cara nao dah pra ser generico...
# cada parametro precisa ser validado de maneira particular para uma msg de erro especifica
#
checkParameters()
{
  totalVars="$(echo "$VARIAVEIS_POSSIVEIS" | wc -w)"
  totalVars=$( expr $totalVars - 2 )

  if [ $# -lt ${totalVars} ]; then
       helpmsg " ERRO: passar pelo menos ${totalVars} parametros (passou $#)"
  fi

## exemplos de validacoes de data, etc...

#  if [ $contratos -lt 0 ]; then
#helpsmsg " ERRO: O valor passado nao pode ser menor que 0 "
#  fi
#
#  if [ $contratos -gt 99 ]; then
#helpsmsg " ERRO: O valor passado nao pode ser maior que 99 "
#  fi
#

#    if [ "${#startdate[@]}" -ne 1 ]; then
#        helpmsg " ERRO: passar uma (somente uma) data de inicio com --startdate=<YYYYMMDD-hh:mm:ss> ( vc passou ${#startdate[@]} )"
#    fi
#
#    if [ "${#enddate[@]}" -ne 1 ]; then
#        helpmsg " ERRO: passar uma (somente uma) data de termino com --enddate=<YYYYMMDD-hh:mm:ss> ( vc passou ${#enddate[@]} ) "
#    fi
#
#    if [ "${#logfile[@]}" -lt 1 ]; then
#        helpmsg " ERRO: passar pelomenos um arquivo de log com --logfile=<path arquivo> ( vc passou ${#logfile[@]} )"
#    fi
#
#    for logfileAtual in "${logfile[@]}"; do
#        if [ ! -f "$logfileAtual" ]; then
#            helpmsg " ERRO: arquivo '$logfileAtual' nao eh arquivo regular... abortando script!!"
#        fi
#        if [ ! -r "$logfileAtual" ]; then
#            helpmsg " ERRO: arquivo '$logfileAtual' nao existe ou nao pode ser lido... abortando script!!"
#        fi
#    done
#
#    start_timestamp=$(date -d "${startdate:0:4}-${startdate:4:2}-${startdate:6:2} ${startdate:9}" +%s)
#    if [ $? -ne 0 ]; then
#        helpmsg " ERRO: startdate invalida ('$startdate')"
#    fi
#
#    end_timestamp=$(date -d "${enddate:0:4}-${enddate:4:2}-${enddate:6:2} ${enddate:9}" +%s)
#    if [ $? -ne 0 ]; then
#        helpmsg " ERRO: enddate invalida ('$enddate')"
#    fi
}

main()
{

    START=$(date +%s)

    DATA_RUN=$(date +%F_%H-%M-%S)

    if [ "" != "$(hostname -a)" ]; then
        HOST="$(hostname -a)"
        OUTPUT_DIR="sar_${HOST}_${DATA_RUN}"
    else
        #logWrite "impossivel determinar alias, usando hostname como output dir..."
        HOST="$(hostname)"
        OUTPUT_DIR="sar_${HOST}_${DATA_RUN}"
    fi

    # se usuario determinou outdir usa ele....
    if [ "" != "${outputDir}" ]; then
        if [ -d "${outputDir}" -a -w ${outputDir} ]; then
            OUTPUT_DIR="${outputDir}/${OUTPUT_DIR}"
        else
            logWrite "outputDir nao existe, nao eh um diretorio ou nao tem permissao de escrita... interrompendo script"
        fi
    fi


    mkdir "${OUTPUT_DIR}"

    if [ "false" == "${monitorarProcessos}" ]; then
        logWrite " --monitorarProcessos=false identificado, nenhum processo (pid) sera monitorado...."
    else

        if [ ${#nomeProcesso[@]} -eq 0 ]; then
            helpmsg "ERRO: nenhum parametro --nomeProcesso encontrado"
        fi

        TODOS_PROCESSOS=$(ps aux)

        for processoAtual in "${nomeProcesso[@]}"; do

            #limitei o tamanho do nome do comando para nao atingir o limite
            #aqui filtro processo do proprio bash atual tambem...
            processos=$(echo "$TODOS_PROCESSOS" |  grep -e "$processoAtual" | \
                grep -v grep | awk '{print $2}' | grep -v "$$" ) 2>&1

            if [ "$processos" == "" ]; then
                echo "impossivel determinar o pid do processo '$processoAtual'... "   $OUTPUT_DIR/Inventario.txt
            fi

            echo "$processos" | while read pidAtual; do

                #echo " pid obtido pelo filtro '$processoAtual': $pidAtual "
                TOP_ARGS=" -b -d $intervaloAmostragem -n $tempoExecucao -p $pidAtual "

                filename="$OUTPUT_DIR/processo_${processoAtual}_pid_${pidAtual}.csv"

                LC=ALL top $TOP_ARGS 2>&1 |awk 'BEGIN{ print "\"Hour\";\"PR\";\"NI\";\"VIRT\";\"RES\";\"SHR\";\"%CPU\";\"%MEM\";\"TIME+\"" } NF && $1~/^[0-9]/ {
                    print strftime("\"%r\";") "\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\";\"" $9 "\";\"" $10 "\";\"" $11 "\"" ;
                }' > "$filename" &

            done
        done
 
    fi    

    LC=ALL sar -b $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\""}' > "$OUTPUT_DIR/Disk_IO.csv" &
    LC=ALL sar -B $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\""}' > "$OUTPUT_DIR/Disk_Paging.csv" &
    LC=ALL sar -n DEV $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\";\"" $8 "\";\"" $9 "\";\"" $10 "\""}' > "$OUTPUT_DIR/EthernetInterfaces.csv" &
    LC=ALL sar -P ALL $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\";\"" $8 "\";\"" $9 "\"" }' > "$OUTPUT_DIR/CPU_Units.csv" &
    LC=ALL sar -r $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\";\"" $8 "\";\"" $9 "\";\"" $10 "\";\"" $11 "\""}' > "$OUTPUT_DIR/Memory_Utilization.csv" &
    LC=ALL sar -R $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\""}' > "$OUTPUT_DIR/Memory_Paging.csv" &
    LC=ALL sar -q $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\"" }' > "$OUTPUT_DIR/Queue_LoadAverage.csv" &
    LC=ALL sar -u $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\";\"" $8 "\";\"" $9 "\""}' > "$OUTPUT_DIR/CPU_All.csv" &
    LC=ALL sar -d $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\";\"" $5 "\";\"" $6 "\";\"" $7 "\";\"" $8 "\";\"" $9 "\";\"" $10 "\";\"" $11 "\""}' > "$OUTPUT_DIR/Device_activity.csv" &
    LC=ALL sar -w $intervaloAmostragem $tempoExecucao  | awk 'NR > 2 { if($1 == "Average:" || $1 == "") next; print "\"" $1 " " $2 "\";\"" $3 "\";\"" $4 "\"" }' >  "$OUTPUT_DIR/Context_Switches.csv" &


    echo "\"Hour\";\"PhysicalmemoryBytesUsed\"" > "$OUTPUT_DIR/PhysicalmemoryBytesUsed.csv" &
    for i in $(seq 1 $tempoExecucao); do sleep $intervaloAmostragem; free | grep "Mem:"| awk -v  date="$(date +%r)"  'BEGIN{} {print "\"" date "\";\"" $3 - $5 - $6 - $7"\"" }'; done >> "$OUTPUT_DIR/PhysicalmemoryBytesUsed.csv" &

    cat /proc/cpuinfo | grep processor > ${OUTPUT_DIR}/.cpus
    wc -l ${OUTPUT_DIR}/.cpus > ${OUTPUT_DIR}/.numcpus
    cat /proc/cpuinfo | grep "cpu MHz" > ${OUTPUT_DIR}/.clock
    cpus=`cat ${OUTPUT_DIR}/.numcpus | awk 'begin {fs=" "};{print $1}'`
    clock=`head -n 1 ${OUTPUT_DIR}/.clock | awk -F" " '{print $4}'`
    memoria=`cat /proc/meminfo | grep MemTotal |  awk -F" " '{print $2}'`

    echo "Processadores:"$cpus > $OUTPUT_DIR/Inventario.txt
    echo "Clock_MHZ:"$clock >> $OUTPUT_DIR/Inventario.txt
    echo "Memoria_KB:"$memoria >> $OUTPUT_DIR/Inventario.txt
    echo "Host:"$HOST >> $OUTPUT_DIR/Inventario.txt
    echo "" >> $OUTPUT_DIR/Inventario.txt
    echo "Linha de comando usada:$0 $@" >> $OUTPUT_DIR/Inventario.txt
    echo "" >> $OUTPUT_DIR/Inventario.txt

    if [ "" != "${TODOS_PROCESSOS}" ]; then
        echo "Processos durante start: " >> $OUTPUT_DIR/Inventario.txt
        echo "" >> $OUTPUT_DIR/Inventario.txt
        echo "${TODOS_PROCESSOS}" >> $OUTPUT_DIR/Inventario.txt
        echo "" >> $OUTPUT_DIR/Inventario.txt
    fi


    END=$(date +%s)

    #logWrite ""
    #logWrite "fim processamento (demorou $(expr $END - $START) secs)"
    logWrite " sar rodando em background.... "

}

#variaveis necessarias: ao adicionar neste array uma variavel o script ira validar se ela foi passada
# (independentemente da ordem que foi passada) e ao identifica-la setara o valor (vide funcoes initParameters e getParameter)
#
# APESAR DESTE COMPORTAMENTO DINAMICO, CASO ESTE SCRIPT SEJA USADO COMO BASE PARA OUTRO SCRIPT SERA NECESSARIO ALTERAR A FUNCAO
# checkParameters E ADICIONAR A LOGICA PARA VALIDAR O NOVO PARAMETRO ADICIONADO
#
VARIAVEIS_POSSIVEIS=" tempoExecucao intervaloAmostragem monitorarProcessos nomeProcesso outputDir "


#obs.: nao tirar a aspas duplas dos parametros.. senao a funcao main pode receber numero errado de parametros
# o sifrao arroba entre aspas passa parametros para a funcao exatamente como o usuario passou para o nosso shellscript
# (se tiver parametros com espacos agrupados por aspas eles serao passados para a funcao como 1 parametro soh, nao como 2 ou mais)

initParameters "$@"
checkParameters "$@"

main "$@"





