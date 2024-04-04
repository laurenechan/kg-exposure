setwd('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/')
label_cols = c('he_m090_uterine_polyps', 'he_m091_uterine_tumors','he_m092_ovarian_cysts', 'he_m089_endometriosis')
load('data.Rda')
mega_df = mega.df.cleaned[, !(names(mega.df.cleaned) %in% 'epr_number')]
row.names(mega_df) = mega.df.cleaned[['epr_number']]
mega_df = apply(mega_df,2, as.numeric)
cor_mat = as.matrix(cor(mega_df))
cor_mat_selection = data.frame(cor_mat[, colnames(cor_mat) %in% label_cols])
cor_mat_selection[['var_names']] = row.names(cor_mat_selection)
writexl::write_xlsx(cor_mat_selection, path = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/mega_df_correlation.xlsx')



little_df = little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')]
row.names(little_df) = little.df.cleaned[['epr_number']]
little_df = apply(little_df,2, as.numeric)
cor_mat = as.matrix(cor(little_df))
cor_mat_selection = data.frame(cor_mat[, colnames(cor_mat) %in% label_cols])
cor_mat_selection[['var_names']] = row.names(cor_mat_selection)
writexl::write_xlsx(cor_mat_selection, path = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/little_df_correlation.xlsx')
cat('finished')

library(glmnet)

#x_mat = as.matrix(little_df[, !(names(little_df) %in% label_cols)])
#res_endo = glmnet(x_mat, little_df[['he_m089_endometriosis']], family = "binomial", alpha = 1)

x_mat = little_df[, which(!(colnames(little_df) %in% label_cols))]
sds = apply(x_mat, 2, sd)
x_mat = x_mat[, which(sds>0.02)]
y = little_df[, 'he_m089_endometriosis']
cvfit = cv.glmnet(x_mat, y, family = "binomial", alpha = 0.25)
x = coef(cvfit, s = "lambda.min" )
x = x[,1]
x[abs(x)>0]


library(glmnetSE)

food_var = colnames(x_mat)[grepl('eb_', colnames(x_mat))]

cvfit = glmnetSE(cbind(y,x_mat), cf.no.shrnkg = food_var, alpha = 0.5, r = 11,method = '10CVoneSE', family = 'binomial', perf.metric = 'auc', ncore = 2)
coef(cvfit)


library(randomForest)

rf =randomForest(x=x_mat, y = factor(y), ntree = 501, strata = factor(y), sampsize= min(sum(y==1), sum(y==0)), importance = TRUE)
df_save = data.frame('importance'=rf$importance[, "MeanDecreaseAccuracy"])
df_save['vars'] = names(rf$importance[, 'MeanDecreaseAccuracy'])

writexl::write_xlsx(df_save, 'importances.xlsx')


