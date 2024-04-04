library(randomForest)
library(doParallel)
library(ROCR)
setwd('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/')
source('analisi_RF_myOpti.R')
source('compute_perf_eval.R')


unregister_dopar <- function() {
  env <- foreach:::.foreachGlobals
  rm(list=ls(name=env), pos=env)
}

analysis_rf <- function(){
  label_cols = c('he_m091_uterine_tumors','he_m092_ovarian_cysts', 'he_m089_endometriosis', 'he_m090_uterine_polyps')
  load('data.Rda')
  
  little_df = little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')]
  row.names(little_df) = little.df.cleaned[['epr_number']]
  
  sds = apply(little_df, 2, sd)
  little_df = little_df[, which(sds>0.02)]
  #outcomes =  little_df[, little_df %in% label_cols]

  mega.df.res = data.frame()
  mega.detailed.df.res = data.frame()
  for (outcome in label_cols){
     cat('starting analysis on ', outcome, '\n')
      perc_pos = sum(little_df[[outcome]])/nrow(little_df)
      little_df[[outcome]] = factor(little_df[[outcome]])
      print(min(table(little_df[[outcome]]))/nrow(little_df))
      res = analisi_RF_myOpti(df = little_df, n_internal_iters = 51, n_external_iters = 21, outcome = outcome, 
                          str_desc = outcome, verbose = 1, mtry = 3, ntree = 1001)
      
      
      mean_res = res[['mean_over_holdouts']] 
      detailed_res = res[['all_holdouts']]
      
      mega.df.res = rbind(mega.df.res,cbind(outcome = outcome, perc_pos= perc_pos, mean_res))
      mega.detailed.df.res = rbind(mega.detailed.df.res, cbind(outcome = outcome, perc_pos= perc_pos, mean_res))
      cat('results until now:\n')
      print(mega.df.res)
  }
  cat('saving results \n')
  writexl::write_xlsx(mega.df.res, 'RF_performance_2023_02_05.xlsx')
}