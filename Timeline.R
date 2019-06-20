source('./gggantt.R')

tasks <- fread("timeline.csv")

#Generating vertical lines to highlight deadlines or (as in this case) new years
vlines <- tribble(
  ~Date, ~LineType, ~Size, ~Color,
  "2020-01-01", "solid", 0.6, "grey80",
  "2021-01-01", "solid", 0.6, "grey80")

#Separating the tasks or a group of tasks can be done by getting the id of the task (if known)
#or by filtering by the task name as shown below
hlines <- tribble(
  ~Index, ~LineType, ~Size, ~Color,
  tasks[tasks$Task == "1st Year",]$Index-0.5, "dotted", 0.6, "grey80",
  tasks[tasks$Task == "2nd Year",]$Index-0.5, "dotted", 0.6, "grey80",
  tasks[tasks$Task == "3rd Year",]$Index-0.5, "dotted", 0.6, "grey80",
  tasks[tasks$Task == "Thesis",]$Index-0.5, "dotted", 0.6, "grey80")


generateGantt(tasks=tasks, hlines=hlines, vlines=vlines, plotTitle="PhD Timeline", fontFamily="Source Sans Pro")
#generateGantt(tasks=tasks, hlines=hlines, vlines=vlines, plotTitle="PhD Timeline") #Without Source Sans Font
ggsave("timeline.pdf", width=16, height=8, units="in", device=cairo_pdf)

