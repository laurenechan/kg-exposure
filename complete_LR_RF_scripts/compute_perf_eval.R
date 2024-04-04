compute_perf_eval <- function(prediction_probs = NULL, labels = NULL, cutoff = 0.5, opti_meas = measures[1],
                              pos_label = '1', neg_label = '0', measures = c("aucpr", "auc") ){
  #prediction_probs is a matrix where each row is a case and each column contains probabilities for a class
  # labels are true labels - they should be factors 
  
  class_probs = prediction_probs[, colnames(prediction_probs) %in% pos_label]
  
  no_aucs = sum(measures %in% c('auc', 'aucpr'))
  no_nonaucs = length(measures)-no_aucs # if some measures are not aucs I must find the threshold for the class prob and derive a classification
  
  pred = ROCR::prediction(class_probs, labels,  label.ordering = c(neg_label,pos_label))
  
  if (no_nonaucs>0){
    classifications = ifelse(class_probs<cutoff, 0, 1 )
    pred_class = ROCR::prediction(classifications, labels,  label.ordering = c(neg_label,pos_label))
  }
  
  perfs = NULL
  
  for (measure in measures){
    
    if ((measure == 'auc') | (measure == 'aucpr')){ 
      perfs = c(perfs, performance(pred, measure = measure)@y.values[[1]]) 
    }else{
      # in this case you must use the thresholded classification and the prediction object generated from that
      # the resulting object has the measure for thresholds equal to 0, 0.5, and 1 - you must take the one in the middle (thr = 0.5)
      pp = performance(pred_class, measure = measure)@y.values[[1]]
      if (length(pp)<3){ 
        cat(pp, ' - mah.....\n')
        metrics = F.measure.single(classifications, labels)
        meas = ifelse(measure== 'prec', metrics[1], 
                ifelse((measure == 'rec') | (measure == 'sens'), metrics[2], 
                  ifelse(measure == 'spec', metrics[3], 
                    ifelse(measure == 'f', metrics[4],
                      ifelse(measure == 'acc', metrics[5],NA)))))
        perfs = c(perfs, meas)
      }else{ perfs = c(perfs, pp[2] )}
   }
  }
  names(perfs) = measures
  res_df = data.frame(t(perfs))
  
  return(res_df)
  

}