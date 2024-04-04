evaluate_ntree_mtry <- function(df_train = NULL, outcome = 'Activity', use_vars = names(df_train)[!(names(df_train) %in% outcome)],
                                pos_label = levels(df_train[[outcome]])[1], neg_label = levels(df_train[[outcome]])[2],
                                n_internal_iters = 101, ntree_mtry_candidate = NULL, opti_meas = 'aucpr', 
                                perc_samples = 0.9, ratio_train = 0.9, verbose = 0, 
                                nneg_train = sum(df_train[[outcome]]== neg_label),  
                                npos_train = sum(df_train[[outcome]]== pos_label)){
    
  # uses n_internal_iters holdouts to compute, for each parameter combination, the performance measure opti_meas
  # as the average across the optimeas computed over all the holdouts 
  # returns the first combination maximizing the opti_meas value
  ntree_mtry_candidate[[opti_meas]] = NA
  
  folds <- caret::createDataPartition(df_train[[outcome]], times = n_internal_iters, 
                                      p = ratio_train, list = TRUE);
  
  
  for (nr in 1:nrow(ntree_mtry_candidate)){
    
    nt = ntree_mtry_candidate[['ntree']][nr]
    mt = ntree_mtry_candidate[['mtry']][nr]
    

    if (verbose ==1){ 
      cat('evaluation of comb =  ') 
      print(ntree_mtry_candidate[nr, ])
    }
    cl <- makePSOCKcluster(4)
    registerDoParallel(cl)
    
    
    res_df = foreach(n_internal_it = 1:n_internal_iters, .combine = 'rbind', .packages = c('randomForest', 'ROCR', 'PerfMeas'), 
                      .export = 'compute_perf_eval') %dopar%{
                       
    #for (n_internal_it in 1:n_internal_iters){
        
         idx = folds[[n_internal_it]]
           
         df_t = df_train[idx, ]
         df_test = df_train[-idx, ]
         
         x = df_t[, names(df_t) %in% use_vars] 
         y = df_t[[outcome]]
         nsamp = floor(min(table(y))*perc_samples)
         sampsize = c(nsamp,nsamp)
         names(sampsize) = levels(y)
         
         rf = randomForest(x, y,   
                           sampsize = sampsize, 
                           strata = y, importance=FALSE, 
                           ntree = nt, mtry = mt)
         
         test_probs = predict(rf, newdata = df_test[,  names(df_test) %in% use_vars], 
                              type = "prob")
         
         df_perf = compute_perf_eval(prediction_probs = test_probs, labels = df_test[[outcome]], 
                                     neg_label = neg_label, pos_label = pos_label, measures = opti_meas)
         
         return(df_perf)
    }
    
    stopCluster(cl)
    unregister_dopar()
    
    ntree_mtry_candidate[nr, opti_meas ] = mean(res_df[[opti_meas]])
    
    if (verbose ==1){ 
      cat('Internal grid search: ', opti_meas, ' = ') 
      print(ntree_mtry_candidate[nr, opti_meas ])
    }
  }
  
  idx_best = which.max(ntree_mtry_candidate[[opti_meas]])
  
  return(ntree_mtry_candidate[idx_best, ])
}