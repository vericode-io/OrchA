rm(list=ls(all=TRUE))


warning(paste('[Memory Usage: ',memory.size(),'mb ]' ,sep=""),immediate.= T)
ptm <- proc.time()

#####Digite o diretório local que está o arquivo alphaPerfmonReport.R (Para Windows, Usar "/"  ao invés de "\"):
myDir <- 'D:/scripts/ant/metodos/perfmon/alphaPerfmon/';
myDir <- paste(getwd(),'/metodos/perfmon/alphaPerfmon/',sep="")
warning(paste(myDir),immediate.=T)


#######################################################################
#######################################################################
#Script Geração Sumario Perfmon - Luis Faria luis.faria@primeup.com.br 24/02/2014
#######################################################################
#######################################################################


myFileConfig <- paste(myDir, 'Config.cfg', sep="")
myConfig <- read.table(myFileConfig, header=FALSE, sep="=")
myDirOut <-  paste (myConfig[1,2])
projectName <- paste (myConfig[2,2])
flagHour <- paste (myConfig[4,2])
flagHour <- as.logical (flagHour)
hourBegin <- paste (myConfig[5,2])
hourEnd <- paste (myConfig[6,2])
len <- length
sampleGroup <- as.numeric(paste (myConfig[3,2]))


myFilesDirs <- list.files(paste(myDirOut,sep=""))[grepl("*.csv$", list.files(paste(myDirOut,sep="")))]
#myFilesDirs <-  paste (myConfig[1,2],myFilesDirs,sep="")
mcolnames <- c("Servername","Resource","Counter","Average","Deviation","Max","Min","Percentil(95%)","Percentil(99%)","Samples")
perfmonAllTables <- matrix(NA, 0, len(mcolnames))
colnames(perfmonAllTables) = mcolnames





	for (myFilePerfmon in myFilesDirs ){

perfmonDataset <- read.csv(paste (myConfig[1,2],myFilePerfmon,sep=""), sep=',', header=TRUE, quote="\"" ,fill=T, check.names=F)
perfmonDataset$hora <- substr(perfmonDataset[[1]],12,19)
perfmonDataset[is.na(perfmonDataset[])] <- 0
	
# serverName <- sub("(+.)\\\\.*", "\\1", colnames(perfmonDataset))[2]
		
  i <- 2
  while(i < length(perfmonDataset)-1)
{
  if(mean((perfmonDataset[[i]])) == 0) {
	perfmonDataset <- perfmonDataset[-i]}
  else{
  i <- i+1}
  }

columnsName <- colnames(perfmonDataset)


#Localizando Recursos
columnsNumber <- grep ("\\\\", columnsName, ignore.case=T) #Processador


perfmonTimeStamp <- c(perfmonDataset$hora)
perfmonTimeStamp <- as.data.frame(perfmonTimeStamp)


colnames (perfmonDataset)[1] <- "Time"

columnsName <- columnsName[-1]; 
columnsName <- columnsName[-length(columnsName)]
columnsName2 <- gsub('\\\\',';',columnsName)
columnsName2 <- gsub('\\(s)','s',columnsName2)
columnsName2 <- gsub('\\(KB)','- KB',columnsName2)
columnsName2 <- gsub('\\:','-',columnsName2)
columnsName2 <- gsub('\\(',';(',columnsName2)
columnsName2 <- gsub(' ;;',';;',columnsName2)
columnsName2 <- gsub(':','-',columnsName2)
#columnsName2 <- gsub('<','-',columnsName2)
#columnsName2 <- gsub('>','-',columnsName2)

perfmonRecursos <- (read.table(textConnection(columnsName2), fill=T,sep=';'))
perfmonRecursos <- aggregate(perfmonRecursos$V4, list(perfmonRecursos$V4),length)
perfmonRecursos <- as.vector(perfmonRecursos$Group.1)

serverName <- (read.table(textConnection(columnsName2[2]), fill=T,sep=';'))
serverName <- aggregate(serverName$V3, list(serverName$V3),length)
serverName <- as.vector(serverName$Group.1)


tryCatch(
	for (i in 1:length(perfmonRecursos)){
		if (perfmonRecursos[i] == "") {
		perfmonRecursos <- perfmonRecursos[-i]
		}
	},error=c)


for (i in columnsNumber) {
colnames(perfmonDataset)[i] <- sub("\\\\","",colnames(perfmonDataset[i]))
colnames(perfmonDataset)[i] <- sub("\\\\","",colnames(perfmonDataset[i]))
}

	columnsBytes <- grep (" Bytes", colnames(perfmonDataset), ignore.case=T) #Processador
	for (i in columnsBytes)
{
colnames(perfmonDataset)[i] <- gsub(' Bytes',' MBytes*',colnames(perfmonDataset)[i])
perfmonDataset[i] <- perfmonDataset[i]/1024/1024
}

	columnsBytes <- grep ("\\\\Bytes", colnames(perfmonDataset), ignore.case=T) #Processador
	for (i in columnsBytes)
{
colnames(perfmonDataset)[i] <- gsub('\\\\Bytes','\\\\MBytes*',colnames(perfmonDataset)[i])
perfmonDataset[i] <- perfmonDataset[i]/1024/1024
}

	columnsWorkingSet <- grep ("Working Set", colnames(perfmonDataset), ignore.case=T) #Processador
	for (i in columnsWorkingSet)
{
colnames(perfmonDataset)[i] <- gsub('Working Set','Working Set(Mbytes)*',colnames(perfmonDataset)[i])
perfmonDataset[i] <- perfmonDataset[i]/1024/1024
}

columnsBytes <- grep ("\\\\Current Bandwidth", colnames(perfmonDataset), ignore.case=T) #Processador
	for (i in columnsBytes)
{
colnames(perfmonDataset)[i] <- gsub('\\\\Current Bandwidth','\\\\Current Bandwidth (Mbits*)',colnames(perfmonDataset)[i])
perfmonDataset[i] <- perfmonDataset[i]/1000/1000
}


columnsBytes <- grep ("\\\\Commit Limit$", colnames(perfmonDataset), ignore.case=T)
	for (i in columnsBytes)
{
colnames(perfmonDataset)[i] <- gsub('\\\\Commit Limit$','\\\\Commit Limit (Mbytes*)',colnames(perfmonDataset)[i])
perfmonDataset[i] <- perfmonDataset[i]/1024/1024
}
	
	
columnsBytes <- grep ("\\(KB\\)", colnames(perfmonDataset), ignore.case=T)
	for (i in columnsBytes)
{
colnames(perfmonDataset)[i] <- gsub ('\\(KB\\)','\\(MB\\)**',colnames(perfmonDataset)[i])
perfmonDataset[i] <- perfmonDataset[i]/1024
}

	
columnsBytes <- grep ("% Committed MBytes", colnames(perfmonDataset), ignore.case=T)
	for (i in columnsBytes)
{
perfmonDataset[i] <- perfmonDataset[i]*1024*1024
}	

columnsBytes <- grep ("Network.*\\[", colnames(perfmonDataset), ignore.case=T)
	for (i in columnsBytes)
{
colnames(perfmonDataset)[i] <- gsub('\\[','--',colnames(perfmonDataset)[i])
colnames(perfmonDataset)[i] <- gsub(']','--',colnames(perfmonDataset)[i])
}	


	columnsBytes <- grep ('PhysicalDisk.*Idle Time',colnames(perfmonDataset),ignore.case=T)
for (i in columnsBytes)
	{
perfmonDataset[i] <- 100-perfmonDataset[i]
colnames(perfmonDataset)[i] <- gsub('Idle','Busy',colnames(perfmonDataset)[i])

for (u in 1:nrow(perfmonDataset[i])){

if (perfmonDataset[u,i] < 0){
	perfmonDataset[u,i] <- 0
	}
}	}





per <- 1
tryCatch(
for (i in 1:length(perfmonDataset))
{
per[i] <- round(quantile (as.numeric(perfmonDataset[[i]]),1),0)
if (per[i] > 999999999){
						colnames(perfmonDataset)[i] <- paste(colnames(perfmonDataset[i]),"(*Converted: 'x/(1.0E+15)')")
						perfmonDataset[[i]] <- perfmonDataset[[i]]/1000/1000/1000/1000/1000
						}
						
						
if (round(quantile (as.numeric(perfmonDataset[[i]]),1),0) > 999999999){
						perfmonDataset[[i]] <- perfmonDataset[[i]]*1000*1000
						write.csv(cbind(perfmonDataset[1],perfmonDataset[i]),paste(myDirOut,i,'_noPlot_', projectName,'_',myFilePerfmon,'.txt' , sep=""),row.names=FALSE)
						warning(paste("Nao sera possivel plotar: ",colnames(perfmonDataset)[i],sep=""),immediate.= T)	
						perfmonDataset <- perfmonDataset[-i]
						}					
						
}


	,error=c)


colnames(perfmonDataset) <- gsub(':','-',colnames(perfmonDataset))
y <- colnames(perfmonDataset)



perfmonDataset$hora <- substr(perfmonDataset[[1]],12,19)

lineHourBegin <- which(perfmonDataset$hora == hourBegin)
plotHourBegin <- round(lineHourBegin/sampleGroup,0)

lineHourEnd <- which(perfmonDataset$hora == hourEnd)
plotHourEnd <- round(lineHourEnd/sampleGroup,0)		

if (flagHour == TRUE){
		perfmonDataset[ncol(perfmonDataset)+1] <- c (1:nrow(perfmonDataset))
		dataSetTemp <- perfmonDataset[(perfmonDataset[ncol(perfmonDataset)] >= lineHourBegin & perfmonDataset[ncol(perfmonDataset)] <= lineHourEnd),1:(length(perfmonDataset))] #filtering specific to this corretora.	

}

		warning(paste(myFilePerfmon,': ',"STARTING...",sep=""),immediate.= T)

		statusExec <- length (perfmonRecursos)
		countExec <- -1
		
		
		


##################################################################
##################################################################
#Filtro REcursos
##################################################################
###################################################################

dataSetLimit <- data.frame (
	'Processor Time' = 70,
	'Processor Queue' = 2,
	'Committed MBytes' = 90,
	'Avg. Disk sec' = 8,
	'Busy Time' = 80,
	'Network' = 80)
		

indice <- colnames(perfmonDataset)
cpus <- grep ('Processor.*(Processor Time$|Queue Length)',indice,value=F)
perfmonDataFilter <-  length(perfmonDataset)
perfmonDataFilter <- append (perfmonDataFilter, cpus, after = length(perfmonDataFilter))
memory <- grep ('Memory.*% Commit',indice,value=F)
perfmonDataFilter <- append (perfmonDataFilter, memory, after = length(perfmonDataFilter))
# perfmonDataFilter <- append (perfmonDataFilter, networkIfaces, after = length(perfmonDataFilter))
physicalDisk <- grep ('Physical.*(Busy|sec/(r|w|t))',indice,ignore.case=T,value=F)
perfmonDataFilter <- append (perfmonDataFilter, physicalDisk, after = length(perfmonDataFilter))

perfmonRawDataFilter <- perfmonDataset[perfmonDataFilter]

if (length(grep ('Network Interface.*(Bytes.*Total|Current Bandwidth)',indice,value=F)) > 0){
networkIfaces <- grep ('Network Interface.*(Bytes.*Total|Current Bandwidth)',indice,value=F)

netIndice <- colnames(perfmonDataset[networkIfaces])
netIndice <- gsub('\\(',';',netIndice)
netIndice <- gsub(')',';',netIndice)

Ifaces <- read.table(textConnection(netIndice), fill=T,sep=';')
Ifaces <- aggregate(Ifaces$V3, list(Ifaces$V2),length)
Ifaces <- Ifaces$Group.1[Ifaces$x > 1]
}







for (net in 1:length(Ifaces)){
	eth_bytes_sec <- NA
	eth_bytes_band <- NA
	eth_bytes_sec <- grep (paste(Ifaces[net],'.*bytes.* Total/sec',sep=""),colnames(perfmonDataset),ignore.case=T)
	if (length (eth_bytes_sec) > 1){
		eth_bytes_sec <- grep (paste(Ifaces[net],'.*bytes.* Total/sec',sep=""),colnames(perfmonDataset),ignore.case=T)[1]
		}		
	eth_bytes_band <- grep (paste(Ifaces[net],'.*Current Bandwidth',sep=""),colnames(perfmonDataset),ignore.case=T)
	if (length (eth_bytes_band) > 1){
		eth_bytes_band <- grep (paste(Ifaces[net],'.*Current Bandwidth',sep=""),colnames(perfmonDataset),ignore.case=T)[1]
		}

	if(!is.na(eth_bytes_sec)&!is.na(eth_bytes_band))
	{
	
	#z <- (perfmonDataset[[eth_bytes_sec]]*8/perfmonDataset[[eth_bytes_band]])*100
	temp <- (perfmonDataset[eth_bytes_sec]*8/perfmonDataset[eth_bytes_band])*100
	colnames(temp) <- paste(serverName,'\\Network Interface(',Ifaces[net],')\\% Consumo Total',sep="")
	perfmonRawDataFilter[(ncol(perfmonRawDataFilter)+1)] <- temp
	}
	}




	pdf(
			paper="a4r",
			width=16, 
			height=9,
			paste(myDirOut, 'speedUP_',projectName,'_',myFilePerfmon,'.pdf' , sep="")
		);
			
		par(mar = c(5,7,4,2) + 0.1)
	

smoke <- matrix(nrow=length(perfmonRawDataFilter),ncol=7,byrow=TRUE)
colnames(smoke) <- c("Average","Deviation","Max","Min","Percentil(95%)","Percentil(99%)","Samples")
rownames(smoke) <-  paste (sub("(.*)\\\\(.*)\\\\(.*)","\\2", colnames(perfmonRawDataFilter)),"/",sub("(.*)\\\\(.*)\\\\(.*)","\\3", colnames(perfmonRawDataFilter)),sep="")


for(y in 2:nrow(smoke)){ 
		smoke [y,1] <- format(round(mean(perfmonRawDataFilter[[y]],na.rm=T),2),big.mark = ",")
		smoke [y,2] <- format(round(sd(perfmonRawDataFilter[[y]],na.rm=T),2),big.mark = ",")
		smoke [y,3] <- format(round(max(perfmonRawDataFilter[[y]],na.rm=T),1),big.mark = ",")
		smoke [y,4] <- format(round(min(perfmonRawDataFilter[[y]],na.rm=T),1),big.mark = ",")
		smoke [y,5] <- format(round(quantile(as.numeric(perfmonRawDataFilter[[y]],na.rm=T),0.95),0),big.mark = ",")
		smoke [y,6] <- format(round(quantile(as.numeric(perfmonRawDataFilter[[y]],na.rm=T),0.99),0),big.mark = ",")	
		smoke [y,7] <- len(perfmonRawDataFilter[[y]])
		  }


		  
smoke <- as.table(smoke)[-1,]
# textplot( smoke, valign="top", hadj = 1  )
#mcolnames <- c("Servername","Resource","Counter","Average","Deviation","Max","Min","Percentil(95%)","Percentil(99%)","Samples")

# my_table <- tableGrob(smoke,
# gpar.coretext = gpar(col="black",fontsize=8),
# gpar.coltext=gpar(fontsize=8), 
# gpar.rowtext=gpar(col="red",fontsize=8))

# lg <- lapply(c("theme.black"),
             # function(x) tableGrob(smoke, theme=get(x)()))
# do.call(grid.arrange, lg)
			 
# d <- smoke
# my_table <- tableGrob(d)
		 
# grid.newpage()
# h <- grobHeight(my_table)
# w <- grobWidth(my_table)
# mytitle <- textGrob(paste("Server: ",serverName), y=unit(0.5,"npc") + 0.5*h, 
                  # vjust=0, gp=gpar(fontsize=15))
# footnote <- textGrob("PrimeUP SpeedUp", 
                     # x=unit(0.5,"npc") - 0.5*w,
                     # y=unit(0.5,"npc") - 0.5*h, 
                  # vjust=1, hjust=0,gp=gpar( fontface="italic"))
# gt <- gTree(children=gList(my_table, mytitle, footnote))
# grid.draw(gt)
			 
			 
			 
# grid.arrange(my_table)



	
		for (i in 2:length(perfmonRawDataFilter)){
			
			x <- as.numeric(as.character(perfmonRawDataFilter[[i]]))
			y1 <- 1
			y2 <- sampleGroup
			z_num <- trunc(length(x)/sampleGroup)
			z <-0
			z_time <- "0"
			z_sd1 <- 0
			z_sd2 <- 0
					
			if (sampleGroup > 1){
				for (ii in 1:z_num) {
					z[ii] <- mean(x[y1:y2])
					z_sd1[ii] <- z[ii]+sd(x[y1:y2])
					z_sd2[ii] <- z[ii]-sd(x[y1:y2])
					z_time[ii] <- paste(perfmonRawDataFilter$hora[y2])
					y1 <- y1+sampleGroup
					y2 <- y2+sampleGroup
				}
				

			}else{
				for (ii in 1:z_num){
					z[ii] <- mean(x[y1:y2])
					z_time[ii] <- paste(perfmonRawDataFilter$hora[y2])
					y1 <- y1+sampleGroup
					y2 <- y2+sampleGroup
				}
			}
					

			if (grepl (paste(colnames(dataSetLimit[1])),colnames(perfmonRawDataFilter[i])) == 1){
			limit <- dataSetLimit[1]}
			if (grepl (paste(colnames(dataSetLimit[2])),colnames(perfmonRawDataFilter[i])) == 1){
			limit <- dataSetLimit[2]}
			if (grepl (paste(colnames(dataSetLimit[3])),colnames(perfmonRawDataFilter[i])) == 1){
			limit <- dataSetLimit[3]}
			if (grepl (paste(colnames(dataSetLimit[4])),colnames(perfmonRawDataFilter[i])) == 1){
			limit <- dataSetLimit[4]}							
			if (grepl (paste(colnames(dataSetLimit[5])),colnames(perfmonRawDataFilter[i])) == 1){
			limit <- dataSetLimit[5]}					
			
			if ((mean(perfmonRawDataFilter[[i]]) < limit[[1]] & max(perfmonRawDataFilter[[i]]) < limit[[1]])){
				color <- "darkgreen"
				color_sd <- "lightgreen"

			}
			
			if ((mean(perfmonRawDataFilter[[i]]) < limit[[1]] & max(perfmonRawDataFilter[[i]]) > limit[[1]])){
				color <- "darkblue"
				color_sd <- "deepskyblue"
			}
			
			if ((mean(perfmonRawDataFilter[[i]]) > limit[[1]] & max(perfmonRawDataFilter[[i]]) > limit[[1]])){
				color <- "darkred"
				color_sd <- "tomato"
			}
			
			
			
			plot (
				z,
				xaxt="n",
				ylim=range(0:max(100,z_sd1,z)),
				ylab="",
				xlab="", 
				type="l",
				lwd=1.5,
				las=1,
				xaxp=c(0, round(length(z)), 20),
				panel.first=grid(), 
				cex.axis=0.8, 
				las=2, 
				col=color,
			)			
	
					
			title (
				main = list(paste('Consumo - ', colnames(perfmonRawDataFilter[i]),' (sampleGroup 1:',sampleGroup,')',  sep=""), cex=0.8,
				col="blue", font=2)
			)
			
			#Add em 31/01/2012
			if (flagHour == TRUE){
				abline (
					v=plotHourBegin, 
					col="purple"
				)
				abline (	
					v=plotHourEnd, 
					col="purple"
				)
				
				}
				
				abline (
					h=limit[[1]], 
					lty=2,
					col="sienna1"
				)
				
								
			lines(
				z_sd1,
				lwd=1, 
				lty=3, 
				col=color_sd,
				cex=0.5, 
				pch=20
			)

			
						
			axis(
				1, 
				las=1, 
				at=1:length(z_time),
				# at=1:length(z_time), 
				# FALSE, 
				lab = c(paste(z_time)), 
				cex.axis=.6
			)
						
			title(
				ylab = sub(".*\\\\", "\\1", colnames(perfmonRawDataFilter))[i], 
							cex=1,
							col="darkgreen", 
							font=2
							
				)
						
			title(
				xlab = "Horario", 
				line = 3.6
			)
							
			if (flagHour == TRUE){	
				legend(
						"topright",
						c(
							paste("*Average= ",format(round(mean(perfmonRawDataFilter[[i]]),2),big.mark = ",")),
							paste('*Standard Deviation= ',format(round(sd(perfmonRawDataFilter[[i]]),2),big.mark = ",")),
							paste('*Max=',format(round(max(perfmonRawDataFilter[[i]]),1),big.mark = ",")),
							paste('*Min=',format(round(min(perfmonRawDataFilter[[i]]),1),big.mark = ",")),
							paste('*Percentil(95%)= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.95),0),big.mark = ",")),
							paste('*Percentil(99%)= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.99),0),big.mark = ","))
						),
						text.col=c(color,color_sd,"gray","gray","gray","gray"),
						lwd=c(2,1.5),
						cex=.8,
						col=c(color,color_sd,"white","white","white","white"), 
						lty=c(1,4,0,0), 
						bty=c("n","n","n","n","n"), 
						pch=c('','','','','')
					)
							#warning(paste('   |--Avg= ',format(round(mean(dataSetTemp[[i]]),2),big.mark = ",")),immediate.= T)
							write(paste('   |--Avg= ',format(round(mean(perfmonRawDataFilter[[i]]),2),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--StDev= ',format(round(sd(dataSetTemp[[i]]),2),big.mark = ",")),immediate.= T)
							write(paste('   |--StDev= ',format(round(sd(perfmonRawDataFilter[[i]]),2),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Max=',format(round(max(dataSetTemp[[i]]),1),big.mark = ",")),immediate.= T)
							write(paste('   |--Max=',format(round(max(perfmonRawDataFilter[[i]]),1),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Min=',format(round(min(dataSetTemp[[i]]),1),big.mark = ",")),immediate.= T)
							write(paste('   |--Min=',format(round(min(perfmonRawDataFilter[[i]]),1),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Perc.95= ',format(round(quantile(as.numeric(dataSetTemp[[i]]),0.95),0),big.mark = ",")),immediate.= T)
							write(paste('   |--Perc.95= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.95),0),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Perc.99= ',format(round(quantile(as.numeric(dataSetTemp[[i]]),0.99),0),big.mark = ",")),immediate.= T)
							write(paste('   |--Perc.99= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.99),0),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
			}else{
					legend(
						"topright",
						c(
							paste("Average= ",format(round(mean(perfmonRawDataFilter[[i]]),2),big.mark = ",")),
							paste('Standard Deviation= ',format(round(sd(perfmonRawDataFilter[[i]]),2),big.mark = ",")),
							paste('Max=',format(round(max(perfmonRawDataFilter[[i]]),1),big.mark = ",")),
							paste('Min=',format(round(min(perfmonRawDataFilter[[i]]),1),big.mark = ",")),
							paste('Percentil(90%)= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.90),0),big.mark = ",")),
							paste('Percentil(95%)= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.95),0),big.mark = ","))
						),
						text.col=c(color,color_sd,"gray","gray","deepskyblue","deepskyblue"),
						lwd=c(2,1.5),
						cex=.8,
						col=c(color,color_sd,"gray","gray","deepskyblue","deepskyblue"), 
						lty=c(1,4,0,0,0,0), 
						bty=c("n","n","n","n","n"), 
						pch=c('','','','','')
					)
							#warning(paste('   |--Avg= ',format(round(mean(perfmonDataset[[i]]),2),big.mark = ",")),immediate.= T)
							write(paste('   |--Avg= ',format(round(mean(perfmonRawDataFilter[[i]]),2),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--StDev= ',format(round(sd(perfmonDataset[[i]]),2),big.mark = ",")),immediate.= T)
							write(paste('   |--StDev= ',format(round(sd(perfmonRawDataFilter[[i]]),2),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Max=',format(round(max(perfmonDataset[[i]]),1),big.mark = ",")),immediate.= T)
							write(paste('   |--Max=',format(round(max(perfmonRawDataFilter[[i]]),1),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Min=',format(round(min(perfmonDataset[[i]]),1),big.mark = ",")),immediate.= T)
							write(paste('   |--Min=',format(round(min(perfmonRawDataFilter[[i]]),1),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Perc.95= ',format(round(quantile(as.numeric(perfmonDataset[[i]]),0.95),0),big.mark = ",")),immediate.= T)
							write(paste('   |--Perc.90= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.90),0),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
							#warning(paste('   |--Perc.99= ',format(round(quantile(as.numeric(perfmonDataset[[i]]),0.99),0),big.mark = ",")),immediate.= T)
							write(paste('   |--Perc.95= ',format(round(quantile(as.numeric(perfmonRawDataFilter[[i]]),0.95),0),big.mark = ",")),paste(myDirOut, 'resultsPerfmon_', projectName,'_',myFilePerfmon,'.txt' , sep=""),append=T)
				}
				

				

				
	
}

dev.off()
}
warning(paste("Perfmon Files .csv to PDF -> Tempo Total de Processamento : ",trunc ((proc.time()[3] - ptm[3]) / 60),"Minutos e ",trunc ((proc.time()[3] - ptm[3]) %% 60)," segundos"),immediate.= T)
warning(paste("-----F I M-----",sep=""),immediate.= T)	
