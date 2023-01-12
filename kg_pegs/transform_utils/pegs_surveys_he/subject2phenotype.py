import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    EntityToPhenotypicFeatureAssociation
)

from koza.cli_runner import koza_app #type: ignore

source_name="subject2phenotype"
full_source_name="pegs_survey"

row = koza_app.get_row(source_name)
print(row.keys)
respondent = 'epr_number:' + row['epr_number']
for col in [x for x in row.keys() if x in ##list of names you want != 'epr_number']:
    if str(row[col]) == '1':
        hp_curie = koza_app.translation_table.resolve_term(col)
        # # Association
        association = EntityToPhenotypicFeatureAssociation(
            id="uuid:" + str(uuid.uuid1()),
            subject=respondent,
            predicate=Predicate.has_phenotype,
            object=hp_curie,
            source=full_source_name
        )
        # koza_app.next_row()
        koza_app.write(association)

