library(Boruta)
library(randomForest)
library(glmnet)
source('feature_selection.R')
source('evaluate_ntree_mtry.R')


analisi_RF_myOpti <- function(df, 
                              maxNumVar = Inf, minNumVar = 2,
                              pos_label = levels(df[[outcome]])[2], 
                              neg_label = levels(df[[outcome]])[1], 
                              outcome = 'Activity', idvar = 'Patient_ID',
                              save_path = './', str_desc ='data', verbose = 0, 
                              perc_samples = 0.8, 
                              ratio_train = 0.9,
                              n_internal_iters = 51, 
                              n_external_iters = 10, 
                              ntree = NA, mtry = NA,
                              feature_selection_method = 'RF_importance',
                              seed = Inf, thr_prob = 0.5, 
                              measures = c("auc", "aucpr", "f", "sens", "spec"), opti_meas = "aucpr"){
  
  # se seed ? Inf non viene settato e gli holdout cambiano sempre!
  #feature_selection may be = 'RF_importance', 'boruta', 'glmnet'
  
  n_internal_iters = min(n_internal_iters, ncol(df)*10)
  all_combs = NULL
  nneg = sum(df[[outcome]]!= pos_label)
  npos = sum(df[[outcome]]== pos_label)
  
  cat('\n\nstarting (not optimized) analysis with matrix ', str_desc, ' - dim = ', dim(df),  '\n')
  cat('pos label =', pos_label, ' (npos =', npos,' ) -  neg label = ', neg_label, ' (nneg = ', nneg, ')\n')
  
  
  #df = df[complete.cases(df), ]
  
  names_vars = names(df[, !(names(df) %in% c(idvar, outcome))])
  
  
  df_imp <- data.frame(matrix(0, nrow = length(names_vars), ncol = 2))
  row.names(df_imp) <- names_vars
  names(df_imp) = c("MeanDecreaseAccuracy", "MeanDecreaseAccuracy_SD")
  
  all_perf = data.frame()  
  #if (is.finite(seed)) set.seed(seed) # to reproduce the same holdouts
  folds <- caret::createDataPartition(df[[outcome]], times = n_external_iters, 
                                      p = ratio_train, list = TRUE);
  
  
  for (niter in 1:n_external_iters) {
    if (verbose ==1) cat('external holdout no = ', niter, '\n')
    
    train_idx = folds[[niter]]
    df_test = df[-train_idx, ]
    df_train = df[train_idx, ]
    
    nneg_train = sum(df_train[[outcome]]!= pos_label)
    npos_train = sum(df_train[[outcome]]== pos_label)
    
    if (verbose ==1) cat(niter, '] nneg_train =', nneg_train,'- npos_train = ', npos_train, '\n') 
    
    
    selected_vars = feature_selection(df_train, feature_selection_method = feature_selection_method,
                                       minNumVar = 2, maxNumVar = nrow(df)-1, perc_samples = perc_samples, 
                                        outcome = outcome, idvar = idvar, n_internal_iters = n_internal_iters,
                                       pos_label = pos_label)
    
    nvar = length(selected_vars) 
    if (verbose==1){
      cat(nvar , ' features selected \n')
    }
    
    # use only selected vars
    df_train = df_train[, names(df_train) %in% c(selected_vars, outcome)]
    df_test = df_test[, names(df_test) %in% c(selected_vars, outcome)]
    
    if (is.na(mtry) | is.na(ntree)){
      cat('starting hyperparameter selection .... \n')
      mtry_candidate = round(sqrt(nvar))
      for (ff in c(2, 3, 5, 7)){
        #cat(ff , ' - ', round(nvar*ff), '\n')
        mtry_candidate = c(mtry_candidate ,ifelse(round(nvar/ff)>round(sqrt(nvar)), round(nvar/ff), -1))
      }
      mtry_candidate = unique(mtry_candidate[mtry_candidate>1])
  
      if (nvar > 10){
        ntree_candidate = c(501, 1001, 1251, 1501)
        
      }else{
        ntree_candidate = c(31, 101, 201, 501)
        
      }
      
      ntree_mtry_candidate = cbind(expand.grid(ntree_candidate,mtry_candidate))
      names(ntree_mtry_candidate) = c("ntree", "mtry")
      
      #set.seed(seed)
      
      
      best_comb = evaluate_ntree_mtry(df_train = df_train, outcome = outcome, 
                                      neg_label = neg_label, pos_label = pos_label,
                                      nneg_train = nneg_train,
                                      npos_train = npos_train,
                                      use_vars = selected_vars,
                                      n_internal_iters = n_internal_iters, 
                                      ntree_mtry_candidate = ntree_mtry_candidate, 
                                      opti_meas = 'aucpr', perc_samples = perc_samples,
                                      ratio_train = ratio_train, verbose = 0 )
    }else{
      cat('avoiding hyperparameter selection and using values ')
      best_comb = matrix(0, ncol = 2, nrow = 1)
      best_comb[1, ] = c(ntree, max(3, round(nvar/mtry)))
      colnames(best_comb) = c('ntree', 'mtry')
      cat(best_comb, '\n')
    }  
      
      all_combs = rbind(all_combs, best_comb)
      if (verbose ==1) {
        print(best_comb) 
        cat( ' selected as best parameters\n')
      }
  
    # potresti semplicemente eliminare l'outcome variable
    x = df_train[, names(df_train) %in% selected_vars] 
    y = df_train[[outcome]]
    nsamp = floor(min(table(y))*perc_samples)
    sampsize = c(nsamp,nsamp)
    names(sampsize) = levels(y)
    
    rf_best = randomForest(x, y,   
                           sampsize = sampsize, 
                           strata = y, importance=TRUE, ntree = best_comb[,'ntree'], mtry = best_comb[,'mtry'])
    
    if (verbose==1) cat('training fnished\n')
    
    test_probs = predict(rf_best,
                         newdata = df_test[,  names(df_test) %in% selected_vars], #potresti semplicemente eliminare l'outcome variable
                         type = "prob")
    
    
    df_perf = compute_perf_eval(prediction_probs = test_probs, labels = df_test[[outcome]], 
                                neg_label = neg_label, pos_label = pos_label, 
                                measures = measures)
    
    all_perf = rbind(all_perf, df_perf)
    
    imp = rf_best$importance[, "MeanDecreaseAccuracy"]
    imp_sd = rf_best$importanceSD[, "MeanDecreaseAccuracy"]
    df_imp[names(imp), "MeanDecreaseAccuracy"] = df_imp[names(imp), "MeanDecreaseAccuracy"]+imp
    df_imp[names(imp), "MeanDecreaseAccuracy_SD"] = df_imp[names(imp_sd), "MeanDecreaseAccuracy"]+imp_sd
    
    if (verbose ==1) print(df_perf)
    
  }
  
  mean_meas = apply(all_perf, 2, mean, na.rm = TRUE)
  mean_meas_df = data.frame(t(mean_meas))
  names(mean_meas_df) = paste(names(mean_meas_df), '_avg', sep ='')
  
  sd_meas = apply(all_perf, 2, sd, na.rm = TRUE)
  sd_meas_df = data.frame(t(sd_meas))
  names(sd_meas_df) = paste(names(sd_meas_df), '_std', sep ='')
  
  str_perfs_df = apply(rbind(mean_meas, sd_meas), 2, function(x){paste(round(x[1],3), '+/-', round(x[2],3))})
  str_perfs_df = data.frame(t(str_perfs_df))
  names(str_perfs_df) = paste(names(str_perfs_df), '_str', sep ='')
  
  res_mega_perf = cbind(data.frame(dim_data = ncol(df), perc_samples = perc_samples, ratio_train = ratio_train, 
                                      feature_selection_method = feature_selection_method, 
                                      n_external_iters = n_external_iters, n_internal_iters= n_internal_iters), 
                                      data.frame(all_combs), all_perf)
  
  res_perf = cbind(data.frame(dim_data = ncol(df), perc_samples = perc_samples, ratio_train = ratio_train, 
                              feature_selection_method = feature_selection_method, 
                              n_external_iters = n_external_iters, n_internal_iters= n_internal_iters, 
                              maxvoted_no_tree = names(which.max(table(all_combs[, 'ntree']))), 
                              maxvoted_mtry = names(which.max(table(all_combs[, 'mtry'])))),
                              mean_meas_df, sd_meas_df, str_perfs_df)
  
  
  tit = paste('auprc = ', str_perfs_df[['aucpr_str']], ' - auc = ', str_perfs_df[['auc_str']], sep = '')
  
  if (verbose ==1){
    cat('****** perf on ', str_desc,' *******\n')
    cat(tit, '\n')
  }
  
  df_imp = df_imp/n_external_iters 
  df_imp = df_imp[df_imp[['MeanDecreaseAccuracy']] >(10)^(-5), ]
  
  
  df_imp['name'] = row.names(df_imp) 
  fn_importances = file.path(save_path, paste('res_RF_', str_desc,'_importances', sep=''))
  write.csv(df_imp, file = paste(fn_importances, '.csv', sep =''))
  # png(file = paste(fn_importances, '.png', sep =''))
  # 
  # plt <- ggplot(df_imp) +
  #   geom_bar( aes(x=name, y=MeanDecreaseAccuracy), stat="identity", fill="skyblue", alpha=0.7) +
  #   geom_errorbar( aes(x=name, ymin=MeanDecreaseAccuracy-MeanDecreaseAccuracy_SD, 
  #                      ymax=MeanDecreaseAccuracy+MeanDecreaseAccuracy_SD), 
  #                  width=0.4, colour="orange", alpha=0.9, linewidth=1.3) + coord_flip()+
  #   ggtitle(tit)  
  # 
  # print(plt)
  # 
  # dev.off()
  # 
  if (verbose == 1) print(res_perf)
  
  return(list('mean_over_holdouts' = res_perf, 'all_holdouts' = res_mega_perf, 'importances' = df_imp))
}