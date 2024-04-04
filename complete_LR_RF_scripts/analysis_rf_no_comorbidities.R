library(randomForest)
library(doParallel)
library(ROCR)
library(dplyr)
setwd('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/')
library(caret)
source('analisi_RF_myOpti.R')
source('compute_perf_eval.R')


unregister_dopar <- function() {
  env <- foreach:::.foreachGlobals
  rm(list=ls(name=env), pos=env)
}

prepare_LR_df = function(glm_fit, nDigits = 4){
  
  my_summary = summary(glm_fit)
  x = my_summary$coefficients
  
  logodds_vals <- coef(glm_fit) 
  confint_vals = tryCatch(confint(glm_fit), error = function(e) e)
  if(inherits(confint_vals, "error")) {
    cat('error in LR confint computation\n')
    return(data.frame("logodds" = -1,
                              "logodds_min" = -1,
                              "logodds_max" = -1, "odds"=-1, 
                              "odds_min"=-1, "odds_max"= -1, "se" = -1))
  }else{
    logodds_vals = cbind(logodds_vals, confint_vals)
  }
#  print(logodds_vals)
  exp<-round(exp(logodds_vals),2)
  # to extract the standard error
  # format glm output to send to ggplot forestplot
  #        print(logodds_vals)
  df_LR <- round(data.frame("logodds" = logodds_vals[,1],
                            "logodds_min" = logodds_vals[,2],
                            "logodds_max" = logodds_vals[,3], "odds"=exp[,1], 
                            "odds_min"=exp[,2], "odds_max"=exp[,3], "se" = x[,2]),nDigits)
  
  df_LR$label <- row.names(exp)
  df_LR$pvalue <- signif(coef(summary(glm_fit))[,4], digits=nDigits)
  return(df_LR)
}

#gc()
#rm(list = ls())
#setwd('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/')
#source('analysis_rf_no_comorbidities.R')
#analysis_rf(maxVars = 31)
analysis_rf <- function(feature_selection_method = 'glmnet', nDigits = 4, maxVars = 100, 
                        n_internal_iters = 101,
                        n_external_iters = 51){
  
  label_cols = c('he_m091_uterine_tumors','he_m092_ovarian_cysts', 'he_m089_endometriosis', 'he_m090_uterine_polyps')
  load('data.Rda')
  
  little_df = little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')]
  row.names(little_df) = little.df.cleaned[['epr_number']]
  
  sds = apply(little_df, 2, sd)
  little_df = little_df[, which(sds>0.02)]
  #outcomes =  little_df[, little_df %in% label_cols]
  prefixes = c('he_', 'CHEBI_', 'ea_', 'eb_')
  for (pref in prefixes){
    dir_res = file.path(getwd(), paste(feature_selection_method, 'results_', pref, sep =''))
    if (!dir.exists(dir_res)) dir.create(dir_res)
    mega.df.res = data.frame()
    mega.detailed.df.res = data.frame()
    for (outcome in label_cols){
       cat('starting analysis on ', outcome, '\n')
       use_df = little_df %>% select(starts_with(c(pref, outcome)))
        perc_pos = sum(use_df[[outcome]])/nrow(use_df)
        print(length(use_df[[outcome]]))
        use_df[[outcome]] = factor(use_df[[outcome]])
        print(min(table(use_df[[outcome]]))/nrow(use_df))
        str_desc = paste(outcome, '_', pref, sep = '')
        fn_importances = file.path(dir_res, paste('res_RF_', str_desc,'_importances.csv', sep=''))
        if (file.exists(fn_importances)){
          cat('importances already existing; I will use them to  run an LR\n')
          df_imp = read.csv(file = fn_importances)
          row.names(df_imp) = df_imp$X
          df_imp = df_imp[, !(names(df_imp) %in% c('X'))]
        }else{
          res = analisi_RF_myOpti(df = use_df, feature_selection_method = feature_selection_method,
                                  n_internal_iters = n_internal_iters, n_external_iters = n_external_iters, 
                                  outcome = outcome, 
                              str_desc = str_desc, 
                              save_path = dir_res,
                              verbose = 1, mtry = 3, ntree = 1001)
          
          df_imp = res[['importances']]
          mean_res = res[['mean_over_holdouts']] 
          detailed_res = res[['all_holdouts']]
         
          mega.df.res = rbind(mega.df.res,cbind(outcome = outcome, perc_pos= perc_pos, mean_res))
          mega.detailed.df.res = rbind(mega.detailed.df.res, cbind(outcome = outcome, perc_pos= perc_pos, mean_res))
          cat('results until now:\n')
          print(mega.df.res)        
        }
        
        df_imp = df_imp[order(df_imp$MeanDecreaseAccuracy, decreasing = TRUE), ]
        df_imp = df_imp[1:min(nrow(df_imp), maxVars), ]
        use_df_LR = use_df
        
        # analize only important variables with Logistic regression
        for (j in 1: n_internal_iters)  {      
          balanced_df = caret::downSample(use_df_LR, use_df_LR[[outcome]], list = FALSE)
          balanced_df[[outcome]] = as.numeric(balanced_df[[outcome]] ==1)
          glm_fit =  glm(as.formula(paste(outcome, '~', paste(rownames(df_imp), collapse = '+'))), 
                       family=binomial(link="logit"), data=balanced_df)
        
          df_LR = prepare_LR_df( glm_fit, nDigits = nDigits)
          print(df_LR)
        }
        writexl::write_xlsx(df_LR, file.path(dir_res, paste(outcome, '_balancedLR_results_', pref, '.xlsx', sep ='')))
        

    }
    fn_mega_df_res = file.path(dir_res, paste('RF_performance_', pref, '.xlsx', sep =''))
    fn_detailed_df_res = file.path(dir_res, paste('detailed_RF_performance_', pref, '.xlsx', sep=''))
    if (!file.exists(fn_mega_df_res)){
      cat('saving results \n')
      writexl::write_xlsx(mega.df.res, fn_mega_df_res)
      writexl::write_xlsx(mega.detailed.df.res, fn_detailed_df_res )
      cat('results saved\n')
    }else{
      cat('file already existing; I will not overwrite importances!\n')
    }
  }
}