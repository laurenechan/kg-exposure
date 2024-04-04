feature_selection <- function(df_train, feature_selection_method = 'RF_importance', minNumVar = 2, maxNumVar = Inf, 
                              perc_samples = 0.8, 
                              outcome = 'label', idvar = 'ID', n_internal_iters = 51, n_repetitions = 11,
                              pos_label = levels(df_train[[outcome]])[2], 
                              thrconf = 0.05){
  
  cl <- makePSOCKcluster(4)
  registerDoParallel(cl)
  
  names_vars = names(df_train[, !(names(df_train) %in% c(idvar, outcome))])
  internal_folds <- caret::createDataPartition(as.factor(df_train[[outcome]]), times = n_internal_iters, 
                                               p = perc_samples, list = TRUE);
  
  if (feature_selection_method == 'RF_importance'){
    
    df_imp_feat_select = foreach (n_internal_it = 1:n_internal_iters, .combine = 'cbind', .packages = 'randomForest') %dopar%{
    #for (n_internal_it in 1:n_internal_iters) {
      
      sub_train_idx = internal_folds[[n_internal_it]]
      df_t = df_train[sub_train_idx, ]
            
      # setting sampsize so that training is performed on balanced bootstraps
      nsamp = floor(min(table(df_t[[outcome]]))*perc_samples)
      sampsize = c(nsamp,nsamp)
      names(sampsize) = levels(df_t[[outcome]])
      
#      for (j in 1:n_repetitions){
        
        rf = randomForest(x = df_t[, !(names(df_t) %in% c(idvar, outcome))],
                          y = df_t[[outcome]], 
                          importance=TRUE, na.action=na.omit, 
                          strata = df_t[[outcome]], sampsize = sampsize)
        
#        if (j ==1) imps = rf$importance[, "MeanDecreaseAccuracy"]
#        else{ imps = imps + rf$importance[, "MeanDecreaseAccuracy"]}
 #     }
#      imps = imps/n_repetitions
      return(rf$importance[, "MeanDecreaseAccuracy"])
    }
    
    df_imp_feat_select = apply(df_imp_feat_select,1, mean)
    df_imp_feat_select = sort(df_imp_feat_select,decreasing = TRUE)
    df_imp_feat_select = df_imp_feat_select[1:min(maxNumVar, length(df_imp_feat_select))]
    df_imp_feat_select = df_imp_feat_select[df_imp_feat_select>=(thrconf^2)]
    
    if(length(df_imp_feat_select)<minNumVar) selected_vars = names_vars 
    else{
      df_imp_feat_select = df_imp_feat_select/sum(df_imp_feat_select)
      idx = which(cumsum(df_imp_feat_select)>0.99)
      selected_vars = names(df_imp_feat_select)[1:max(idx,3)]
    }
  }else{
    
    if (feature_selection_method=='boruta'){    
      
      
      df_imp_feat_select = foreach(n_internal_it = 1:n_internal_iters, .combine = 'cbind', .packages = 'Boruta') %dopar%{
        
        sub_train_idx = internal_folds[[n_internal_it]]
        df_t = df_train[sub_train_idx, ]
       # vec_selection = rep(0, times = length(names(x)))
        
        #for (j in 1:n_repetitions){
        # balancing the training set via downsampling
          balanced_df = caret::downSample(df_t, df_t[[outcome]], list = FALSE)
          x = balanced_df[, !(names(balanced_df) %in% c(idvar, outcome, 'Class'))]
          y = balanced_df[['Class']]
        
          boruta_decision = Boruta(x = x, y = y, pValue = (thrconf*2), 
                                 maxRuns = n_internal_iters)
          selected_vars = getSelectedAttributes(boruta_decision, withTentative = TRUE)
        return(selected_vars)
         # names(vec_selection) = names(x)
        #  vec_selection[match(selected_vars, names(x))] = vec_selection[match(selected_vars, names(x))] + 1
        #}
        #return(vec_selection)
      }
      
      df_imp_feat_select = apply(df_imp_feat_select,1, mean)
      df_imp_feat_select = sort(df_imp_feat_select,decreasing = TRUE)
      df_imp_feat_select = df_imp_feat_select[1:min(maxNumVar, length(df_imp_feat_select))]
      df_imp_feat_select = df_imp_feat_select[df_imp_feat_select>=(thrconf^2)]
      
      if(length(df_imp_feat_select)<minNumVar) selected_vars = names_vars
      else selected_vars = names(df_imp_feat_select)
      
    }else if(feature_selection_method=='glmnet'){
      
      df_imp_feat_select = foreach (n_internal_it = 1:n_internal_iters, .combine = 'cbind', .packages = 'glmnet') %dopar%{
        
        sub_train_idx = internal_folds[[n_internal_it]]
        df_t = df_train[sub_train_idx, ]
        
        # balancing the training set via downsampling
        balanced_df = caret::downSample(df_t, df_t[[outcome]], list = FALSE)
        x = as.matrix(balanced_df[, !(names(balanced_df) %in% c(idvar, outcome, 'Class'))])
        y = as.numeric(balanced_df[['Class']] == pos_label) 
        
        cvfit = cv.glmnet(x,y, alpha = 0.5, family = 'binomial')
        vals = coef(cvfit, s = "lambda.min")
        
        return(vals[,1])
      }
      
      df_imp_feat_select = apply(abs(df_imp_feat_select),1, mean)
      df_imp_feat_select = sort(df_imp_feat_select,decreasing = TRUE)
      df_imp_feat_select = df_imp_feat_select[1:min(maxNumVar, length(df_imp_feat_select))]
      df_imp_feat_select = df_imp_feat_select[df_imp_feat_select>=(thrconf^2)]
      if(length(df_imp_feat_select)<minNumVar) selected_vars = names_vars
      else selected_vars = names(df_imp_feat_select)
    }
  }
  
  stopCluster(cl)
  unregister_dopar()
  
  return(selected_vars) 
}
