# Locale 설정 
Sys.setlocale('LC_ALL','C')
Sys.setlocale(category = "LC_ALL", locale = "ko_KR.UTF-8")

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
data <- read.csv("hira.csv")

# ----------------------------------------------------------------------------------------------------------------------------------

# NA 값 처리
data[is.na(data)] <- 0

# Data summary
str(data)
summary(data)
nrow(data)

# 형변환
data$GENDER <- as.factor(data$GENDER)
data$HB_YN <- as.factor(data$HB_YN)

# col_name <- colnames(data[6:46])
# data_1 <- lapply(data[col_name], as.factor)
# data_1 <- cbind(data[,1:5], data_1)
# data <- data_1

# 입내원 일수가 0인것 빼고 불러오기
data <- subset(data, data$DAY != 0)
nrow(data)

# 95% vs 5%
table(data$HB_YN)

#one_hot <- transform(data, hb_yes = ifelse(HB_YN == 1, 1, 0),
#                hb_no = ifelse(HB_YN== 0, 1, 0))
#one_hot$HB_YN <- NULL

# ----------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------

# Model - Sampling 안했을 때
index <- createDataPartition(y = data$HB_YN, p = 0.7, list = FALSE)
train <- data[index, ]
test <- data[-index, ]

set.seed(1234)
model <- train(HB_YN ~ ., data = train, method = "glm")

pred <- predict(model, newdata = test)
confusionMatrix(pred, test$HB_YN)

model_rf <- randomForest(HB_YN ~ ., data = train)

pred <- predict(model_rf, newdata = test)
confusionMatrix(pred, test$HB_YN)

# ----------------------------------------------------------------------------------------------------------------------------------

# Model (Down Sampling) [GLM]
x <- downSample(subset(data, select=-HB_YN), data$HB_YN)
table(x$Class)

index <- createDataPartition(y = x$Class, p = 0.7, list = FALSE)
train_down <- x[index, ]
test_down <- x[-index, ]

set.seed(1234)
model <- train(Class ~ ., data = train, method = "glm")

pred <- predict(model, newdata = test)
confusionMatrix(pred, test$Class)

# ----------------------------------------------------------------------------------------------------------------------------------

# Model (Up Sampling) [GLM]
ups <- upSample(subset(data, select=-HB_YN), data$HB_YN)
table(y$Class)

index <- createDataPartition(y = y$Class, p = 0.7, list = FALSE)
train_up <- y[index, ]
test_up <- y[-index, ]

set.seed(1234)
model <- train(Class ~ ., data = train, method = "glm")

pred <- predict(model, newdata = test)
confusionMatrix(pred, test$Class)
summary(model)

# ----------------------------------------------------------------------------------------------------------------------------------

# Model (Up Sampling) - 1 [GLM]
model_1 <- train(Class ~ GENDER + AGE + DAY + DRUG_110801ATB + DRUG_111001ACE + DRUG_111001ATE + DRUG_133202ATB + DRUG_136901ATB +
                   DRUG_152103BIJ + DRUG_168602BIJ + DRUG_198403BIJ + DRUG_492501ATB + DRUG_498801ATB + DRUG_498900ATB +
                   DRUG_506100ATB + DRUG_511401ATB + DRUG_511402ATB + DRUG_511403ATB + DRUG_517900ACH + DRUG_617001ATB + DRUG_617002ATB
                 , data = train_up, method = "glm")
summary(model_1)
pred <- predict(model_1, newdata = test)
confusionMatrix(pred, test$Class)


# ----------------------------------------------------------------------------------------------------------------------------------

# Model (Up Sampling) - 1 [RF] = 70%
model_rf_1 <- randomForest(Class ~ ., data = train_up)

pred <- predict(model_rf_1, newdata = test_up, type = "response")
confusionMatrix(pred, test_up$Class)

pr <- prediction(pred, test_up$Class)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
win.graph(); plot(prf, main='ROC of Test Data')
# ----------------------------------------------------------------------------------------------------------------------------------

# Model (Down Sampling) - 2 [RF] = 63.7%
model_rf_2 <- randomForest(Class ~ ., data = train_down)

pred <- predict(model_rf_2, newdata = test_down)
confusionMatrix(pred, test_down$Class)

pr <- prediction(pred, test$vote)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
win.graph(); plot(prf, main='ROC of Test Data')
# ----------------------------------------------------------------------------------------------------------------------------------

# Model (Up Sampling) - 3 [RF] = 67.3%
model_rf_3 <- randomForest(Class ~ GENDER + AGE + DAY + DRUG_110801ATB + DRUG_111001ACE + DRUG_111001ATE + DRUG_133202ATB + DRUG_136901ATB +
                             DRUG_152103BIJ + DRUG_168602BIJ + DRUG_198403BIJ + DRUG_492501ATB + DRUG_498801ATB + DRUG_498900ATB +
                             DRUG_506100ATB + DRUG_511401ATB + DRUG_511402ATB + DRUG_511403ATB + DRUG_517900ACH + DRUG_617001ATB + DRUG_617002ATB
                           , data = train_up)

