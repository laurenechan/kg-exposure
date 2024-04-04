library(missRanger)
imputa <- function(mat_data, k= 1){
  # fun may be knn or missRanger
  #mat_data has features on columns
  
  miss_indicator = apply(apply(mat_data, 2, is.na),2, as.numeric)
  if (any(miss_indicator>0)){
    no_pt_with_missing = sum(rowMeans(miss_indicator)>0)
    no_vars_with_missing = sum(colMeans(miss_indicator)>0)
    cat('no. cases with missing values = ', no_pt_with_missing,
        '(', round(100*(no_pt_with_missing/nrow(mat_data)),3), '%) - average (min,max) missingness =',
        mean(rowMeans(miss_indicator)), ' (',
        min(rowMeans(miss_indicator)),',',max(rowMeans(miss_indicator)),')\n')
    cat('no. variables with missing values = ', no_vars_with_missing,
        '(', round(100*(no_vars_with_missing/ncol(mat_data)),3), '%) - average (min,max) missingness =',
        mean(colMeans(miss_indicator)), ' (',
        min(colMeans(miss_indicator)),',',max(colMeans(miss_indicator)),')\n')
    cat('imputation with missRanger (k = ', k, ')\n')
    if (!is.data.frame(mat_data)) df_data = data.frame(mat_data)
    else df_data = mat_data
    imputed_data =  missRanger(df_data, pmm.k = k, num.trees = 101)
    if (!is.data.frame(mat_data)) imputed_data = as.matrix(imputed_data)
 
  }else{
    cat('no missing values\n')
    imputed_data = mat_data
  }
  return(imputed_data)
}



replace_nans <- function(df){
  df[df == '.M'] = NA
  df[df == '.N'] = NA
  df[df == '.S'] = NA
  df[df == '-888888'] = NA
  df[, !(names(df) %in% 'epr_number')] = sapply(df[, !(names(df) %in% 'epr_number')], as.numeric)  
  return(df)
}