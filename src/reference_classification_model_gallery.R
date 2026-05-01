#CONSTRUCCIÓN DEL CLASIFICADOR
datos<-read.table("bobinas.txt",header=T) 
summary(datos)
head(datos)
set.seed(123)
#calidad es una variable 0 no defectuoso, 1 defectuoso
#vmedia velocidad a la que va la chapa
#TP12 temperatura a la que entra la chapa al baño
#T1,T2,T3 temperaturas del baño de zinc
library(rpart)
#construir arbol maximo
treefull <- rpart(factor(calidad)~ .,data=datos, method="class", cp=0.001)
plotcp(treefull)
#seleccionar el arbol de xerror minimo
printcp(treefull)
library(rpart.plot)
prp(treefull, extra=101)
#podar el arbol
tree2<-prune.rpart(treefull, cp=0.10870)# cp del mínimo xerror
tree22<-prune.rpart(treefull, cp=0.11)# cp un poco superior al del mínimo xerror
# Ambos podrucen el mismo gráfico
par(mfrow = c(1, 2))# Una fila, dos columnas
prp(tree2,extra=101)
prp(tree22,extra=101)
library(DMwR2)
tree3<-rpartXse(factor(calidad)~ .,data=datos,model= TRUE) 
prp(tree3,extra=101)

#MATRIZ DE CONFUSIÓN
#obtención de la predicción de la clase
pred <- predict(tree2, datos)#predice en probabilidad por defecto
dim(pred)# predice la prob de 0 y de 1
pred2 <- predict(tree2, datos, type="class")#predicción de la clase
#la predicción en clase es equivalente a lo siguiente
clase<-pred[,2]
clase[pred[,2]>0.5]<-1 #este punto de corte puede variarse como luego veremos en la ROC
clase[pred[,2]<=0.5]<-0
#comprobamos que es lo mismo
table(clase,pred2)
#matriz de confusión
tab <- table(clase, datos[,6]) #tabla cruzada de predicciones y clasificación real
tab
#tasa de acierto
sum(tab[row(tab)==col(tab)])/sum(tab)
#obtener la tasa de fallo
sum(tab[row(tab)!=col(tab)])/sum(tab)
library(caret)
confusionMatrix(pred2, factor(datos$calidad), positive= "1")#esta función necesita que sean factores

########################
# random forest
########################

library(randomForest)
#mostrar las variables
head(datos)
#notar que el random forest he de ponerle que es factor la variable dep
#mtry=2 raiz(5) donde 5 es el num de var indep
rf.calidad<-randomForest(factor(calidad)~ ., data=datos,mtry=2,method="class",importance=TRUE) 
# Plot variable importance
varImpPlot(rf.calidad, main="",col="dark blue")
clase <- predict(rf.calidad, datos, type="class")#predice la clase
#matriz de confusión
class(clase)
c.rf <-confusionMatrix(clase,factor(datos$calidad), positive= "1")
c.rf$overall
c.rf$overall[1]
c.rf$byClass

#randomForest sigue funcionando, pero ranger es más rápido, maneja mejor datasets 
# medianos/grandes y es el estándar actual en R para RF.
library(ranger)
rf_ranger <- ranger(calidad ~ ., data = datos, probability = TRUE,
                    mtry = 2, num.trees = 500, importance = "impurity")
pred_prob <- predict(rf_ranger, datos)$predictions[, "1"]
pred_class <- ifelse(pred_prob > 0.5, "1", "0")
caret::confusionMatrix(factor(pred_class), factor(datos$calidad), positive="1")


#######################
#Bagging
#####################
library(ipred)
datos$calidad<-factor(datos$calidad)
bag.calidad <- bagging(calidad ~., data=datos, coob=TRUE)#no puedes ponerle el factor dentro de la fórmula da error
bag.calidad 
clase <- predict(bag.calidad, datos) 
#matriz de confusión
confusionMatrix(clase,factor(datos$calidad), positive= "1")
#obtener la tasa de acierto y de fallo

#######################
#Boosting
#####################
library(adabag)
bot.calidad  <- boosting(calidad ~., data=datos, coob=TRUE)
bot.calidad
pred <- predict(bot.calidad, datos) #pred es una lista y has que acceder a las clase predicha
#matriz de confusión
confusionMatrix(as.factor(pred$class),factor(datos$calidad), positive= "1")

#######################
#vecino mas proximo
#####################
library(class)
#requiere reescalado
sdatos <- scale(subset(datos, select = -calidad))
#estamos utilizando knn para predecir todos los datos
# si miramos la ayuda de knn el primer argumento es train y el segundo test
vecino<-knn(sdatos,sdatos, cl=factor(datos$calidad), k = 3, prob = TRUE)
#matriz de confusion
confusionMatrix(vecino[1:48],factor(datos$calidad), positive= "1")

#################
#Naive Bayes
###########
library(e1071)
nbayes <- naiveBayes(factor(calidad)~ ., data=datos) 
summary(nbayes)
clase <- predict(nbayes, datos)
confusionMatrix(clase, factor(datos$calidad), positive= "1")

## using Laplace smoothing: 
model <- naiveBayes(factor(calidad)~ ., data=datos, laplace = 3)
clase <- predict(model, datos) 
confusionMatrix(clase, factor(datos$calidad),  positive= "1")
#############
#SVM
#############
library("kernlab")
svp <- ksvm(factor(calidad)~ ., data=datos, type = "C-svc", kernel = "rbfdot",kpar = "automatic")
summary(svp)
clase <- predict(svp, datos) 
confusionMatrix(clase, factor(datos$calidad), positive= "1")

library("e1071")
model <- svm(factor(calidad)~ ., data = datos, method = "C-classification", kernel = "radial",cost = 10, gamma = 0.1)
summary(model)
summary(datos)
clase <- predict(model, datos) 
confusionMatrix(clase, factor(datos$calidad), positive= "1")

# PARTIAL DEPENDENT PLOT
library(pdp)
# Si el modelo es de clasificación y la variable respuesta tiene múltiples clases, 
#la función calcula el gráfico para la clase predeterminada (normalmente la primera clase).
partialPlot(rf.calidad, datos, "Vmedia") 
partialPlot(rf.calidad, datos, "Vmedia", "0")#es igual que el de arriba
#el gráfico se centrará en cómo "Vmedia" afecta las probabilidades o la clasificación de la clase "1".
partialPlot(rf.calidad, datos, "Vmedia", "1")#cuando aumenta la Vmedia aumenta la prob de defectuosa 

partialPlot(rf.calidad, datos, "T1", "1")#cuando aumenta la Vmedia aumenta la prob de defectuosa 


#############
#GLM REGRESIÓN LOGIT
#############
summary(datos)
glm.calidad <- glm(factor(calidad)~ ., data=datos, family=binomial(link = logit))
summary(glm.calidad)
final.model<-step(glm.calidad)
pred <- predict(final.model, datos) #no es la predicción en clase ni en probabilidad
pred <- predict(final.model, datos, type="response") #pred es el vector que indica la prob de pertenecer a la clase 1
clase<-pred
clase[pred>0.5]<-1 #este punto de corte puede variarse como luego veremos en la ROC
clase[pred<=0.5]<-0
confusionMatrix(factor(clase), factor(datos$calidad), positive= "1")



