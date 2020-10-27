# library
library(tidyverse)
library(dplyr)
library(caret)
library(e1071)
library(randomForest)
library(ROCR)
library(xgboost)

# Data
setwd("/Users/doyun/Downloads/")

# 
med1 <- read.csv("MEDICINE.csv")
med2 <- read.csv("MEDICINE2.csv")

med1 <- med1[-(1:2),]
med2 <- med2[-1,]

med1_use <- med1 %>%
  arrange(desc(SUM_DUE))

med2_use <- med2 %>%
  arrange(desc(SUM_DUE))

med1_due <- med1 %>%
  arrange(desc(AVG_DUE))

med2_due <- med2 %>%
  arrange(desc(AVG_DUE))

#
nrow(med1_use)



#
library(googleVis)

plot(gvisPieChart(med1_use[1:10,][,-(2:4)], options=list(
  slices="{0: {offset: 0.3}}",
  pieHole=0.4)))

plot(gvisPieChart(med2_use[1:10,][,-(2:4)], options=list(
  slices="{0: {offset: 0.3}}",
  pieHole=0.4)))

plot(gvisPieChart(med1_use[,-(2:4)]))
plot(gvisPieChart(med2_use[,-(2:4)]))

#
ggplot(med1_due[1:5,][,-2][,-(3:4)], aes(x = reorder(GNL_CD, -AVG_DUE), y = AVG_DUE, fill = GNL_CD)) +
  geom_bar(stat = "identity", color = "black") +
  scale_fill_manual(values = c("#50C2FF", "#D2E1FF", "#E8F5FF", "#78EAFF", "#1E90FF")) +
  theme_bw() + theme(
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    plot.background = element_blank()
  )

ggplot(med2_due[1:5,][,-(2:3)][,-3], aes(x = reorder(GNL_CD, -AVG_DUE), y = AVG_DUE, fill = GNL_CD)) +
  geom_bar(stat = "identity", color = "black") +
  scale_fill_manual(values = c("#1E90FF", "#50C2FF", "#78EAFF", "#E8F5FF", "#D2E1FF")) +
  theme_bw() + theme(
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(),
    panel.background = element_blank(),
    plot.background = element_blank()
  )

#
med_code <- read.csv("주성분코드_최종.csv")
med_code$주성분코드

loca1 <- c()
for (i in med_code$주성분코드){
  loca1 <- c(loca1, paste(which(med1$GNL_CD == i), "/", i))
}

loca2 <- c()
for (i in med_code$주성분코드){
  loca2 <- c(loca2, paste(which(med2$GNL_CD == i), "/", i))
}

# 300
loca1
# 530
loca2






