import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    EntityToPhenotypicFeatureAssociation
)

from koza.cli_runner import koza_app #type: ignore

source_name="subject2phenotype"
full_source_name="pegs_survey"

row = koza_app.get_row(source_name)

cols_of_interest = ['epr_number',
                    'he_b007_hypertension_PARQ',
                    'he_b009_atherosclerosis',
                    'he_b010_cardiac_arrhythmia',
                    'he_b011_angina',
                    'he_b012_heart_attack',
                    'he_b014_congestive_heart_failure',
                    'he_b017_blood_clots',
                    'he_b019_stroke_mini',
                    'he_b020_stroke_PARQ',
                    'he_b020a_stroke_type_CHILDQ',
                    'he_c023c_thyroid_enlarged_CHILDQ',
                    'he_e032_migraine',
                    'he_f037_celiac',
                    'he_f038_lactose_intolerance',
                    'he_f039_crohns',
                    'he_f040_ulcerative_colitis',
                    'he_f041_polyps',
                    'he_f043_stomach_ulcer',
                    'he_f044_cirrhosis',
                    'he_g047_ckd',
                    'he_g049_kidney_stones',
                    'he_g050_kidney_infection',
                    'he_h053_scleroderma',
                    'he_i059_iron_anemia',
                    'he_j062_bone_loss',
                    'he_j063_osteoporosis',
                    'he_j065_myositis',
                    'he_j066_rheu_arthritis_PARQ',
                    'he_j067_osteoarthritis_PARQ',
                    'he_k070_eczema',
                    'he_k071_urticaria',
                    'he_m091_uterine_tumors',
                    'he_m092_ovarian_cysts']


print(row.keys)
respondent = 'epr_number:' + row['epr_number']

for col in cols_of_interest:
    if str(row[col]) == '1':
        hp_curie = koza_app.translation_table.resolve_term(col)
        association = EntityToPhenotypicFeatureAssociation(
            id="uuid:" + str(uuid.uuid1()),
            subject=respondent,
            predicate=Predicate.has_phenotype,
            object=hp_curie,
            source=full_source_name
        )
    # koza_app.next_row()
        koza_app.write(association)

