path <- "D:/idps/script/output/Step5_mobidb"
fileName <- dir(path)
filePath <- sapply(fileName,function(x){
  paste(path,x,sep = "/")
})
data <- lapply(filePath,function(x){
  read.table(x,header = T,sep = "\t",quote = NULL,stringsAsFactors = F)
})
data.diease <- lapply(data, function(x){
  subset(x,x$RelatedDisease!=0)
})

#D、C、S分类计数
data.disorder.s <- lapply(data, function(x) {
  subset(x,
         x$RelatedDisease != 0 &
           (
             x$mobidb.disorder.full.regions == "s" |
               x$mobidb.disorder.full.regions == "S")
           )
})


data.disorder.C <- lapply(data,function(x){
  subset(x,x$RelatedDisease!=0 & (x$mobidb.disorder.full.regions=="C"|x$mobidb.disorder.full.regions=="c"))
})

data.disorder.D <- lapply(data, function(x){
  subset(x,x$RelatedDisease!=0 & (x$mobidb.disorder.full.regions=="D"| x$mobidb.disorder.full.regions=="d"))
})

data.disorder.NA <- lapply(data, function(x){
  subset(x,x$RelatedDisease!=0 & is.na(x$mobidb.disorder.full.regions) )
})
numofS <- 0
numofC <- 0
numofD <- 0
numofNA <- 0
for (i in 1:122) {
  numofS <- numofS+dim(data.disorder.s[i][[1]])[1]
  numofC <- numofC+dim(data.disorder.C[i][[1]])[1]
  numofD <- numofD+dim(data.disorder.D[i][[1]])[1]
  numofNA <- numofNA+dim(data.disorder.NA[i][[1]])[1]
}

sum <- 0
for (i in 1:122) {
  #cat(data.diease[i][[1]]$mobidb.disorder.full.regions,"\n")
  sum <- sum+length(data.diease[i][[1]]$mobidb.disorder.full.regions)
}


#建表
#选出所有PTM位点
data.PTM <- data.diease <- lapply(data, function(x){
  subset(x,x$Modification!=0)
})
alldata <- data.frame( data.diease[[1]])
alldata <- cbind(data.frame("ProID"=rep("1A01_HUMAN",24)),alldata)
for (i in 2:122) {
  temdata <- data.frame(data.diease[[i]])
  proid <- strsplit(names(data.diease)[i],".txt")[[1]]
  temdata <- cbind(data.frame("ProID"=rep(proid,dim(temdata)[1])),temdata)
  alldata <- rbind(alldata,temdata)
}
#alldata
alldata.diease <- subset(alldata,alldata$RelatedDisease!=0)
alldata.normal <- subset(alldata,alldata$RelatedDisease==0)
#dim( filter(alldata.diease,mobidb.disorder.predictors.mobidb.lite.score>0.74)) 疾病相关中无序的数量
#dim(alldata)总PTM位点个数
#正态性检验
shapiro.test(alldata.normal[,22])
#p-value < 2.2e-16
shapiro.test(alldata.normal[,22])
#p-value < 2.2e-16

#方差齐性检验
a <- factor(c(rep(1,2704),rep(2,261)))
x <- c(alldata.normal[,22],alldata.diease[,22])
bartlett.test(x~a)
predict.score <- data.frame(A=c(rep("normal",2704),rep("diease",261)),rates=x)
#p=0.9159,方差有差异


wilcox.test(alldata.diease[,22],alldata.normal[,22])
# p-value = 0.3675,接受原假设，两样本有显著性差异


# 
boxplot(alldata.diease[,22],alldata.normal[,22])
library(ggplot2)
ggplot(predict.score,aes(x=A,y=rates))+
  geom_boxplot()+
  xlab("")+
  ylab("")

#D、C、S分类计数
alldata.s <- lapply(data, function(x) {
  subset(x,
         x$Modification != 0 &
           (
             x$mobidb.disorder.full.regions == "s" |
               x$mobidb.disorder.full.regions == "S")
  )
})


alldata.C <- lapply(data,function(x){
  subset(x,x$Modification!=0 & (x$mobidb.disorder.full.regions=="C"|x$mobidb.disorder.full.regions=="c"))
})

alldata.D <- lapply(data, function(x){
  subset(x,x$Modification!=0 & (x$mobidb.disorder.full.regions=="D"| x$mobidb.disorder.full.regions=="d"))
})

alldata.NA <- lapply(data, function(x){
  subset(x,x$Modification!=0 & is.na(x$mobidb.disorder.full.regions) )
})
numofS <- 0
numofC <- 0
numofD <- 0
numofNA <- 0
for (i in 1:122) {
  numofS <- numofS+dim(alldata.s[i][[1]])[1]
  numofC <- numofC+dim(alldata.C[i][[1]])[1]
  numofD <- numofD+dim(alldata.D[i][[1]])[1]
  numofNA <- numofNA+dim(alldata.NA[i][[1]])[1]
}

#按打分值画图：

library("plyr")
alldata.factor <- factor(alldata[,22])
alldata.factor.count <- count(alldata.factor)
library(ggplot2)
p1 <- ggplot(alldata.factor.count,aes(x=alldata.factor.count$x,y=alldata.factor.count$freq))+
  geom_point()+
  geom_text(label=alldata.factor.count$freq,vjust=-0.5)+
  xlab("Mobi-lite score")+
  ylab("counts")+
  ggtitle("A")


alldata.diease.factor.count <- count(factor(alldata.diease[,22]))
p2 <- ggplot(alldata.diease.factor.count,aes(x=alldata.diease.factor.count$x,y=alldata.diease.factor.count$freq))+
  geom_point()+
  geom_text(label=alldata.diease.factor.count$freq,vjust=-0.5)+
  xlab("Mobi-lite score")+
  ylab("counts")+
  ggtitle("B")
library("patchwork")
p1+p2
#卡方检验
num.data.normal.diso <- dim(subset(alldata,alldata$RelatedDisease == 0 & alldata$mobidb.disorder.predictors.mobidb.lite.score>0.74))[1]
num.data.normal.stru <- dim(subset(alldata,alldata$RelatedDisease == 0 & alldata$mobidb.disorder.predictors.mobidb.lite.score<0.74))[1]
num.data.dise.diso <- dim(subset(alldata,alldata$RelatedDisease != 0 & alldata$mobidb.disorder.predictors.mobidb.lite.score > 0.74))[1]
num.data.dise.stru <- dim(subset(alldata,alldata$RelatedDisease != 0 & alldata$mobidb.disorder.predictors.mobidb.lite.score <0.74))[1]
kafang.dataframe <- data.frame(stru=c(num.data.normal.stru,num.data.dise.stru),diso=c(num.data.normal.diso,num.data.dise.diso))
rownames(kafang.dataframe) <- c("nor","dise")
chisq.test(kafang.dataframe)
#p = 0.3423

##########PTM类型统计
library(tidyverse)

PTMS <- group_by(alldata,Modification) %>%
  summarize(count=n()) 
  
ggplot(data=PTMS,aes(y=Modification,x=count))+
  geom_point()+
  geom_text(label=PTMS$count,hjust=1.5)


PTMS.disease <- group_by(alldata.diease,Modification) %>%
  summarise(count=n())
ggplot(data = PTMS.disease,aes(y=Modification,x=count))+
  geom_point()+
  geom_text(label=PTMS.disease$count,hjust=1.5)
