run_analysis<-function(){
  directory="data"
  fileUrl="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  fileName="getdata-projectfiles-UCI HAR Dataset.zip"
  ## check if the directory exits, if not, creat a directory
  if (!dir.exists(directory)){
    dir.create(directory)
  }
  
  ## check if the zip file exits, if not, download and unzip the data
  ## It takes a while for downloadng the data (59.7MB)
  if (!file.exists(paste(directory,fileName,sep="/"))){
    download.file(fileUrl,paste(directory,fileName,sep = "/"),mode = "wb")
    unzip(paste(directory,fileName,sep = "/"),exdir=directory)
  }
  
  ## read the feature.txt file, currently hardcode the directory
  dic<-readLines("data/UCI HAR Dataset/features.txt")
  ## extract names contains mean or std
  ## include meanFreq()
  ## exclude angle(,) variables, which are neither mean nor std
  dic<-dic[grep("mean|std",dic)]
  t<-strsplit(dic," ")
  dic<-matrix(t[[1]],nrow = 1,ncol=2)
  for (i in 2:length(t)){
    tmp<-t[[i]]
    dic<-rbind(dic,tmp)
  }
  dic<-data.frame(dic,stringsAsFactors = F)
  colnames(dic)<-c("colnum","colname")
  dic$colnum<-as.numeric(dic$colnum)
  #keep the camelCase style( my preference...)
  dic$colname<-gsub("[\\(]|[\\)]|-","",dic$colname)
  #remove 
  rm(list = c("t","tmp"))

  
  ##read the X&Y data in both test and train folders, takes a while to run
  xtest<-read.table("data/UCI HAR Dataset/test/X_test.txt",header = F)[,dic$colnum]
  xtrain<-read.table("data/UCI HAR Dataset/train/X_train.txt",header = F)[,dic$colnum]
  ytest<-read.table("data/UCI HAR Dataset/test/Y_test.txt",header = F)
  ytrain<-read.table("data/UCI HAR Dataset/train/Y_train.txt",header = F)
  #keep the id as string format
  idtest<-readLines("data/UCI HAR Dataset/test/subject_test.txt")
  idtrain<-readLines("data/UCI HAR Dataset/train/subject_train.txt")
  xytest<-cbind(idtest,xtest,ytest)
  xytrain<-cbind(idtrain,xtrain,ytrain)
  colnames(xytest)<-c("id",dic$colname,"activity")
  colnames(xytrain)<-c("id",dic$colname,"activity")
  rm(list=c("xtest","ytest","xtrain","ytrain"))
  
  ##join the 2 datasets by id, package "plyr" required
  install.packages("plyr")
  library(plyr)
  dataset<-join(xytest,xytrain,by="id",type="full")
  
  ## write the joint data into a .txt file
  write.table(a,"data.txt",sep=" ",col.names = T,row.names = F)
  
  
}
  