pred <- predict(model_rf_3, newdata = test_up)
confusionMatrix(pred, test_up$Class)

# ----------------------------------------------------------------------------------------------------------------------------------
# Model (Up Sampling) - 1 [xgboost]
ups <- upSample(subset(data, select=-HB_YN), data$HB_YN)
set.seed(42)
row <- sample(nrow(ups))
ups_shu <- ups[row,]

index <- createDataPartition(y = ups_shu$Class, p = 0.7, list = FALSE)
train_up <- ups_shu[index, ]
test_up <- ups_shu[-index, ]


x = train_up %>% 
  select(-Class) %>%
  data.matrix
y = as.numeric(train_up$Class)

model_xg_1 <- xgboost(data = x, label = y - 1,
                     max.depth = 15, eta = 0.3, nthread = 4, nrounds = 100, objective = "binary:logistic", prediction = T)

test_x = test_up %>% 
  select(-Class) %>%
  data.matrix()
test_y = as.numeric(test_up$Class)
pred <- predict(model_xg_1, test_x)

prediction <- as.numeric(pred > 0.5)
print(head(prediction))

err <- mean(as.numeric(pred > 0.5) != test_y - 1)
print(paste("test accuracy = ", 1 - err))

caret::confusionMatrix(as.factor(prediction), as.factor(test_y - 1))

pr <- prediction(pred, test_y - 1)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf, main='ROC of XGBoost : AUC - 0.86354')

# AUC = 0.8635 (민감도와 특이도 - 1을 1이라고, 0을 0이라고)
# x - TPR (민감도) [양성율], y - FPR (1-특이도) [위양성율]
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]; auc
plot.roc
# 
importance <- xgb.importance(model = model_xg_1)
print(xgb.plot.importance(importance_matrix = importance))

#
tree_result <- xgb.model.dt.tree(model = model_xg_1)
# ----------------------------------------------------------------------------------------------------------------------------------
# 
x_1 <- train_up %>% 
  select(-Class, -DAY, -AVG_DDCNT) %>%
  data.matrix

model_xg_2 <- xgboost(data = x_1, label = y - 1,
                      max.depth = 15, eta = 0.3, nthread = 4, nrounds = 100, objective = "binary:logistic", prediction = T)

test_x_1 = test_up %>% 
  select(-Class, -DAY, -AVG_DDCNT) %>%
  data.matrix()
test_y_1 = as.numeric(test_up$Class)
pred_1 <- predict(model_xg_2, test_x_1)

prediction_1 <- as.numeric(pred_1 > 0.5)
print(head(prediction))

err1 <- mean(as.numeric(pred_1 > 0.5) != test_y_1 - 1)
print(paste("test accuracy = ", 1 - err1))

caret::confusionMatrix(as.factor(prediction_1), as.factor(test_y_1 - 1))

pr1 <- prediction(pred_1, test_y_1 - 1)
prf1 <- performance(pr1, measure = "tpr", x.measure = "fpr")
plot(prf1, main='ROC of XGBoost : AUC - 0.7465')

# AUC = 0.8635 (민감도와 특이도 - 1을 1이라고, 0을 0이라고)
# x - TPR (민감도) [양성율], y - FPR (1-특이도) [위양성율]
auc1 <- performance(pr1, measure = "auc")
auc1 <- auc1@y.values[[1]]; auc1

# 
importance <- xgb.importance(model = model_xg_2)
print(xgb.plot.importance(importance_matrix = importance))
# ----------------------------------------------------------------------------------------------------------------------------------
set.seed(42)
row <- sample(nrow(ups))
ups_shu <- ups[row,]

# Model (Up Sampling) - 2 [xgboost]
x = ups_shu %>% 
  select(-Class) %>%
  data.matrix
y = as.numeric(ups_shu$Class)

model_xg_cv <- xgb.cv(data = x, label = y - 1, 
                        nfold = 10, nrounds = 200, early_stopping_rounds = 150, eval_metric = "error",
                        objective = "binary:logistic", verbose = T, prediction = T)

pred_df = model_xg_cv$pred %>% as.data.frame %>%
  mutate(pred = levels(y)[max.col(.)] %>% as.factor,actual = y)

pred_df %>% select(pred, actual) %>% table
caret::confusionMatrix(pred_df$pred, pred_df$actual)

cvplot = function(model){
  eval.log = model$evaluation_log
  std = names(eval.log[,2]) %>% gsub('train_','',.) %>% gsub('_mean','',.)
  
  data.frame(error = c(unlist(eval.log[.2]), unlist(eval.log[,4])),
             class = c(rep('train', nrow(eval.log)),
                       rep('test', nrow(eval.log))),
             nround = rep(1:nrow(eval.log), 2)
             ) %>%
    ggplot(aes(nround, error, col = class)) +
    geom_point(alpha = 0.2) +
    geom_smooth(alpha = 0.4, se = F) +
    theme_bw() +
    ggtitle("XGBoost Cross-validation",
            subtitle = paste0('fold : ', length(model$folds),
                              '  iteration : ', model$niter)
            ) + ylab(std) + theme(axis.title = element_text(size = 11))
}
cvplot(model_xg_cv)
