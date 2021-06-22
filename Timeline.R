# setwd("/Users/marinig/Documents/GitHub/Gggantt")
setwd("C:\\Users\\Gabryxx7\\Documents\\GitHub\\Gggantt")
source('./gggantt.R')

tasks <- fread("timeline.csv")

#Generating vertical lines to highlight deadlines or (as in this case) new years
# vlines <- tribble(
#   ~Date, ~LineType, ~Size, ~Color,
#   # "2020-01-01", "solid", 0.6, "grey80",
#   # "2021-01-01", "solid", 0.6, "grey80")
#   tasks[grep("Aug Deadline", tasks$Task),]$Start, "dotted", 0.6, "grey80",
#   tasks[grep("Nov Deadline", tasks$Task),]$Start, "dotted", 0.6, "grey80",
#   "2021-12-01", "dotted", 0.6, "grey80")

#Separating the tasks or a group of tasks can be done by getting the id of the task (if known)
#or by filtering by the task name as shown below
hlines <- tribble(
  ~Index, ~LineType, ~Size, ~Color,
  # tasks[tasks$Task == "1st Year",]$Index-0.5, "dotted", 0.6, "grey80",
  # tasks[tasks$Task == "2nd Year",]$Index-0.5, "dotted", 0.6, "grey80",
  # tasks[tasks$Task == "3rd Year",]$Index-0.5, "dotted", 0.6, "grey80",
  # tasks[tasks$Task == "Thesis",]$Index-0.5, "dotted", 0.6, "grey80")
  tasks[tasks$Task == "#1",]$Index-0.5, "dotted", 0.6, "grey80",
  tasks[tasks$Task == "#2",]$Index-0.5, "dotted", 0.6, "grey80")

hlines <- tribble(
  ~Index, ~LineType, ~Size, ~Color)


g <- generateGantt(tasks=tasks, hlines=hlines, plotTitle="PhD Timeline", fontFamily="Source Sans Pro", date_label_size=13)
#generateGantt(tasks=tasks, hlines=hlines, vlines=vlines, plotTitle="PhD Timeline") #Without Source Sans Font
# ggsave("timeline_end.pdf", width=16, height=8, units="in", type="cairo")
# ggsave("timeline_end.png",  width=16, height=8, units="in", type="cairo-png")
dev.print(file="timeline_end2.png", device=png,  width=16, height=8, units = "in", res=300)
dev <- dev.prev()
dev.print(file="timeline_end2.pdf", device=cairo_pdf,  width=16, height=8)

