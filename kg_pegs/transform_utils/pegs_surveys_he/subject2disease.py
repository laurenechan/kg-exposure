import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    EntityToDiseaseAssociation
)

from koza.cli_runner import koza_app #type: ignore

source_name="subject2disease"
full_source_name="pegs_survey"

row = koza_app.get_row(source_name)
respondent = 'epr_number:' + row['epr_number']
for col in [x for x in row.keys() if x != 'epr_number']:
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
