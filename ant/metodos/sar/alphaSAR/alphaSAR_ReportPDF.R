
	rm(list=ls(all=TRUE))
	#####Digite o diretório local (Para Windows, Usar "/"  ao invés de "\"):

	#library(foreach)
	#library(doParallel)
	#library(parallel)

	#warning("getDoParWorkers()=", getDoParWorkers())
	#registerDoParallel(cores=10)
	#warning("getDoParWorkers()=", getDoParWorkers())
	
	args <- commandArgs(TRUE)
	
	myDir <- getwd();

	#######################################################################
	#######################################################################
	#Script Geração Graficos alphaSAR - Luis Faria luis.faria@primeup.com.br
	#######################################################################
	#######################################################################

	myFileConfig <- paste(myDir, '/metodos/sar/alphaSAR/Config_SAR.cfg', sep="");
	myConfig <- read.table(myFileConfig, header=FALSE, sep="=")
	projectName <- paste (myConfig[1,2])
	
	#MyFilesDirs <- list.dirs(paste(myDir,"Files_SAR",sep="")[grepl("^/*", list.files(myDir))])[-1]
	
	warning("myDir=", myDir)
	warning("args[1]=",args[1])
	
	filesToParse <- paste(myDir,args[1],sep="/")
	
	warning("tentando obter arquivos para parsesar do diretorio: ", filesToParse )
	
	MyFilesDirs <- list.dirs(filesToParse[grepl("^/*", list.files(myDir))])[-1]
	
	mcolnames <- c("Servername","Resource","Counter","Average","Deviation","Variation(%)","Max","Min","Percentil(95%)","Percentil(99%)","Samples")
	sarAllTables <- matrix(NA, 0, length(mcolnames))
	colnames(sarAllTables) = mcolnames
	
	warning("Iniciando...",immediate.= T)
	statusParcial <- -1
	statusTotal <- length(MyFilesDirs)
	ptm <- proc.time()

	#for (i in MyFilesDirs) %dopar%	{
	#foreach(i, MyFilesDirs) %dopar%	{
	for (i in MyFilesDirs) {
		
	statusParcial <- statusParcial + 1
	statusReal <- round(statusParcial/statusTotal*100,2)
	warning(paste(statusReal,"% Concluido",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
	myDirOut <-  paste (i,"/",sep="")

	processFileNames <- list.files(myDirOut)[grepl("^processo.*\\.csv", list.files(myDirOut))]
	processName <- as.character(strsplit(substring(processFileNames,10),".csv"))
	
	myFileQueueLoadAverage <-  paste (myDirOut,myConfig[2,2],sep="")
	myFileMemoryUtilization <-  paste (myDirOut,myConfig[3,2],sep="")
	myFileMemoryPaging <-  paste (myDirOut,myConfig[4,2],sep="")
	myFiledataSetEthernetInterfaces <-  paste (myDirOut,myConfig[5,2],sep="")
	myFileDiskPaging <-  paste (myDirOut,myConfig[6,2],sep="")
	myFileDiskIO <-  paste (myDirOut,myConfig[7,2],sep="")
	myFileCpuUnits <-  paste (myDirOut,myConfig[8,2],sep="")
	myFileCpuAll <-  paste (myDirOut,myConfig[9,2],sep="")
	myFileDeviceActivity <- paste (myDirOut,myConfig[10,2],sep="")
	myFileInfo <- paste (myDir,myConfig[13,2],sep="")
	myFileserverConfig <-  paste (myDirOut,myConfig[14,2],sep="")
	myFileContextSwitches <- paste (myDirOut,myConfig[11,2],sep="")
	sampleGroup <- as.numeric(paste (myConfig[12,2]))
	myphysicalMemoryBytesUsed <- paste (myDirOut,myConfig[15,2],sep="")
	flagHour <- paste (myConfig[16,2])
	hourBegin <- paste (myConfig[17,2])
	hourEnd <- paste (myConfig[18,2])


	tryCatch(dataSetQueueLoadAverage <- read.csv(myFileQueueLoadAverage, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetMemoryUtilization <- read.csv(myFileMemoryUtilization, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetMemoryPaging <- read.csv(myFileMemoryPaging, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetEthernetInterfaces <- read.csv(myFiledataSetEthernetInterfaces, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetDiskPaging <- read.csv(myFileDiskPaging, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetDiskIO <- read.csv(myFileDiskIO, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetCpuUnits <- read.csv(myFileCpuUnits, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetCpuAll <- read.csv(myFileCpuAll, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetDeviceActivity <- read.csv(myFileDeviceActivity, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(dataSetContextSwitches <- read.csv(myFileContextSwitches, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(physicalMemoryBytesUsed <- read.csv(myphysicalMemoryBytesUsed, sep=';', header=TRUE, fill=T, check.names=F),error=c)
	tryCatch(serverConfig <- read.csv(myFileserverConfig, sep=':', header=FALSE, fill=T, check.names=F),error=c)
	tryCatch(counterInfo <- read.csv(myFileInfo, sep=';', header=TRUE, fill=T, check.names=F),error=c)

	#warning( "####", physicalMemoryBytesUsed);
	#dataSetMemoryUtilization[dataSetMemoryUtilization == ""] <- NA
	
	#remove campos vazios do arquivo, devido a incompatibilidade do 'sar -r' em versão mais nova
	#sem isso mais a frente da pau quando manda gerar o grafico (thiago ruiz)
	dataSetMemoryUtilization <- Filter(function(x)!all(is.na(x)), dataSetMemoryUtilization)
	dataSetContextSwitches <- Filter(function(x)!all(is.na(x)), dataSetContextSwitches)
	
	
	tryCatch(colnames(dataSetQueueLoadAverage)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetMemoryUtilization)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetMemoryPaging)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetEthernetInterfaces)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetDiskPaging)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetDiskIO)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetCpuUnits)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetCpuAll)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetDeviceActivity)[1] <- "TIME",error=c)
	tryCatch(colnames(dataSetContextSwitches)[1] <- "TIME",error=c)
	tryCatch(colnames(physicalMemoryBytesUsed)[1] <- "TIME",error=c)


	flagHour <- as.logical (flagHour)

warning(paste("Criando Funcoes",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
	
chart <- function (temp,dataset,sampleGroup) {
infoDataFrame <- as.data.frame(colnames(dataset))
colnames(infoDataFrame)[1] <- "Contador"
infoDataFrame <- merge(counterInfo, infoDataFrame, by="Contador", all.y=TRUE)[-2]
infoDataFrame <- infoDataFrame[!is.na(infoDataFrame$Desc),1:(length(infoDataFrame))]

lineHourBegin <- which(dataset[1] == hourBegin)
plotHourBegin <- round(lineHourBegin/sampleGroup,0)

lineHourEnd <- which(dataset[1] == hourEnd)
plotHourEnd <- round(lineHourEnd/sampleGroup,0)		

if (flagHour == TRUE){
		dataset[ncol(dataset)+1] <- c (1:nrow(dataset))
		dataSetTemp <- dataset[(dataset[ncol(dataset)] >= lineHourBegin & dataset[ncol(dataset)] <= lineHourEnd),1:(length(dataset))] #filtering specific to this corretora.	
}
	
	
pdf(
	paper="a4r",
	width=16, 
	height=9,
	paste(myDirOut, 'plotSAR_', projectName, '_',serverConfig[4,2],'-',j,'.pdf' , sep="")
	);
	
	par(mar = c(5,7,4,2) + 0.1)

for (i in temp) {
	

			dataset[i] <- as.numeric(as.character(dataset[[i]]))
			dataset <- dataset[!is.na(dataset[i]),1:(length(dataset))]
			description <- subset(infoDataFrame[2], infoDataFrame$Contador == i,ignore.case=T)
			x <- as.numeric(as.character(dataset[[i]]))
			x <- x[!is.na(x)]
			y1 <- 1
			y2 <- sampleGroup
			z_num <- trunc(length(x)/sampleGroup)
			z <-0
			z_time <- "0"
			z_sd1 <- 0
			z_sd2 <- 0
			
			if (sampleGroup > 1){
			for (ii in 1:z_num)
			{
				z[ii] <- mean(x[y1:y2])
				z_sd1[ii] <- z[ii]+sd(x[y1:y2])
				z_sd2[ii] <- z[ii]-sd(x[y1:y2])
				z_time[ii] <- paste(dataset$TIME[y2])
				y1 <- y1+sampleGroup
				y2 <- y2+sampleGroup
			}
			}else{
				for (ii in 1:z_num)
				{
				z[ii] <- mean(x[y1:y2])
				z_time[ii] <- paste(dataset$TIME[y2])
				y1 <- y1+sampleGroup
				y2 <- y2+sampleGroup
			}}
			
				
			
			# z <- z[!is.na(z)]
		if (min(z) < 0){
					
				plot(
					z,
					xaxt="n",
					ylim=range(min(0,z_sd2):max(100,max(z_sd1,z))),
					# ylim=range(min(0,min(z_sd1)):max(100,max(z_sd1,z))),
					ylab="",
					xlab="", 
					type="l",
					main=paste('Consumo - ', colnames(dataset[i]),' (sampleGroup 1:',sampleGroup,')',  sep=""), 
					lwd=1.5,
					las=1,
					xaxp=c(0, round(length(z)), 20),
					panel.first=grid(), 
					cex.axis=0.8, 
					las=2, 
					col="Blue",
					# sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(serverConfig[3,2]/1024,0),big.mark = ".")),
					sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
					cex.sub = 0.6, font.sub = 3, col.sub = 132
					)
			}else{
					plot(
					z,
					xaxt="n",
					ylim=range(min(0,z):max(100,max(z_sd1,z))),
					# ylim=range(min(0,min(z_sd1)):max(100,max(z_sd1,z))),
					ylab="",
					xlab="", 
					type="l",
					main=paste('Consumo - ', colnames(dataset[i]),' (sampleGroup 1:',sampleGroup,')',  sep=""), 
					lwd=1.5,
					las=1,
					xaxp=c(0, round(length(z)), 20),
					panel.first=grid(), 
					cex.axis=0.8, 
					las=2, 
					col="Blue",
					# sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(serverConfig[3,2]/1024,0),big.mark = ".")),
					sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
					cex.sub = 0.6, font.sub = 3, col.sub = 132
					)
			}
			
			#Incio - add em 31/01/2012
			if (flagHour == TRUE)
			{
				abline (
					v=plotHourBegin, 
					col="purple"
					)
				
				#Fim add em 31/01/2012
				abline (
					v=plotHourEnd, 
					col="purple"
					)
			}
								
			lines(
					z_sd1,
					type="l", 
					lwd=2.5, 
					lty=3, 
					col=rgb(255,0,0,80,maxColorValue=255),
					cex=3,
					pch=20
				)
			
			lines(
					z_sd2,
					type="l", 
					lwd=2.5, 
					lty=3, 
					col=rgb(255,0,0,80,maxColorValue=255),
					cex=3, 
					pch=20
				)
			
			axis(
				1, 
				las=1, 
				at=1:length(z_time), 
				FALSE, 
				lab = c(paste(z_time)), 
				cex.axis=.6
				)
				
			title(
				ylab = colnames(dataset[i]), 
				line = 3.5
				)
				
			title(
				xlab = "Horario", 
				line = 2.6
				)
		
			
			if (flagHour == TRUE)
			{
				legend(
						"topright",
							c(
								paste("*Average= ",format(round(mean(dataSetTemp[[i]]),2),big.mark = ",")),
								paste('*Standard Deviation= ',format(round(sd(dataSetTemp[[i]]),2),big.mark = ",")),
								paste('*Coefficient Variation(%)= ',format(round(sd(dataSetTemp[[i]])/mean(dataSetTemp[[i]])*100,2),big.mark = ",")),
								paste('*Max=',format(round(max(dataSetTemp[[i]]),1),big.mark = ",")),
								paste('*Min=',format(round(min(dataSetTemp[[i]]),1),big.mark = ",")),
								paste('*Percentil(95%)= ',format(round(quantile (as.numeric(dataSetTemp[[i]]),0.95),0),big.mark = ",")),
								paste('*Percentil(99%)= ',format(round(quantile (as.numeric(dataSetTemp[[i]]),0.99),0),big.mark = ","))
							),
						text.col=c("blue","red","red","gray","gray","gray","gray"),
						lwd=c(2,1.5),
						cex=.7,
						col=c("blue","red","red","white","white","white","white"), 
						lty=c(1,4,0,0), 
						bty=c("n","n","n","n"), 
						pch=c('','','','')
					)
			}else{	
				legend(
							"topright",
								c(
									paste("Average= ",format(round(mean(dataset[[i]]),2),big.mark = ",")),
									paste('Standard Deviation= ',format(round(sd(dataset[[i]]),2),big.mark = ",")),
									paste('Coefficient Variation(%)= ',format(round(sd(dataset[[i]])/mean(dataset[[i]])*100,2),big.mark = ",")),
									paste('Max=',format(round(max(dataset[[i]]),1),big.mark = ",")),
									paste('Min=',format(round(min(dataset[[i]]),1),big.mark = ",")),
									paste('Percentil(95%)= ',format(round(quantile (as.numeric(dataset[[i]]),0.95),0),big.mark = ",")),
									paste('Percentil(99%)= ',format(round(quantile (as.numeric(dataset[[i]]),0.99),0),big.mark = ","))
								),
							text.col=c("blue","red","red","gray","gray","gray","gray"),
							lwd=c(2,1.5),
							cex=.7,
							col=c("blue","red","red","white","white","white","white"), 
							lty=c(1,4,0,0), 
							bty=c("n","n","n","n"), 
							pch=c('','','','')
						)
				}
			mtext (paste(description[1,1]),cex=.6,col="deepskyblue2",)
			
			count <- count+1
			}
		dev.off()			
	}

chart2 <- function (devices,contador,sampleGroup) {

infoDataFrame <- as.data.frame(colnames(contador))
colnames(infoDataFrame)[1] <- "Contador"
infoDataFrame <- merge(counterInfo, infoDataFrame, by="Contador", all.y=TRUE)[-2]
infoDataFrame <- infoDataFrame[!is.na(infoDataFrame$Desc),1:(length(infoDataFrame))]

pdf(
	paper="a4r",
	width=16, 
	height=9,
	paste(myDirOut, 'plotSAR_', projectName, '_',serverConfig[4,2],'-',j,'.pdf' , sep="")
	);
	
	par(mar = c(5,7,4,2) + 0.1)


for (dev in devices){
					dataset <- subset (contador[-2], contador[2] == dev)
					colnames (dataset)[1] <- paste("TIME - ",dev)
					y <- colnames(dataset)
					y <- sub("/s", "_per_second",y, fixed = F, ignore.case=T)
					colnames (dataset) <- y
					temp <- y[-1]
					
					lineHourBegin <- which(dataset[1] == hourBegin)
					plotHourBegin <- round(lineHourBegin/sampleGroup,0)

					lineHourEnd <- which(dataset[1] == hourEnd)
					plotHourEnd <- round(lineHourEnd/sampleGroup,0)		

					if (flagHour == TRUE)
						{
							dataset[ncol(dataset)+1] <- c (1:nrow(dataset))
							dataSetTemp <- dataset[(dataset[ncol(dataset)] >= lineHourBegin & dataset[ncol(dataset)] <= lineHourEnd),1:(length(dataset))] #filtering specific to this corretora.	
						}

count <- 1
for (i in temp) {
			dataset[i] <- as.numeric(as.character(dataset[[i]]))
			dataset <- dataset[!is.na(dataset[i]),1:(length(dataset))]
			description <- subset(infoDataFrame[2], infoDataFrame$Contador == i)
			x <- as.numeric(as.character(dataset[[i]]))
			y1 <- 1
			y2 <- sampleGroup
			z_num <- trunc(length(x)/sampleGroup)
			z <-0
			z_time <- "0"
			z_sd1 <- 0
			z_sd2 <- 0
						
			if (sampleGroup > 1){
			for (ii in 1:z_num)
			{
				z[ii] <- mean(x[y1:y2])
				z_sd1[ii] <- z[ii]+sd(x[y1:y2])
				z_sd2[ii] <- z[ii]-sd(x[y1:y2])
				z_time[ii] <- paste(dataset$TIME[y2])
				y1 <- y1+sampleGroup
				y2 <- y2+sampleGroup
			}
			}else{
				for (ii in 1:z_num)
				{
				z[ii] <- mean(x[y1:y2])
				z_time[ii] <- paste(dataset$TIME[y2])
				y1 <- y1+sampleGroup
				y2 <- y2+sampleGroup
			}}
					
			
			if (min(z) < 0){
					
				plot(
					z,
					xaxt="n",
					ylim=range(min(0,z_sd2):max(100,max(z_sd1,z))),
					# ylim=range(min(0,min(z_sd1)):max(100,max(z_sd1,z))),
					ylab="",
					xlab="", 
					type="l",
					main=paste('Consumo - ', colnames(dataset[i]),' (Scale 1:',sampleGroup,')',  sep=""), 
					lwd=1.5,
					las=1,
					xaxp=c(0, round(length(z)), 20),
					panel.first=grid(), 
					cex.axis=0.8, 
					las=2, 
					col="Blue",
					# sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(serverConfig[3,2]/1024,0),big.mark = ".")),
					sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
					cex.sub = 0.6, font.sub = 3, col.sub = 132
					)
			}else{
					plot(
					z,
					xaxt="n",
					ylim=range(min(0,z):max(100,max(z_sd1,z))),
					# ylim=range(min(0,min(z_sd1)):max(100,max(z_sd1,z))),
					ylab="",
					xlab="", 
					type="l",
					main=paste('Consumo - ', colnames(dataset[i]),' (Scale 1:',sampleGroup,')',  sep=""), 
					lwd=1.5,
					las=1,
					xaxp=c(0, round(length(z)), 20),
					panel.first=grid(), 
					cex.axis=0.8, 
					las=2, 
					col="Blue",
					# sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(serverConfig[3,2]/1024,0),big.mark = ".")),
					sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
					cex.sub = 0.6, font.sub = 3, col.sub = 132
					)
			}

			#add em 20/03/2013
			if (flagHour == TRUE)
				{
					# Incio - add em 31/01/2013
					abline (
						v=plotHourBegin, 
						col="purple"
						)
						
					# Fim add em 31/01/2013
					abline (
						v=plotHourEnd, 
						col="purple"
							)
				}	
			lines(
					z_sd1,
					type="l", 
					lwd=1.5, 
					lty=3, 
					col=rgb(255,0,0,70,maxColorValue=255),
					cex=3, 
					pch=20
				)
				
			#lines(
			#		z_sd2,
			#		type="l", 
			#		lwd=1.5, 
			#		lty=3, 
			#		col=rgb(255,0,0,70,maxColorValue=255),
			#		cex=3, 
			#		pch=20
			#	)
			
			#lines(
			#		0,
			#		type="l", 
			#		lwd=1, 
			#		lty=3, 
			#		col=rgb(255,0,0,20,maxColorValue=255),
			#		cex=3, 
			#		pch=20
			#	)
				
			axis(
				1, 
				las=1, 
				at=1:length(z_time), 
				FALSE, 
				lab = c(paste(z_time)), 
				cex.axis=.6
				)
				
				# title(
				# ylab = colnames(dataset[i]), 
				# line = 3.5
				# )

			title(
				ylab = paste (colnames(dataset[i]),' - ',name,': ',dev), 
				line = 3.5
				)
				
			title(
				xlab = "Horario", 
				line = 3.6
				)
		
				if (flagHour == TRUE)
			{
				legend(
						"topright",
							c(
								paste("*Average= ",format(round(mean(as.numeric(dataSetTemp[[i]])),2),big.mark = ",")),
								paste('*Standard Deviation= ',format(round(sd(as.numeric(dataSetTemp[[i]])),2),big.mark = ",")),
								paste('*Coefficient Variation(%)= ',format(round(sd(as.numeric(dataSetTemp[[i]]))/mean((as.numeric(dataSetTemp[[i]])))*100,2),big.mark = ",")),
								paste('*Max=',format(round(max(as.numeric(dataSetTemp[[i]])),1),big.mark = ",")),
								paste('*Min=',format(round(min(as.numeric(dataSetTemp[[i]])),1),big.mark = ",")),
								paste('*Percentil(95%)= ',format(round(quantile (as.numeric(as.numeric(dataSetTemp[[i]])),0.95),0),big.mark = ",")),
								paste('*Percentil(99%)= ',format(round(quantile (as.numeric(as.numeric(dataSetTemp[[i]])),0.99),0),big.mark = ","))
							),
						text.col=c("blue","red","red","gray","gray","gray","gray"),
						lwd=c(2,1.5),
						cex=.7,
						col=c("blue","red","red","white","white","white","white"), 
						lty=c(1,4,0,0), 
						bty=c("n","n","n","n"), 
						pch=c('','','','')
					)
			}else{	
				legend(
							"topright",
									
								c(
									paste("Average= ",format(round(mean(dataset[[i]]),2),big.mark = ",")),
									paste('Standard Deviation= ',format(round(sd(dataset[[i]]),2),big.mark = ",")),
									paste('Coefficient Variation(%)= ',format(round(sd(dataset[[i]])/mean(dataset[[i]])*100,2),big.mark = ",")),
									paste('Max=',format(round(max(dataset[[i]]),1),big.mark = ",")),
									paste('Min=',format(round(min(dataset[[i]]),1),big.mark = ",")),
									paste('Percentil(95%)= ',format(round(quantile (as.numeric(dataset[[i]]),0.95),0),big.mark = ",")),
									paste('Percentil(99%)= ',format(round(quantile (as.numeric(dataset[[i]]),0.99),0),big.mark = ","))
								),
						text.col=c("blue","red","red","gray","gray","gray","gray"),
						lwd=c(2,1.5),
						cex=.7,
						col=c("blue","red","red","white","white","white","white"), 
						lty=c(1,4,0,0), 
						bty=c("n","n","n","n"), 
						pch=c('','','','')
						)
				}
			mtext (paste(description[1,1]),cex=.6,col="deepskyblue2",)
			count <- count+1
			}
		}
		dev.off()
		}

warning(paste("Gerando: Tamanho Fila (1 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetQueueLoadAverage')){
################################################################################################################################
#dataSetQueueLoadAverage_PDF_Charts
################################################################################################################################

y <- colnames(dataSetQueueLoadAverage)
j <- 'QueueLoadAverage'
print (j)
temp <- y[-1]


dataset <- as.data.frame(dataSetQueueLoadAverage)
y <- colnames(dataset)
y <- sub("/s", "_per_sec", y, fixed = F, ignore.case=T)
y <- sub("%", "", y, fixed = F, ignore.case=T)
colnames (dataset) <- y
temp <- y[-1]
count <- 1

warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
chart(temp,dataset,sampleGroup)
}

if (exists('physicalMemoryBytesUsed')){
	################################################################################################################################
	#dataSetMemoryUtilization_PDF_Charts
	################################################################################################################################

	physicalMemoryBytesUsed[2] <- physicalMemoryBytesUsed[2]/1024
	colnames(physicalMemoryBytesUsed)[2] <- "PhysicalmemoryMBytesUsed"
	dataSetMemoryUtilization$indice2 <- c(1:(nrow (dataSetMemoryUtilization)))
	temp <- merge(dataSetMemoryUtilization, physicalMemoryBytesUsed,by="TIME",all.y=TRUE)
	temp <- temp[order(temp$indice2) , ]
	temp <- temp [,-11]
	dataSetMemoryUtilization <- temp[!is.na(temp[2]),1:(length(temp))]
	
}

if (exists('dataSetMemoryUtilization')){
	y <- colnames (dataSetMemoryUtilization)
	
	#Converter KB to MB
	loc_kb <- grep ("kb", y, fixed = F, ignore.case=T)
	for (i in loc_kb) {
		colnames(dataSetMemoryUtilization)[i] <- sub("kb","mb",colnames(dataSetMemoryUtilization[i]))
		dataSetMemoryUtilization[i] <- as.numeric(as.character(dataSetMemoryUtilization[[i]]))
		dataSetMemoryUtilization[[i]] <- dataSetMemoryUtilization[[i]]/1024
	}

	y <- colnames (dataSetMemoryUtilization)

	loc_percent <- grep ("%", y, fixed = F, ignore.case=T)

	for (i in loc_percent) {
		colnames(dataSetMemoryUtilization)[i] <- sub("%","utilization(%)_",colnames(dataSetMemoryUtilization[i]))
	}

	j <- 'MemoryUtilization'
	print (j)
	temp <- y[-1]

	dataset <- as.data.frame(dataSetMemoryUtilization)
	y <- colnames(dataset)

	colnames (dataset) <- y
	temp <- y[-1]
	temp <- temp[-5]

	count <- 1
	warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
	chart(temp,dataset,sampleGroup)
}

warning(paste("Gerando: Paginacao Memoria (3 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetMemoryPaging')){
################################################################################################################################
#dataSetMemoryPaging_PDF_Charts
################################################################################################################################
y <- colnames(dataSetMemoryPaging)
j <- 'MemoryPaging'
print (j)
temp <- y[-1]
	
dataset <- as.data.frame(dataSetMemoryPaging)
y <- colnames(dataset)
y <- sub("/s", "_per_second", y, fixed = F, ignore.case=T)
y <- sub("%", "", y, fixed = F, ignore.case=T)
colnames (dataset) <- y
temp <- y[-1]
count <- 1

warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)

chart(temp,dataset,sampleGroup)

}

warning(paste("Gerando: Consumo Interfaces de Rede (4 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetEthernetInterfaces')){
################################################################################################################################
#dataSetEthernetInterfaces_PDF_Charts
################################################################################################################################

devices <- aggregate(dataSetEthernetInterfaces$IFACE, list(dataSetEthernetInterfaces$IFACE),length)
devices <- as.vector(devices$Group.1)
devices <- read.table(textConnection(devices), na.strings = "IFACE")
devices <- devices[!is.na(devices)]

y <- colnames(dataSetEthernetInterfaces)

#Converter KB to MB
loc_seconds <- grep ("/s", y, fixed = F, ignore.case=T)
for (i in loc_seconds) {
					colnames(dataSetEthernetInterfaces)[i] <- sub("/s","_per_second",colnames(dataSetEthernetInterfaces[i]))
					}

					
	
					
loc_bytes <- grep ("byt", y, fixed = F, ignore.case=T)
for (i in loc_bytes) {			
					colnames(dataSetEthernetInterfaces)[i] <- sub("byt","KB",colnames(dataSetEthernetInterfaces[i]))
					dataSetEthernetInterfaces[i] <- as.numeric(as.character(dataSetEthernetInterfaces[[i]]))
					dataSetEthernetInterfaces[[i]] <- dataSetEthernetInterfaces[[i]]/1024
					}



j <- 'EthernetInterfaces'
print (j)



name <- colnames(dataSetEthernetInterfaces[2])


# plotHourBegin <- which(dataSetEthernetInterfaces[1] == hourBegin)
# plotHourBegin <- round(plotHourBegin/sampleGroup,0)

# plotHourEnd <- which(dataSetEthernetInterfaces[1] == hourEnd)
# plotHourEnd <- round(plotHourEnd/sampleGroup,0)		
warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
chart2(devices,dataSetEthernetInterfaces,sampleGroup)
}

warning(paste("Gerando: Paginacao Disco (5 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetDiskPaging')){
################################################################################################################################
#DiskPaging_PDF_Charts
################################################################################################################################
y <- colnames(dataSetDiskPaging)
j <- 'DiskPaging'
print (j)
temp <- y[-1]

dataset <- as.data.frame(dataSetDiskPaging)
y <- colnames(dataset)
y <- sub("/s", "_per_second", y, fixed = F, ignore.case=T)
y <- sub("%", "", y, fixed = F, ignore.case=T)
colnames (dataset) <- y
temp <- y[-1]
count <- 1
warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)

chart(temp,dataset,sampleGroup)

}

warning(paste("Gerando: I/O Discos (6 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetDiskIO')){

################################
#DiskIO_PDF_Charts
################################
y <- colnames(dataSetDiskIO)
j <- 'DiskIO'
print (j)
temp <- y[-1]
			
dataset <- as.data.frame(dataSetDiskIO)
y <- colnames(dataset)
y <- sub("/s", "_per_second", y, fixed = F, ignore.case=T)
y <- sub("%", "", y, fixed = F, ignore.case=T)
colnames (dataset) <- y
temp <- y[-1]
count <- 1
warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)

chart(temp,dataset,sampleGroup)

}


warning(paste("Gerando: Consumo por CPU (7 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetCpuUnits')){
################################
#dataSetCpuUnits_PDF_Charts
################################
devices <- aggregate(dataSetCpuUnits$CPU, list(dataSetCpuUnits$CPU),length)
devices <- as.vector(devices$Group.1)
devices <- read.table(textConnection(devices), na.strings = "CPU")
devices <- devices[!is.na(devices)]

y <- colnames(dataSetCpuUnits)

loc_percent <- grep ("%", y, fixed = F, ignore.case=T)
for (i in loc_percent) {
					colnames(dataSetCpuUnits)[i] <- sub("%","utilization(%)_",colnames(dataSetCpuUnits[i]))
					}

j <- 'CpuUnits'
print (j)

name <- colnames(dataSetCpuUnits[2])
warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)

chart2(devices,dataSetCpuUnits,sampleGroup)

}


warning(paste("Gerando: Consumo Geral CPU (8 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
	if (exists('dataSetCpuAll')){
	################################
	#dataSetCpuAll_PDF_Charts
	################################
	y <- colnames(dataSetCpuAll)
	j <- 'CpuAll'
	print (j)

	loc_percent <- grep ("%", y, fixed = F, ignore.case=T)

	for (i in loc_percent) {
						colnames(dataSetCpuAll)[i] <- sub("%","utilization(%)_",colnames(dataSetCpuAll[i]))
						}

					
	

	dataset <- as.data.frame(dataSetCpuAll)
	y <- colnames(dataset)

	temp <- y[-1][-1]

	count <- 1
warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
	chart(temp,dataset,sampleGroup)

	}

	
warning(paste("Gerando: Atividade Disco (9 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetDeviceActivity')){	
################################
#dataSetDeviceActivity_PDF_Charts
################################
devices <- aggregate(dataSetDeviceActivity$DEV, list(dataSetDeviceActivity$DEV),length)
devices <- as.vector(devices$Group.1)
devices <- read.table(textConnection(devices), na.strings = "DEV")
devices <- devices[!is.na(devices)]

y <- colnames(dataSetDeviceActivity)

#Converter KB to MB
loc_seconds <- grep ("/s", y, fixed = F, ignore.case=T)
for (i in loc_seconds) {
					colnames(dataSetDeviceActivity)[i] <- sub("/s","_per_second",colnames(dataSetDeviceActivity[i]))
					}

					
for (i in 3:length(colnames(dataSetDeviceActivity))) {
					colnames(dataSetDeviceActivity)[i] <- sub("","DEV_",colnames(dataSetDeviceActivity[i]))
					}


loc_percent <- grep ("%", y, fixed = F, ignore.case=T)
for (i in loc_percent) {
					colnames(dataSetDeviceActivity)[i] <- sub("%","utilization(%)_",colnames(dataSetDeviceActivity[i]))
					}

y <- sub("%","utilization(%)_",y, fixed = F, ignore.case=T)
				
j <- 'DeviceActivity'

print (j)

name <- colnames(dataSetDeviceActivity[2])
chart2(devices,dataSetDeviceActivity,sampleGroup)

}

warning(paste("Gerando: Troca de Contexto Processador  (10 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('dataSetContextSwitches')){	
################################
#dataSetCpuAll_PDF_Charts
################################
y <- colnames(dataSetContextSwitches)
j <- 'ContextSwitches'
print (j)

loc_percent <- grep ("%", y, fixed = F, ignore.case=T)

for (i in loc_percent) {
					colnames(dataSetContextSwitches)[i] <- sub("%","utilization(%)_",colnames(dataSetContextSwitches[i]))
					}

				
temp <- y[-1]
temp <- y[-1]

dataset <- as.data.frame(dataSetContextSwitches)
y <- colnames(dataset)


temp <- y[-1]
temp <- temp[-1]
count <- 1
warning(paste(serverConfig[4,2],"-CREATING PDF REPORT: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
chart(temp,dataset,sampleGroup)

}


warning(paste("Gerando: Processos Monitorados  (11 de 11)",' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
if (exists('processFileNames')){	
################################
#PROCESS
################################

for (j in processFileNames){
	
	print (j)
	warning(paste(serverConfig[4,2],"-CREATING PDF REPORT - Process: ",j,' [Memory: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
	
	myFileProcess <- paste (myDirOut,j[1],sep="")
	processName <- as.character(strsplit(substring(j,10),".csv"))
	dataSetProcess <- read.csv(myFileProcess, sep=';', header=TRUE, fill=T, check.names=F)
		
	dataSetProcess$VIRT <-  gsub("m", "", dataSetProcess$VIRT)
	dataSetProcess$RES <-  gsub("m", "", dataSetProcess$RES)
	dataSetProcess$SHR <-  gsub("m", "", dataSetProcess$SHR)
	
	#procura t de "teras" e converte em megas, se não achar procura g de gigas e converte em megas
	
	tb <- grep ("t", dataSetProcess$VIRT, ignore.case=T) #Processador
	if (length(tb) > 0) {
		dataSetProcess$VIRT <-  gsub("t", "", dataSetProcess$VIRT)
		for (i in tb) {
			dataSetProcess[i,4] <- as.numeric(dataSetProcess[i,4])*1024*1024
		};
	} else {
		gb <- grep ("g", dataSetProcess$VIRT, ignore.case=T) #Processador
		if (length(gb) > 0) {
			dataSetProcess$VIRT <-  gsub("g", "", dataSetProcess$VIRT)
			for (i in gb) {
				dataSetProcess[i,4] <- as.numeric(dataSetProcess[i,4])*1024
			};
		}
	}

	
	tb <- grep ("t", dataSetProcess$RES, ignore.case=T)
	if (length(tb) > 0) {
		dataSetProcess$RES <-  gsub("t", "", dataSetProcess$RES)
		for (i in tb) {
			dataSetProcess[i,5] <- as.numeric(dataSetProcess[i,5])*1024*1024
		};
	} else {
		gb <- grep ("g", dataSetProcess$RES, ignore.case=T) #Processador
		if (length(gb) > 0) {
			dataSetProcess$RES <-  gsub("g", "", dataSetProcess$RES)
			for (i in gb) {
				dataSetProcess[i,5] <- as.numeric(dataSetProcess[i,5])*1024
			};
		}
	}
	
	tb <- grep ("t", dataSetProcess$SHR, ignore.case=T)
	if (length(tb) > 0) {
		dataSetProcess$SHR <-  gsub("t", "", dataSetProcess$SHR)
		for (i in tb) {
			dataSetProcess[i,6] <- as.numeric(dataSetProcess[i,6])*1024*1024
		};
	} else {
		gb <- grep ("g", dataSetProcess$SHR, ignore.case=T) #Processador
		if (length(gb) > 0) {
			dataSetProcess$SHR <-  gsub("g", "", dataSetProcess$SHR)
			for (i in gb) {
				dataSetProcess[i,6] <- as.numeric(dataSetProcess[i,6])*1024
			};
		}
	}

	colnames(dataSetProcess)[1] <- "TIME"
	colnames(dataSetProcess)[2] <- "Priority"
	colnames(dataSetProcess)[3] <- "Nice_Value"
	colnames(dataSetProcess)[4] <- "Virtual_Image_mb"
	colnames(dataSetProcess)[5] <- "Resident_Size_mb"
	colnames(dataSetProcess)[6] <- "Shared_Mem_Size_mb"
	colnames(dataSetProcess)[7] <- "CPU_Usage"
	colnames(dataSetProcess)[8] <- "Memory_Usage"
	colnames(dataSetProcess)[9] <- "CPU_Time"


	tryCatch(
	{
	
		lineHourBegin <- which(dataSetProcess[1] == hourBegin)
		plotHourBegin <- round(lineHourBegin/sampleGroup,0)
		lineHourEnd <- which(dataSetProcess[1] == hourEnd)
		plotHourEnd <- round(lineHourEnd/sampleGroup,0)
	
		if (flagHour == TRUE){
				dataSetProcess[ncol(dataSetProcess)+1] <- c (1:nrow(dataSetProcess))
				dataSetTemp <- dataSetProcess[(dataSetProcess[ncol(dataSetProcess)] >= lineHourBegin & dataSetProcess[ncol(dataSetProcess)] <= lineHourEnd),1:(length(dataSetProcess))] #filtering specific to this corretora.	
		}
	


		
		pdf(
			paper="a4r",
			width=16, 
			height=9,
			paste(myDirOut, 'plotSAR_', projectName, '_',serverConfig[4,2],'-',j,'.pdf' , sep="")
			);
			
		par(mar = c(5,7,4,2) + 0.1)

		
		
		
		
		
	infoDataFrame <- as.data.frame(colnames(dataSetProcess))
	
	
	
	colnames(infoDataFrame)[1] <- "Contador"
	infoDataFrame <- merge(counterInfo, infoDataFrame, by="Contador", all.y=TRUE)[-2]
	infoDataFrame <- infoDataFrame[!is.na(infoDataFrame$Desc),1:(length(infoDataFrame))]	
	dataSetProcess <- dataSetProcess[-2][-2][-7][-7]
	temp <- colnames(dataSetProcess[-1])
	
		
	for (i in temp) {
				dataSetProcess[i] <- as.numeric(as.character(dataSetProcess[[i]]))
				dataSetProcess <- dataSetProcess[!is.na(dataSetProcess[i]),1:(length(dataSetProcess))]
				description <- subset(infoDataFrame[2], infoDataFrame$Contador == i)
				x <- as.numeric(as.character(dataSetProcess[[i]]))
				x <- x[!is.na(x)]
				y1 <- 1
				y2 <- sampleGroup
				z_num <- trunc(length(x)/sampleGroup)
				z <-0
				z_time <- "0"
				z_sd1 <- 0
				z_sd2 <- 0
				
				if (sampleGroup > 1){
				for (ii in 1:z_num)
				{
					z[ii] <- mean(x[y1:y2])
					z_sd1[ii] <- z[ii]+sd(x[y1:y2])
					z_sd2[ii] <- z[ii]-sd(x[y1:y2])
					z_time[ii] <- paste(dataSetProcess$TIME[y2])
					y1 <- y1+sampleGroup
					y2 <- y2+sampleGroup
				}
				}else{
					for (ii in 1:z_num)
					{
					z[ii] <- mean(x[y1:y2])
					z_time[ii] <- paste(dataSetProcess$TIME[y2])
					y1 <- y1+sampleGroup
					y2 <- y2+sampleGroup
				}}
				
					
				
				z <- z[!is.na(z)]
			if (min(z) < 0){
						
					plot(
						z,
						xaxt="n",
						ylim=range(min(0,z_sd2):max(100,max(z_sd1,z))),
						# ylim=range(min(0,min(z_sd1)):max(100,max(z_sd1,z))),
						ylab="",
						xlab="", 
						type="l",
						
						main=paste(processName,' ->', colnames(dataSetProcess[i]),' (sampleGroup 1:',sampleGroup,')',  sep=""), 
						lwd=1.5,
						las=1,
						xaxp=c(0, round(length(z)), 20),
						panel.first=grid(), 
						cex.axis=0.8, 
						las=2, 
						col="Blue",
						# sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(serverConfig[3,2]/1024,0),big.mark = ".")),
						sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
						cex.sub = 0.6, font.sub = 3, col.sub = 132
						)
				}else{
				
#				warning(paste("-debug:",z_sd1,sep=""),immediate.= T)

						plot(
						z,
						xaxt="n",
						ylim=range(min(0,z):max(100,max(z_sd1,z))),
						# ylim=range(min(0,min(z_sd1)):max(100,max(z_sd1,z))),
						ylab="",
						xlab="", 
						type="l",
						main=paste(processName,' -> ', colnames(dataSetProcess[i]),' (sampleGroup 1:',sampleGroup,')',  sep=""), 
						lwd=1.5,
						las=1,
						xaxp=c(0, round(length(z)), 20),
						panel.first=grid(), 
						cex.axis=0.8, 
						las=2, 
						col="Blue",
						# sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(serverConfig[3,2]/1024,0),big.mark = ".")),
						sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
						cex.sub = 0.6, font.sub = 3, col.sub = 132
						)
				}
				
				#Incio - add em 31/01/2012
				if (flagHour == TRUE)
				{
					abline (
						v=plotHourBegin, 
						col="purple"
						)
					
					#Fim add em 31/01/2012
					abline (
						v=plotHourEnd, 
						col="purple"
						)
				}
									
				lines(
						z_sd1,
						type="l", 
						lwd=2.5, 
						lty=3, 
						col=rgb(255,0,0,80,maxColorValue=255),
						cex=3,
						pch=20
					)
				
				lines(
						z_sd2,
						type="l", 
						lwd=2.5, 
						lty=3, 
						col=rgb(255,0,0,80,maxColorValue=255),
						cex=3, 
						pch=20
					)
				
				axis(
					1, 
					las=1, 
					at=1:length(z_time), 
					FALSE, 
					lab = c(paste(z_time)), 
					cex.axis=.6
					)
					
				title(
					ylab = colnames(dataSetProcess[i]), 
					line = 3.5
					)
					
				title(
					xlab = "Horario", 
					line = 2.6
					)
			
				
				if (flagHour == TRUE)
				{
					legend(
							"topright",
								c(
									paste("*Average= ",format(round(mean(as.numeric(dataSetTemp[[i]])),2),big.mark = ",")),
									paste('*Standard Deviation= ',format(round(sd(as.numeric(dataSetTemp[[i]])),2),big.mark = ",")),
									paste('*Coefficient Variation(%)= ',format(round(sd(as.numeric(dataSetTemp[[i]]))/mean(dataSetTemp[[i]])*100,2),big.mark = ",")),
									paste('*Max=',format(round(max(as.numeric(dataSetTemp[[i]])),1),big.mark = ",")),
									paste('*Min=',format(round(min(as.numeric(dataSetTemp[[i]])),1),big.mark = ",")),
									paste('*Percentil(95%)= ',format(round(quantile (as.numeric(dataSetTemp[[i]]),0.95),0),big.mark = ",")),
									paste('*Percentil(99%)= ',format(round(quantile (as.numeric(dataSetTemp[[i]]),0.99),0),big.mark = ","))
								),
							text.col=c("blue","red","red","gray","gray","gray","gray"),
							lwd=c(2,1.5),
							cex=.7,
							col=c("blue","red","red","white","white","white","white"), 
							lty=c(1,4,0,0), 
							bty=c("n","n","n","n"), 
							pch=c('','','','')
						)
				}else{	
					legend(
								"topright",
									c(
										paste("Average= ",format(round(mean(as.numeric(dataSetProcess[[i]])),2),big.mark = ",")),
										paste('Standard Deviation= ',format(round(sd(as.numeric(dataSetProcess[[i]])),2),big.mark = ",")),
										paste('Coefficient Variation(%)= ',format(round(sd(as.numeric(dataSetProcess[[i]]))/mean(dataSetProcess[[i]])*100,2),big.mark = ",")),
										paste('Max=',format(round(max(as.numeric(dataSetProcess[[i]])),1),big.mark = ",")),
										paste('Min=',format(round(min(as.numeric(dataSetProcess[[i]])),1),big.mark = ",")),
										paste('Percentil(95%)= ',format(round(quantile (as.numeric(dataSetProcess[[i]]),0.95),0),big.mark = ",")),
										paste('Percentil(99%)= ',format(round(quantile (as.numeric(dataSetProcess[[i]]),0.99),0),big.mark = ","))
									),
								text.col=c("blue","red","red","gray","gray","gray","gray"),
								lwd=c(2,1.5),
								cex=.7,
								col=c("blue","red","red","white","white","white","white"), 
								lty=c(1,4,0,0), 
								bty=c("n","n","n","n"), 
								pch=c('','','','')
							)
					}
				mtext (paste(description[1,1]),cex=.6,col="deepskyblue2",)
				
				# GRAFICO AGRUPADO DE MEMORIA
				}
			
	

	
			
			
				plot(
						dataSetProcess[[2]],
						xaxt="n",
						ylim=range(min(0,dataSetProcess[[2]],dataSetProcess[[3]],dataSetProcess[[4]]):max(100,max(dataSetProcess[[2]],dataSetProcess[[3]],dataSetProcess[[4]]))),
						ylab="",
						xlab="", 
						type="l",
						main= paste('Process: ',processName, ' | MEMORY USAGE (TOP command)',  sep=""), 
						lwd=2,
						las=1,
						xaxp=c(0, round(length(dataSetProcess[[2]])), 20),
						panel.first=grid(), 
						cex.axis=0.8, 
						las=2, 
						col="forestgreen",
						sub = paste("Host:",serverConfig[4,2],"Config:",serverConfig[1,1],serverConfig[1,2],';',serverConfig[2,1],serverConfig[2,2],'; Memoria_MB',format(round(as.numeric(as.character(serverConfig[[3,2]]))/1024,0),big.mark = ".")),
						cex.sub = 0.6, font.sub = 3, col.sub = 132
					)
				

			
				if (flagHour == TRUE)
				{
					abline (
						v=lineHourBegin, 
						col="purple"
						)
					
					#Fim add em 31/01/2012
					abline (
						v=lineHourEnd, 
						col="purple"
						)
				}
				
				
				
				lines(
						dataSetProcess[[3]],
						type="l", 
						lwd=2, 
						col="firebrick1",
					)
				
				lines(
						dataSetProcess[[4]],
						type="l", 
						lwd=2, 
						col="turquoise2",
					)


					
				title(
						ylab = colnames(dataSetProcess[i]), 
						line = 3.5
					)
					
				title(
						xlab = "Horario", 
						line = 2.6
					)


					
				legend(
							"topright",
								c(
									paste("VIRTUAL - Avg:",format(round(mean(as.numeric(dataSetProcess[[2]])),2),big.mark = ",")),
									paste("RESIDENT - Avg:",format(round(mean(as.numeric(dataSetProcess[[3]])),2),big.mark = ",")),
									paste("SHARED - Avg:", format(round(mean(as.numeric(dataSetProcess[[4]])),2),big.mark = ","))
								),
								text.col=c("forestgreen","firebrick1","turquoise2"),
								lwd=c(2,2,2),
								cex=.7,
								col=c("forestgreen","firebrick1","turquoise2"), 
								# lty=c(1,4,0,0), 
								bty=c("n","n","n"), 
								pch=c('','','')
							)
							

						
			dev.off()			
			
} ,error=c)
	}

}

}
warning(paste("SAR Files .csv to PDF -> Tempo Total de Processamento : ",trunc ((proc.time()[3] - ptm[3]) / 60),"min",trunc ((proc.time()[3] - ptm[3]) %% 60),"seg"),immediate.= T)
warning(paste("-----F I M-----",sep=""),immediate.= T)	
		
