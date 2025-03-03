# Mini-Projeto 3 - Planejamento de Carreira para Pessoas
# A An�lise Estat�stica em Avalia��es Anuais de Desempenho foi reutilizada para basear o sal�rio em rela��o a educa��o.

# Neste Mini-Projeto nosso objetivo � aplicar an�lise estat�stica em dados de sal�rio em rela��o a educa��o em busca de prov�vel correla��o entre n�vel educacional e sal�rio.

# Diret�rio de trabalho
#getwd()
#setwd("~/Dropbox/DSA/AnaliseEstatisticaI/Modulo09/Mini-Projeto3")

# Pacotes
library(ggplot2)
library(dplyr)
library(GGally)
library(pscl)
library(ROCR)


########## Carregando os Dados ########## 

# Carregando os dados que foram salvos ao final do script da Parte 1.
dados_aval = read.csv("C:/Users/Sheila Dias/Downloads/NYC_Jobs3.csv", sep = ',', stringsAsFactors = TRUE)

# Removemos a primeira coluna por ser �ndice
df_aval <- dados_aval

# Tipos de dados
str(df_aval)

# Sum�rio
summary(df_aval)

# Visualiza os dados
View(df_aval)

view(df_aval_saida_positiv)
?view #data$Recruitment.Contact <- NULL

install.packages("dplyr")

#df_aval1 <- data$Recruitment.Contact <- NULL

#view(df_aval)

#foram tratados dados, retiradas letras do data set de n�veis: para n�o termos n�vel 0, acrescentamos 1 aos n�veis.
#os cargos gerenciais, foram retiradas a letra M de Manager e os cargos de diretoria que estavam com Y, colocamos 6 para virar 7.

#mtcars[ ,c("Level")]
#na.omit(df_aval["Salary.Range.From"])

#df_aval <- na.omit(df_aval["Salary.Range.To", "Salary.Range.From"])
#names(df_aval)

#df_aval <- na.omit(df_aval["Level","Career.Level"])



#df_aval <- mtcars[ ,c("Level")] # seleciona quatro colunas

# Nomes das colunas
names(df_aval)


########## Correla��o ########## 

# Vamos analisar a Correla��o entre algumas das vari�veis num�ricas
ggpairs(df_aval, columns = c("Career.Level",
                             "Salary.Range.From",
                             "Salary.Range.To",
                             "Level"))

# Para interpretar as correla��es, analise o gr�fico observando linhas e colunas 
# (o conceito de correla��o foi abordado na aula 5):

# A primeira visualisa��o de correla��o mostrava que existia um vale entre os n�veis de carreira. Precisa passar alguma
#ferramenta de limpeza ou de transforma��o antes de rodar o GGpairs novamente.

# Ao rodar o NA omit para excluir os NAs havia nas em todas as colunas. precisa primeiro excluir algumas colunas.
#Para selecionar as quatro colunas usar o comando MTCARS:
mtcars[,c("Level")]

names(df_aval)

#Utilizamos o excel para limpeza dos NAs e para tratamento de alguns dados missings e com textos misturados, para
#excluir colunas em branco e tambem perdemos 14 linhas que ainda continha dados com d�zimas peri�dicas.
# Os dados com d�zimas peri�dicas foram removidos automaticamente pela biblioteca stat_density do R as demais 12 foram removidas
#pela biblioteca ggally_statistic (data, mapping, na.rm, geom_point).


names(df_aval) # Mas o mais importante: quando um funcion�rio estava insatisfeito, ele deixou a empresa.


########## Teste t Para Confirmar a Hip�tese ########## 

# Vamos realizar um teste t com n�vel de confian�a de 95% e ver se ele rejeita corretamente 
# a hip�tese nula de que a amostra vem da mesma distribui��o que a popula��o de funcion�rios. 
#Aplicando NA omits para excluir as linhas que contem NA:

#df_aval <-na.omit(df_aval)

#ggpairs(df_aval, columns = c("Career.Level",                              "Salary.Range.From",                             "Salary.Range.To",
                # "Level"))
# Primeiro, vamos analisar o sal�rio m�dio das carreiras
names(df_aval)
salarioinicial_media <- mean(df_aval$Salary.Range.From)
salarioinicial_media

salariomaximo_media <- mean(df_aval$Salary.Range.To)
salariomaximo_media


# Para isso, criamos um subset somente com vari�vel target igual a 1.
df_aval_saida_positiv <- subset(df_aval, Salary.Range.From > salariomaximo_media)
view(df_aval_saida_positiv)

# E ent�o calculamos a satisfa��o m�dia desse grupo
satisfacao_media_func_saiu_empresa <-mean(df_aval_saida_positiv$nivel_satisfacao)
satisfacao_media_func_saiu_empresa

# Os resultados s�o coerentes, pois cerca de 44% de satisfa��oo m�dia para quem saiu da empresa 
# faz sentido. Vamos ao teste t.

# Teste t de uma amostra 
?t.test
t.test(df_aval_saida_positiv$nivel_satisfacao, mu = satisfacao_media)

# Valor-p < 0.05 indica que h� evid�ncia estat�stica para rejeitarmos a hip�tese nula.
# A hip�tese nula � que a amostra vem da mesma distribui��o que a popula��o de funcion�rios.

# Teste t de duas amostra s
t.test(df_aval_saida_positiv$nivel_satisfacao, df_aval$nivel_satisfacao)

