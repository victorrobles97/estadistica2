rproject@socialdata-peru.com
msiguena@socialdata-peru.com
936922548


install.packages("foreign")
library(foreign)

Democracias = read.spss("D:/R/1. Nivel I/3/data/Democracias.sav", 
                        to.data.frame=TRUE)

head(Democracias)

# install.packages("haven")
library(haven)
setwd("D:/R/1. Nivel I/3/data/")
Fragilidad = read_spss("FragilidadEstatal.sav")

head(Fragilidad)

# install.packages("haven")
library(haven)

Osinergmin = read_dta("C:/Users/Victor/Desktop/sesion3/ERCUE-2016-Hogares.dta")

head(Osinergmin)

Osinergmin1 = read_stata("C:/Users/Victor/Desktop/sesion3/ERCUE-2016-Hogares.dta")

head(Osinergmin1)

# install.packages("readr")
library(readr)

datos = read.csv2("D:/R/1. Nivel I/3/data/DataKeiko.csv", encoding="UTF-8")

head(datos)

# install.packages("readxl")
library(readxl)

LL1 = read_excel("D:/R/1. Nivel I/3/data/LL1.xlsx",sheet = "base")

head(LL1)

# install.packages("rjson")
library("rjson")

# install.packages("jsonlite")
library("jsonlite")

Subvenciones = fromJSON("D:/R/1. Nivel I/3/data/subvenciones.json", flatten=TRUE)

colnames(Subvenciones)

head(Subvenciones)

#install.packages("RPostgreSQL")
require("RPostgreSQL")

# Guardar el Password para poder posteriormente eliminarlo
pw <- { "sdc2019PERU"}

# Leer el driver de PostgreSQL
drv <- dbDriver("PostgreSQL")

# Crear la conexion con la base de datos
con <- dbConnect(drv, dbname = "alumno",
                 host = "69.164.192.245", port = 5432,
                 user = "postgres", password = pw)

# Eliminar el Password
rm(pw) 

# Extraer datos de la base de datos
datos1 <- dbGetQuery(con, "SELECT * from tabla_bupa")

head(datos1)


