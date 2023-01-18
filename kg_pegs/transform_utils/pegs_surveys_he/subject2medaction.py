import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    Association
)

from koza.cli_runner import koza_app #type: ignore

source_name="subject2medaction"
full_source_name="pegs_survey"

row = koza_app.get_row(source_name)

cols_of_interest = ['epr_number',
                    'he_c022b_diabetes_insulin_CHILDQ',
                    'he_c022d_diabetes_pills_CHILDQ',
                    'he_m083_hysterectomy',
                    'he_m084_ovaries_PARQ']

respondent = 'epr_number:' + row['epr_number']
for col in cols_of_interest:
    if str(row[col]) == '1':
        maxo_curie = koza_app.translation_table.resolve_term(col)
        association = Association(
            id="uuid:" + str(uuid.uuid1()),
            subject=respondent,
            predicate=Predicate.affected_by,
            object=maxo_curie,
            source=full_source_name
        )
        koza_app.write(association)
