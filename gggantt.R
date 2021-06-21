library(tidyverse)
library(lubridate)
library(scales)
library(Cairo)
library(data.table)
library(reshape2)
library(Cairo)

generateGantt <- function(tasks, hlines, vlines=NULL, plotTitle="Timeline", fontFamily="Open Sans", date_label_size=1){
  # Custom theme for making a clean Gantt chart
  theme_gantt <- function(base_size=17, base_family=fontFamily) {
    ret <- theme_bw(base_size, base_family) %+replace%
      theme(panel.background = element_rect(fill="#ffffff", colour=NA),
            axis.title.x=element_text(vjust=-0.2), axis.title.y=element_text(vjust=1.5),
            title=element_text(vjust=1.2, family=fontFamily),
            panel.border = element_blank(),
            axis.line=element_blank(),
            panel.grid.minor.x=element_line(size=0.2, colour="grey90"),
            panel.grid.major.x = element_line(size=0.4, colour="grey85"),
            panel.grid.major.y = element_blank(),
            panel.grid.minor.y = element_blank(),
            axis.ticks=element_blank(),
            legend.position="none", 
            axis.title=element_text(size=rel(0.8), family=fontFamily),
            strip.text=element_text(size=rel(1), family=fontFamily),
            strip.background=element_rect(fill="#ffffff", colour=NA),
            panel.spacing.y=unit(1.5, "lines"),
            legend.key = element_blank(),
            plot.margin=grid::unit(c(10,10,10,10), "mm"))
    ret
  }
  
  if(!grepl("ndex", colnames(tasks)))
    tasks$Index <- seq(nrow(tasks),1,-1)
  tasks$Start <- as.POSIXct(tasks$Start, origin="1970-01-01", tryFormats = c("%Y-%m-%d","%Y/%m/%d"))
  tasks$End <- as.POSIXct(tasks$End, origin="1970-01-01",  tryFormats = c("%Y-%m-%d","%Y/%m/%d"))
  breaks <- tasks$Task
  labels <- breaks
  
  
  markers <- tasks[grep("marker", tasks$Type),]
  markers$Task <- ""
  markers$Project <- ""
  
  if(!("MarkerSize" %in% colnames(markers))){
    #markers <- transform(markers, MarkerSize = as.numeric(MarkerSize))
    markers$MarkerSize <-9
  }
  
  if(!("MarkerShape" %in% colnames(markers))){
    #markers <- transform(markers, MarkerShape = as.numeric(MarkerShape))
    markers$MarkerShape <-18
  }
  
  if(!("MarkerColor" %in% colnames(markers))){
    markers$MarkerColor <- as.factor("#E8E8E8")
    #markers <- transform(markers, MarkerColor = as.character(MarkerColor))
  }
  
  if(!("MarkerOffset" %in% colnames(markers))){
    #markers <- transform(markers, MarkerOffset = as.numeric(MarkerOffset))
    markers$MarkerOffset <-0
  }
  
  if(!("MarkerXPos" %in% colnames(markers))){
    #markers <- transform(markers, MarkerXPos = as.character(MarkerXPos))
    markers$MarkerXPos <- "center"
  }
  
  markers[markers$MarkerXPos == ""] <- "center"
  
  markers$PosY <- markers$Index - markers$MarkerOffsetY
  markersStart <- markers[grep("tart", markers$MarkerXPos),]
  markersStart$PosX <- difftime(markersStart$End , markersStart$Start, units="secs")*0.9 + markersStart$Start
  
  markersEnd <- markers[grep("nd", markers$MarkerXPos),]
  markersEnd$PosX <- difftime(markersEnd$End , markersEnd$Start, units="secs")*0.1 + markersEnd$Start
  
  markersCenter <- markers[grep("enter", markers$MarkerXPos),]
  markersCenter$PosX <- difftime(markersCenter$End , markersCenter$Start, units="secs")*0.5 + markersCenter$Start
  
  allDates <- melt(tasks[,c("Start", "End")])$value
  yearsVlines <- data.frame("date"=as.POSIXct(lubridate::ymd(unique(lubridate::year(allDates)), truncated=2L)))
  hour(yearsVlines$date) <- 0
  
  bars <- tasks[grep("bar", tasks$Type),]
  
  if(!("BarColor" %in% colnames(bars))){
   # bars <- transform(bars, BarColor = as.character(BarColor))
    bars$BarColor <- "#E8E8E8"
  }
  
  if(!("BarSize" %in% colnames(bars))){
    #bars <- transform(bars, BarSize = as.character(BarSize))
    bars$BarSize <- "#E8E8E8"
  }
  
  # Build plot
  timeline <- ggplot()
  
  if(!is.null(vlines)){
    vlines$Date <- as.POSIXct(vlines$Date, origin="1970-01-01")
    timeline <- timeline + geom_vline(data=vlines, aes(xintercept=Date, color=Color, linetype=LineType, size=Size))
  }
  
  if(!is.null(hlines))
    timeline <- timeline + geom_hline(data=hlines,aes(yintercept=Index, color=Color, linetype=LineType, size=Size))
  
  tasks$LabelFace[tasks$LabelFace == ""] <- "plain"
  
  
  if(!("LabelFace" %in% colnames(tasks))){
    #tasks <- transform(tasks, LabelFace = as.character(LabelFace))
    tasks$LabelFace <- "#E8E8E8"
  }
  if(!("LabelColor" %in% colnames(tasks))){
    #tasks <- transform(tasks, LabelColor = as.character(LabelColor))
    tasks$LabelColor <- "#E8E8E8"
  }
  if(!("LabelSize" %in% colnames(tasks))){
    #tasks <- transform(tasks, LabelSize = as.character(LabelSize))
    tasks$LabelSize <- 15
  }
  
  
  timeline <- timeline +
    geom_vline(data=yearsVlines,aes(xintercept=date, color="grey70", linetype="solid", size=0.65)) +
    geom_segment(data=bars, aes(x=Start, xend=End, y=Index, yend=Index, color=BarColor, size=BarSize)) + 
    geom_point(data=markersStart, mapping=aes(x=PosX, y=PosY, size=MarkerSize-0.5, color=MarkerColor, shape=MarkerShape)) +
    geom_point(data=markersEnd, mapping=aes(x=PosX, y=PosY, size=MarkerSize-0.5, color=MarkerColor, shape=MarkerShape)) +
    geom_point(data=markersCenter, mapping=aes(x=PosX, y=PosY, size=MarkerSize-0.5, color=MarkerColor, shape=MarkerShape)) +
    scale_color_identity() +
    scale_shape_identity() +
    scale_linetype_identity() +
    scale_size_identity() +
    scale_y_continuous(breaks=tasks$Index, labels=labels, trans='reverse') +
    scale_x_datetime(date_labels = "%b '%y", date_breaks="1 month", expand = expand_scale(mult = c(.015, .015))) +
    guides(colour=guide_legend(title=NULL)) +
    labs(x=NULL, y=NULL) +
    theme_gantt() +
    ggtitle(label = plotTitle) +
    theme(axis.text.x=element_text(angle=0, hjust=0.5, size=date_label_size), axis.text.y=element_text(color=tasks$LabelColor, face=tasks$LabelFace, size=tasks$LabelSize))
  
  return(list("timeline"=timeline))
}
