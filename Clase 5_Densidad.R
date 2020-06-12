#ELIGIENDO EL MEJOR CLUSTER SEGUN PARTICIÓN Y JERÁRQUICA

library(stringr)
library(magrittr)
library(htmltab)
library(factoextra)
library(cluster)
library(ggrepel)
library(foreign)

data<-read.spss(
  "Cosmetic Surgery_BASE.sav", 
  to.data.frame=TRUE)

names(data)
data<-na.omit(data)#para omitir NA
data=data[-5,]
data
row.names(data)=data$Id
data$Id=NULL
str(data)
data
data=na.omit(data)

data=data[,-c(3,7,8)]

str(data)

g.dist = daisy(data, metric="gower")

#Número de clusters recomendados para partición

fviz_nbclust(data, pam,diss=g.dist,method = "gap_stat",k.max = 10,verbose = F)

#Número de clusters para jerarquización

fviz_nbclust(data, hcut,diss=g.dist,method = "gap_stat",k.max = 10,verbose = F)

#Criterios

res.pam = pam(g.dist,5,cluster.only = F)
res.agnes = hcut(g.dist, k = 7,hc_func='agnes',hc_method = "ward.D")
res.diana = hcut(g.dist, k = 7,hc_func='diana')

fviz_silhouette(res.pam)
fviz_silhouette(res.agnes)
fviz_silhouette(res.diana)

#EVALUACION NUMÉRICA
#Esta etapa es para identificar a los casos mal asignados: los que tienen silueta negativa

#creando un data frame

#DIANA
head(res.diana$silinfo$widths)
poordiana=data.frame(res.diana$silinfo$widths)
poordiana$Id=row.names(poordiana)

poordianacases=poordiana[poordiana$sil_width<0,'Id']
poordianacases

#cantidad
length(poordianacases)

#AGNES
poorAGNES=data.frame(res.agnes$silinfo$widths)
poorAGNES$Id=row.names(poorAGNES)
poorAGNEScases=poorAGNES[poorAGNES$sil_width<0,'Id']
poorAGNEScases
length(poorAGNEScases)

#PAM
poorPAM=data.frame(res.pam$silinfo$widths)
poorPAM$Id=row.names(poorPAM)
poorPAMcases=poorPAM[poorPAM$sil_width<0,'Id']
poorPAMcases
length(poorPAMcases)

#CASO MAL ASIGNADO ES LAZARO. No hay necesidad de intersección


######CLUSTER SEGUN DENSIDAD#######

#necesitamos un mapa de posiciones para todos los casos
#usamos el escalamiento multidimensional

proyeccion = cmdscale(g.dist, k=2,add = T) #k es el número de dimensiones
data$dim1 <- proyeccion$points[,1]
data$dim2 <- proyeccion$points[,2]

#GRAFICANDO

base= ggplot(data,aes(x=dim1, y=dim2,label=row.names(data))) 
base + geom_text(size=2)

#Coloreando el mapa#

#Creemos primero las columnas 
data$pam=as.factor(res.pam$clustering)
data$agnes=as.factor(res.agnes$cluster)
data$diana=as.factor(res.diana$cluster)

#Estimando límites

min(data[,c('dim1','dim2')]); max(data[,c('dim1','dim2')])

#GRAFICAS PARA PAM AGNES Y DIANA

limites=c(-0.4,0.4)

base= ggplot(data,aes(x=dim1, y=dim2)) + ylim(limites) + xlim(limites) + coord_fixed()

base + geom_point(size=2, aes(color=pam))  + labs(title = "PAM") 
base + geom_point(size=2, aes(color=agnes)) + labs(title = "AGNES")
base + geom_point(size=2, aes(color=diana)) + labs(title = "DIANA")


#AHORA POR FIN USAMOS DBSCAN PARA VER LA DENSIDAD#

#Calculando nuevas distancias
g.dist.cmd = daisy(data[,c('dim1','dim2')], metric = 'euclidean')

#CALCULANDO EL EPS

library(dbscan)
kNNdistplot(g.dist.cmd, k=5)
abline(h=0.18, lty=2)

#OBTENIENDO LOS CLUSTERS DE DENSIDAD
install.packages("fpc")
library(fpc)
db.cmd = dbscan(g.dist.cmd, eps=0.18, MinPts=5, method = 'dist')
db.cmd

#Pongamos esos valores en otra columna:
data$dbCMD=as.factor(db.cmd$cluster)

#GRAFICANDO
install.packages("ggrepel")
library(ggplot2)
library(ggrepel)
base= ggplot(data,aes(x=dim1, y=dim2)) + ylim(limites) + xlim(limites) + coord_fixed()
dbplot= base + geom_point(aes(color=dbCMD)) 
dbplot

#graficando con texto de los casos
dbplot + geom_text_repel(size=5,aes(label=row.names(data)))

#SOLO LOS ATIPICOS

LABEL=ifelse(data$dbCMD==0,row.names(data),"")
dbplot + geom_text_repel(aes(label=LABEL),
                         size=5, 
                         direction = "y", ylim = 0.45,
                         angle=45,
                         segment.colour = "grey")