# Valor-p < 0.05, rejeitamos a hip�tese nula.


########## Constru��o do Modelo ########## 

# Criaremos um modelo para prever se o funcion�rio vai ou n�o deixar a empresa.

# Vari�vel target: saida
# Vari�veis preditoras: nivel_satisfacao, ultima_avaliacao, media_mensal_horas, salario e num_projetos

# Dimens�es do dataset original
dim(df_aval)

# Como vamos prever a sa�da, essa ser� nossa vari�vel alvo
# Vamos convert�-la para o tipo fator
df_aval$saida <- factor(df_aval$saida)

# Vamos checar as propor��es das classes
table(df_aval$saida)

# Temos 0 como a classe negativa e 1 como a classe positiva.
# Sendo assim, 12185 funcionários não deixaram a empresa, enquanto 3813 deixaram a empresa.

# Divis�o dos dados em treino e teste
dados_treino <- df_aval[1:12000,]
dados_teste <- df_aval[12001:15998,]

# Dimens�es
dim(dados_treino)
dim(dados_teste)

# Cria��o do modelo
# Usaremos a fun��o glm() para um modelo de regress�o log�stica bin�ria
names(df_aval)
?glm
modelo_func_v1 <- glm(saida ~ nivel_satisfacao + 
                        ultima_avaliacao + 
                        media_mensal_horas + 
                        salario + 
                        num_projetos,
                   data = dados_treino,
                   binomial())

# Sum�rio do modelo
summary(modelo_func_v1)

# Os 3 asteriscos ao lado de cada vari�vel e o valor-p baixo indicam que todas as vari�veis preditoras
# s�o relevantes para prever a vari�vel de sa�da.

# Previs�es com o modelo 
previsoes_v1 <- predict(modelo_func_v1, newdata = dados_teste, type = 'response')
previsoes_v1

# Definindo os limites das previs�es das classes
# Como as previs�es est�o no formato de probabilidade, vamos definir um limite e gerar a previs�o# de classe final. Se a probabilidade for maior que 0.55, classificamos como positivo,
# caso contr�rio como negativo.
previsoes_v1 <- ifelse(previsoes_v1 > 0.55, 1, 0)
previsoes_v1

# Vamos avaliar o modelo
erro_modelo_v1 <- mean(previsoes_v1 != dados_teste$saida, na.rm = T)
print(paste('Acur�cia do Modelo', 1 - erro_modelo_v1))

# Nosso modelo � capaz de prever com aproximadamente 79% de precis�o.

# Vamos criar o plot da Curva ROC e calcular a métrica AUC.
p <- predict(modelo_func_v1, newdata = dados_teste, type="response")
pr <- prediction(p, dados_teste$saida)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc

# As m�tricas n�o est�o ruins, vamos tentar melhorar. Criaremos a segunda versão do modelo, 
#dessa vez mudando a estratégia de divis�o dos dados de treino e de teste.

# Definindo o tamanho da divis�o dos dados para 80/20
data_size <- ceiling(0.8 * nrow(df_aval))

# Divis�o em treino e teste
set.seed(100)
indice <- sample(seq_len(nrow(df_aval)), size = data_size)
dados_treino <- df_aval[indice, ]
dados_teste <- df_aval[-indice, ]

# Dimens�es
dim(dados_treino)
dim(dados_teste)

# Inclus�o de vari�veis
names(df_aval)
modelo_func_v2 <- glm(saida ~ nivel_satisfacao + 
                        ultima_avaliacao + 
                        num_projetos + 
                        media_mensal_horas + 
                        tempo_empresa + 
                        acidente_trabalho + 
                        promocao_5_anos + 
                        salario,
                      data = dados_treino,
                      binomial())

# Sum�rio do modelo
summary(modelo_func_v2)

# previs�es com o modelo
previsoes_v2 <- predict(modelo_func_v2, newdata = dados_teste, type = 'response')
previsoes_v2 <- ifelse(previsoes_v2 > 0.55, 1, 0)

# Avalia��o do modelo
erro_modelo_v2 <- mean(previsoes_v2 != dados_teste$saida, na.rm = T)
print(paste('Acur�cia do Modelo', 1 - erro_modelo_v2))

# Tivemos uma pequena redu��o na acur�cia. Mas e o AUC?

p <- predict(modelo_func_v2, newdata = dados_teste, type = "response")
pr <- prediction(p, dados_teste$saida)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc

# Nosso modelo tem agora uma performance global melhor, ou seja, um modelo mais 
# est�vel e generaliz�vel.

# Voc� pode agora usar o modelo com dados de novos funcion�rios e ent�o prever se
# eles deixar�o a empresa ou n�o.


# Conclus�o

# Para resumir nossa an�lise sobre porque os funcion�rios deixam a empresa, dentre todos os fatores que contribuem
# o preditor mais forte � o n�vel de satisfa�ao do funcion�rio.

# Em geral, os funcion�rios saem quando est�o com excesso de trabalho (mais de 250 horas de m�dia mensal de trabalho) 
# ou com trabalho insuficiente (menos de 150 de m�dia mensal de trabalho).

# Empregados com avalia��es baixas ou muito altas provavelmente sair�o da empresa.

# Empregados com sal�rios baixos ou m�dios deixam a empresa.

# Empregados que tiveram menos (3 ou menos) ou mais (6 ou mais) projetos provavelmente deixar�o a empresa.







