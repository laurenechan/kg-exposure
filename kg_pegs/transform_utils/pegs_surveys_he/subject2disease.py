import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    EntityToDiseaseAssociation
)

from koza.cli_runner import koza_app #type: ignore

source_name="subject2disease"
full_source_name="pegs_survey"

row = koza_app.get_row(source_name)

cols_of_interest = [
     'epr_number',
     'he_b007a_hypertension_preg_CHILDQ',
     'he_b013_coronary_artery',
     'he_b016_raynauds',
     'he_c021_pre_diabetes_PARQ',
     'he_c022_diabetes_PARQ',
     'he_c022a_diabetes_preg_CHILDQ',
     'he_c023_thyroid_disease_PARQ',
     'he_c023a_hyperthyroidism_CHILDQ',
     'he_c023b_hypothyroidism_CHILDQ',
     'he_c023d_nodule_benign_CHILDQ',
     'he_d025_copd',
     'he_d026_ipf',
     'he_d027_tb_PARQ',
     'he_d030_asthma_PARQ',
     'he_e031_epilepsy',
     'he_f042_gallbladder_disease',
     'he_f045_fatty_liver',
     'he_f046_hepatitis_PARQ',
     'he_g048_esrd',
     'he_g051_pkd',
     'he_h055_fibromyalgia',
     'he_h056_lupus',
     'he_h057_sjogrens',
     'he_i058_hemochromatosis',
     'he_i060_pernicious_anemia',
     'he_i061_sickle_cell',
     'he_j064_gout',
     'he_k069_psoriasis',
     'he_m089_endometriosis',
     'he_m090_uterine_polyps',
     'he_o108a_cancer_breast_age_CHILDQ',
     'he_o109_cancer_cervix_PARQ_CHILDQ',
     'he_o123_cancer_ovary_PARQ_CHILDQ',
     'he_o134_cancer_uterus_PARQ_CHILDQ']


respondent = 'epr_number:' + row['epr_number']


for col in cols_of_interest:
    if str(row[col]) == '1':
        mondo_curie = koza_app.translation_table.resolve_term(col)
        association = EntityToDiseaseAssociation(
            id="uuid:" + str(uuid.uuid1()),
            subject=respondent,
            predicate=Predicate.affected_by,
            object=mondo_curie,
            source=full_source_name
        )
        koza_app.write(association)

