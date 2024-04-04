library(stringdist)
library(readxl)
library(car)
setwd('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/')
source('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/utilities.R')

main <- function(thr_missing_mega = 0.3, thr_missing_little = 0.2){
  

  setwd('/Users/laurenchan/Desktop/GIT/kg-exposure/kg_pegs/transform_utils/pegs_surveys_exposomeB/')
  
  tab_drugs = read.csv('reported_medication_name_to_chebi.tsv', sep = '\t')
  
  setwd('/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/')
  
  
  Cols_of_interest_KG <- read_excel("Exposome/Cols of interest - KG.xlsx", 
                                    sheet = "all_cols")
  #View(Cols_of_interest_KG)
  
  load('Exposome/exposomea_02jun21_v2_no_pii.RData')
  load('Exposome/exposomeb_02jun21_v2_no_pii.RData')
  load('Health_and_Exposure/healthexposure_26aug21_v2_no_pii.RData')
  
  
  
  columns_to_use = tolower(Cols_of_interest_KG$epr_number)
  names(epr.ea) = tolower(names(epr.ea))
  epr.ea = epr.ea[, names(epr.ea) %in% c(columns_to_use, 'epr_number')]
  
  names(epr.eb) = tolower(names(epr.eb))
  epr.eb = epr.eb[, names(epr.eb) %in% c(columns_to_use, 'epr_number')]
  
  names(epr.he) = tolower(names(epr.he))
  epr.he = epr.he[, names(epr.he) %in% c(columns_to_use, '_he_gender_', 'epr_number')]
  
  
  
  med_df = epr.eb[, grepl('_med', names(epr.eb))]
  
  
  #yy = seq_dist(a = utf8ToInt(dd), b= lapply(col_med, utf8ToInt) , method ='lv')/nchar(dd)
  #check_length = nchar(col_med) >= nchar(dd)-1
  thr= 3
  
  treatments_df = data.frame(matrix(0, nrow = nrow(epr.eb), ncol = length(unique(tab_drugs$chemical))))
  names(treatments_df) = unique(tab_drugs$chemical)
  treatments_df[['epr_number']] = epr.eb$epr_number
  
  for (n_drugs in 1:nrow(tab_drugs)){
    
    dd = tab_drugs$medication[n_drugs]
    chebi = tab_drugs$chemical[n_drugs]
    
    cat('Searching mappings for ', dd, '\n')
   
    cat('col ', dd, ' added \n')
    list_mappings = NULL
    for (med_col in names(med_df)){
      treatments_df[[chebi]][grepl(dd, med_df[[med_col]], ignore.case = TRUE)] =1
      
      dists = stringdist::seq_dist(a = utf8ToInt(dd), b= lapply(med_df[[med_col]], utf8ToInt) , method ='lv')
      if (any(dists<thr)){
        treatments_df[[chebi]][dists<thr] = 1
        list_mappings = c(list_mappings, med_df[[med_col]][dists<thr])
      }
        
    }
    cat(list_mappings, 'mapped to', dd, '\n')
    cat('***********\n')
  }
  
  freq = colSums(treatments_df[, !(names(treatments_df) %in% 'epr_number')])
  freq = freq[freq > 3]
  treatments_df = treatments_df[, names(treatments_df) %in% c('epr_number', names(freq))]
  
  epr.eb = epr.eb[, !(names(epr.eb) %in% names(med_df))]

#  epr.eb[epr.eb == '.M'] = NA
#  epr.eb[epr.eb == '.S'] = NA
#  epr.eb[epr.eb == '-888888'] = NA
#  epr.eb[, !(names(epr.eb) %in% 'epr_number')] = sapply(epr.eb[, !(names(epr.eb) %in% 'epr_number')], as.numeric)
  epr.eb = replace_nans(epr.eb)
  epr.eb = merge(epr.eb, treatments_df, by = 'epr_number', all = TRUE)
  
  
  #epr.ea[epr.ea == '.M'] = NA
  #epr.ea[epr.ea == '.S'] = NA
  #epr.ea[epr.ea == '-888888'] = NA
  epr.ea = replace_nans(epr.ea)
  epr.ea[, !(names(epr.ea) %in% 'epr_number')] = sapply(epr.ea[, !(names(epr.ea) %in% 'epr_number')], as.numeric)
  
  
  
  #epr.he[epr.he == '.M'] = NA
  #epr.he[epr.he == '.S'] = NA
  #epr.he[epr.he == '.N'] = NA
  #epr.he[epr.he == '-888888'] = NA
  epr.he = replace_nans(epr.he)
  epr.he[, !(names(epr.he) %in% 'epr_number')] = sapply(epr.he[, !(names(epr.he) %in% 'epr_number')], as.numeric)
  
  
  
  thr_missing = thr_missing_mega
  label_cols = c('he_m090_uterine_polyps', 'he_m091_uterine_tumors','he_m092_ovarian_cysts', 'he_m089_endometriosis')
  
  # 
  # mega.df = epr.ea
  # mega.df = merge(mega.df, epr.eb, by = 'epr_number', all = TRUE)
  # mega.df = merge(mega.df, epr.he, by = 'epr_number', all = TRUE)
  # 
  # mega.df = mega.df[(!(is.na(mega.df$he_m090_uterine_polyps)) & 
  #            (!is.na(mega.df$he_m091_uterine_tumors)) & 
  #            (!is.na(mega.df$he_m092_ovarian_cysts)) & 
  #            (!is.na(mega.df$he_m089_endometriosis))), ]
  # 
  # mega.df = mega.df[mega.df['_he_gender_'] == 1, ]
  # mega.df = mega.df[, !(names(mega.df) %in% '_he_gender_')]
  # num_missing = apply(apply(mega.df, 2, is.na), 2, as.numeric)
  # miss_rate_cols = colSums(num_missing)/nrow(mega.df)
  # miss_rate_cols = miss_rate_cols[miss_rate_cols < thr_missing]
  # mega.df.cleaned = mega.df[, names(mega.df) %in% names(miss_rate_cols)]
  # names(mega.df.cleaned) = gsub(':', '_', names(mega.df.cleaned))
  # names(mega.df.cleaned) = gsub(' ', '_', names(mega.df.cleaned))
  # mega.df.cleaned[, !(names(mega.df.cleaned) %in% 'epr_number')] = sapply(mega.df.cleaned[, !(names(mega.df.cleaned) %in% 'epr_number')], as.numeric)  
  # mega.df.cleaned[, !(names(mega.df.cleaned) %in% label_cols)] = imputa(mega.df.cleaned[, !(names(mega.df.cleaned) %in% label_cols)])
  # 
  # writexl::write_xlsx(mega.df.cleaned, path = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/mega.df.cleaned.xlsx')
  
  #miss_rate_cols
  thr_missing = thr_missing_little
  little.df = epr.ea
  little.df = merge(little.df, epr.eb, by = 'epr_number', all = FALSE)
  little.df = merge(little.df, epr.he, by = 'epr_number', all = FALSE)
  little.df = little.df[(!(is.na(little.df$he_m090_uterine_polyps)) & 
                       (!is.na(little.df$he_m091_uterine_tumors)) & 
                       (!is.na(little.df$he_m092_ovarian_cysts)) & 
                       (!is.na(little.df$he_m089_endometriosis))), ]
  little.df = little.df[little.df['_he_gender_'] == 1, ]
  little.df = little.df[, !(names(little.df) %in% '_he_gender_')]
  names(little.df) = gsub(':', '_', names(little.df))
  names(little.df) = gsub(' ', '_', names(little.df))  
  
  num_missing = apply(apply(little.df, 2, is.na), 2, as.numeric)
  miss_rate_cols = colSums(num_missing)/nrow(little.df)
  miss_rate_cols = miss_rate_cols[miss_rate_cols < thr_missing]
  
  miss_rate_cols #0.2 missing
  df_missing = data.frame(miss_rate = miss_rate_cols, var_names = names(miss_rate_cols), row.names = names(miss_rate_cols))
  writexl::write_xlsx(df_missing, path = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/little.df.missing.xlsx')
  
  hist(miss_rate_cols[miss_rate_cols>0], main = paste("Histogram of survey question missingness"), xlab = 'Missingness (%)', ylab = 'Frequency (counts)')
  
  little.df.cleaned = little.df[, names(little.df) %in% names(miss_rate_cols)]

  little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')] = sapply(little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')], as.numeric)  
  little.df.cleaned[, !(names(little.df.cleaned) %in% label_cols)] = imputa(little.df.cleaned[, !(names(little.df.cleaned) %in% label_cols)])
  #num_missing.cleaned = apply(apply(little.df.cleaned, 2, is.na), 2, as.numeric)
  #miss_rate_row = rowSums(num_missing.cleaned)/ncol(little.df.cleaned)
  
  x = data.frame(sapply(little.df.cleaned,class))
  
  mean_prevalence = data.frame(mean_prevalence = sapply(little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')], mean))
  #mean_prevalence[['var_names']] = row.names(mean_prevalence)
  sd_prevalence = data.frame(sd_prevalence = sapply(little.df.cleaned[, !(names(little.df.cleaned) %in% 'epr_number')], sd))
  merged.df = merge(mean_prevalence, sd_prevalence, by = 'row.names')
  row.names(merged.df) = merged.df$Row.names
  merged.df = merged.df[, !(names(merged.df) %in% 'Row.names')]
  
  writexl::write_xlsx(merged.df, path = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/merged.df.xlsx')
  missingness.prevalence.df = merge(merged.df, df_missing, by = 'row.names')
  row.names(missingness.prevalence.df) = missingness.prevalence.df$Row.names
  missingness.prevalence.df = missingness.prevalence.df[, !(names(missingness.prevalence.df) %in% 'Row.names')]
  
  writexl::write_xlsx(little.df.cleaned, path = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/little.df.cleaned.xlsx')
  save(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/workspace_variables.Rda')
  save(mega.df.cleaned, little.df.cleaned, 
       file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/data.Rda')
}


##for lauren, download the tables, rerun from line 184-line192 but mind that need to change names in 186 and 192 to the other conditions

### this is endometriosis, do for all others as well
load(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/missingness.prevalence.df.Rda')
## modifying to include LR and missingness/prevalence
tab = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/Supp Table 2A_ endometriosis_LR_full_input.csv')
tab = tab[,!(names(tab)%in% 'X')]
tab = unique(tab)
row.names(tab) = tab$Survey.question.label

tab_miss_prev = merge(tab, missingness.prevalence.df, by = 'row.names')
write.csv(tab_miss_prev, file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2A_ endometriosis_LR_full - Sheet1.csv')

### this is for uterine fibroids
tab1 = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/Supp Table 2B_ uterine_fibroid_LR_full_input.csv')
tab1 = tab1[,!(names(tab1)%in% 'X')]
tab1 = unique(tab1)
row.names(tab1) = tab1$Survey.question.label

tab1_miss_prev = merge(tab1, missingness.prevalence.df, by = 'row.names')
write.csv(tab1_miss_prev, file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full - Sheet1.csv')


### this is for ovarian cysts
tab2 = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/Supp Table 2C_ ovarian_cysts_LR_full_input.csv')
tab2 = tab2[,!(names(tab2)%in% 'X')]
tab2 = unique(tab2)
row.names(tab2) = tab2$Survey.question.label

tab2_miss_prev = merge(tab2, missingness.prevalence.df, by = 'row.names')
write.csv(tab2_miss_prev, file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2C_ ovarian_cysts_LR_full - Sheet1.csv')

##ovarian

# uterine fibroids

library(car)
label_cols = c('he_m090_uterine_polyps', 'he_m091_uterine_tumors','he_m092_ovarian_cysts', 'he_m089_endometriosis')

load(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/data.Rda')
tab = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full - Sheet1.csv')
row.names(tab)= tab$Row.names
outcome = label_cols[2]  ## change for different outcome
nn = row.names(tab)
nn = nn[!(nn %in% outcome)]
glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
              family=binomial(link="logit"), data=little.df.cleaned) 
xx = vif(glm_fit)
print(names(xx[xx>4]))
## vif values telling inflation of each value, 


n_internal_iters = 11
use_df = little.df.cleaned
vif_df = data.frame(row.names = nn)
for (j in 1: n_internal_iters)  {      
  balanced_df = caret::downSample(use_df, factor(use_df[[outcome]],levels = c(0,1)), list = FALSE)
  balanced_df[[outcome]] = as.numeric(balanced_df[[outcome]] ==1)
  glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                family=binomial(link="logit"), data=balanced_df)
  xx = vif(glm_fit)
  del_vars = names(xx[xx>2])
  while (length(del_vars)>0){
    cat('Removing variables: ', del_vars, '\n')
    nn = nn[!(nn %in% del_vars)]
    glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                  family=binomial(link="logit"), data=balanced_df)
    xx = vif(glm_fit)
    del_vars = names(xx[xx>2])
  }
}  
  
  vif_df[[j]] = NA
  vif_df[nn, j] = xx

  mean_vif_df = data.frame(mean_vif = apply(vif_df, 1, mean, na.rm = TRUE), row.names = row.names(vif_df))
  tab_uf = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full - Sheet1.csv')
  row.names(tab_uf) = tab_uf$Row.names
  merge_uf_vif = merge(mean_vif_df, tab_uf, by = 'row.names')
  writexl::write_xlsx(merge_uf_vif, path= '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full_VIF1-Sheet1.xlsx')


#END endometriosis

#ovarian poly cists
  library(car)
  load(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/data.Rda')
  tab = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2C_ ovarian_cysts_LR_full - Sheet1.csv')
  row.names(tab)= tab$Row.names
  outcome = label_cols[4]  ## change for different outcome
  nn = row.names(tab)
  nn = nn[!(nn %in% outcome)]
  #  glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
  #                family=binomial(link="logit"), data=little.df.cleaned) 
  #  xx = vif(glm_fit)
  #  print(names(xx[xx>4]))
  ## vif values telling inflation of each value, 
  
  
  n_internal_iters = 31
  use_df = little.df.cleaned
  vif_df = data.frame(row.names = nn)
  for (j in 1: n_internal_iters)  {      
    balanced_df = caret::downSample(use_df, factor(use_df[[outcome]],levels = c(0,1)), list = FALSE)
    balanced_df[[outcome]] = as.numeric(balanced_df[[outcome]] ==1)
    balanced_df = balanced_df[, !(names(balanced_df) %in% c('epr_number', 'Class'))]
    #balanced_df_for_prevalence = apply(balanced_df>0,2, as.numeric)
    prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, mean)
    std_prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, sd)
    del_vars = union(names(prevalence[prevalence<0.01]),names(std_prevalence[std_prevalence<0.01])) 
    
    glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                  family=binomial(link="logit"), data=balanced_df)
    xx = vif(glm_fit)
    del_vars = union(del_vars, names(xx[xx>2]))
    while (length(del_vars)>0){
      cat('Removing variables: ', del_vars, '\n')
      nn = nn[!(nn %in% del_vars)]
      glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                    family=binomial(link="logit"), data=balanced_df)
      xx = vif(glm_fit)
      del_vars = names(xx[xx>2])
    }
  }  
  vif_df[[j]] = NA
  vif_df[nn, j] = xx
  
  mean_vif_df = data.frame(mean_vif = apply(vif_df, 1, mean, na.rm = TRUE), row.names = row.names(vif_df))
  tab_endo = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2A_ endometriosis_LR_full - Sheet1.csv')
  row.names(tab_endo) = tab_endo$Row.names
  merge_endo_vif = merge(mean_vif_df, tab_endo, by = 'row.names')
  writexl::write_xlsx(merge_endo_vif, path= '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2A_ endometriosis_LR_full_VIF1-Sheet1.xlsx')
  
  
  
  
  
  
  
  
  
  
  
  #### START ENDOMETRIOSIS
  
  library(car)
  label_cols = c('he_m090_uterine_polyps', 'he_m091_uterine_tumors','he_m092_ovarian_cysts', 'he_m089_endometriosis')
  
  load(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/data.Rda')
  tab = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2A_ endometriosis_LR_full - Sheet1.csv')
  row.names(tab)= tab$Row.names
  outcome = label_cols[4]  ## change for different outcome
  nn = row.names(tab)
  nn = nn[!(nn %in% outcome)]
#  glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
#                family=binomial(link="logit"), data=little.df.cleaned) 
#  xx = vif(glm_fit)
#  print(names(xx[xx>4]))
  ## vif values telling inflation of each value, 
  
  
  n_internal_iters = 31
  use_df = little.df.cleaned
  vif_df = data.frame(row.names = nn)
  for (j in 1: n_internal_iters)  {  
    nn = row.names(tab)
    nn = nn[!(nn %in% outcome)]
    balanced_df = caret::downSample(use_df, factor(use_df[[outcome]],levels = c(0,1)), list = FALSE)
    balanced_df[[outcome]] = as.numeric(balanced_df[[outcome]] ==1)
    balanced_df = balanced_df[, !(names(balanced_df) %in% c('epr_number', 'Class'))]
    #balanced_df_for_prevalence = apply(balanced_df>0,2, as.numeric)
    prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, mean)
    std_prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, sd)
    del_vars = union(names(prevalence[prevalence<0.01]),names(std_prevalence[std_prevalence<0.01])) 
    
    glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                  family=binomial(link="logit"), data=balanced_df)
    xx = vif(glm_fit)
    del_vars = union(del_vars, names(xx[xx>4]))
    while (length(del_vars)>0){
      cat('Removing variables: ', del_vars, '\n')
      nn = nn[!(nn %in% del_vars)]
      glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                    family=binomial(link="logit"), data=balanced_df)
      xx = vif(glm_fit)
      del_vars = names(xx[xx>4])
    }
    
    vif_df[[j]] = NA
    vif_df[nn, j] = xx
  }
  mean_vif_df = data.frame(mean_vif = apply(vif_df, 1, mean, na.rm = TRUE), row.names = row.names(vif_df))
  tab_endo = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2A_ endometriosis_LR_full - Sheet1.csv')
  row.names(tab_endo) = tab_endo$Row.names
  merge_endo_vif = merge(mean_vif_df, tab_endo, by = 'row.names')
  writexl::write_xlsx(merge_endo_vif, path= '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2A_ endometriosis_LR_full_VIF1-Sheet1.xlsx')


########  END ENDOMETRIOSIS
    
    #### START OVARIAN
    
    
    load(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/data.Rda')
    tab = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2C_ ovarian_cysts_LR_full - Sheet1.csv')
    
    row.names(tab)= tab$Row.names
    outcome = label_cols[3]  ## change for different outcome
    nn = row.names(tab)
    nn = nn[!(nn %in% outcome)]
    #  glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
    #                family=binomial(link="logit"), data=little.df.cleaned) 
    #  xx = vif(glm_fit)
    #  print(names(xx[xx>4]))
    ## vif values telling inflation of each value, 
    
    
    n_internal_iters = 31
    use_df = little.df.cleaned
    vif_df = data.frame(row.names = nn)
    for (j in 1: n_internal_iters)  {  
      nn = row.names(tab)
      nn = nn[!(nn %in% outcome)]
      balanced_df = caret::downSample(use_df, factor(use_df[[outcome]],levels = c(0,1)), list = FALSE)
      balanced_df[[outcome]] = as.numeric(balanced_df[[outcome]] ==1)
      balanced_df = balanced_df[, !(names(balanced_df) %in% c('epr_number', 'Class'))]
      #balanced_df_for_prevalence = apply(balanced_df>0,2, as.numeric)
      prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, mean)
      std_prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, sd)
      del_vars = union(names(prevalence[prevalence<0.01]),names(std_prevalence[std_prevalence<0.01])) 
      
      glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                    family=binomial(link="logit"), data=balanced_df)
      xx = vif(glm_fit)
      del_vars = union(del_vars, names(xx[xx>4]))
      while (length(del_vars)>0){
        cat('Removing variables: ', del_vars, '\n')
        nn = nn[!(nn %in% del_vars)]
        glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                      family=binomial(link="logit"), data=balanced_df)
        xx = vif(glm_fit)
        del_vars = names(xx[xx>4])
      }
      
      vif_df[[j]] = NA
      vif_df[nn, j] = xx
    }
    mean_vif_df = data.frame(mean_vif = apply(vif_df, 1, mean, na.rm = TRUE), row.names = row.names(vif_df))
    
    
    tab_endo = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2C_ ovarian_cysts_LR_full - Sheet1.csv')
    row.names(tab_endo) = tab_endo$Row.names
    merge_endo_vif = merge(mean_vif_df, tab_endo, by = 'row.names')
    writexl::write_xlsx(merge_endo_vif, path= '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2C_ ovarian_cyst_LR_full_VIF1-Sheet1.xlsx')
    
    
    #### FIBROIDS
    
    
    
    load(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/data.Rda')
    tab = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full - Sheet1.csv')
    row.names(tab)= tab$Row.names
    outcome = label_cols[2]  ## change for different outcome
    nn = row.names(tab)
    nn = nn[!(nn %in% outcome)]
    #  glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
    #                family=binomial(link="logit"), data=little.df.cleaned) 
    #  xx = vif(glm_fit)
    #  print(names(xx[xx>4]))
    ## vif values telling inflation of each value, 
    
    
    n_internal_iters = 31
    use_df = little.df.cleaned
    vif_df = data.frame(row.names = nn)
    for (j in 1: n_internal_iters)  {  
      nn = row.names(tab)
      nn = nn[!(nn %in% outcome)]
      balanced_df = caret::downSample(use_df, factor(use_df[[outcome]],levels = c(0,1)), list = FALSE)
      balanced_df[[outcome]] = as.numeric(balanced_df[[outcome]] ==1)
      balanced_df = balanced_df[, !(names(balanced_df) %in% c('epr_number', 'Class'))]
      #balanced_df_for_prevalence = apply(balanced_df>0,2, as.numeric)
      prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, mean)
      std_prevalence = apply(balanced_df[, !(colnames(balanced_df) %in% outcome)], 2, sd)
      del_vars = union(names(prevalence[prevalence<0.01]),names(std_prevalence[std_prevalence<0.01])) 
      
      glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                    family=binomial(link="logit"), data=balanced_df)
      xx = vif(glm_fit)
      del_vars = union(del_vars, names(xx[xx>4]))
      while (length(del_vars)>0){
        cat('Removing variables: ', del_vars, '\n')
        nn = nn[!(nn %in% del_vars)]
        glm_fit = glm(as.formula(paste(outcome, '~', paste(nn, collapse = '+'))),
                      family=binomial(link="logit"), data=balanced_df)
        xx = vif(glm_fit)
        del_vars = names(xx[xx>4])
      }
      
      vif_df[[j]] = NA
      vif_df[nn, j] = xx
    }
    mean_vif_df = data.frame(mean_vif = apply(vif_df, 1, mean, na.rm = TRUE), row.names = row.names(vif_df))
    
    
    tab_endo = read.csv(file = '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full - Sheet1.csv')
    row.names(tab_endo) = tab_endo$Row.names
    merge_endo_vif = merge(mean_vif_df, tab_endo, by = 'row.names')
    writexl::write_xlsx(merge_endo_vif, path= '/Users/laurenchan/Desktop/pegs_chan_no_pii/Surveys/R Scripts/supplementary LR data/new_Supp Table 2B_ uterine_fibroid_LR_full_VIF1-Sheet1.xlsx')
    
    
    
    
    

