import uuid

from biolink_model_pydantic.model import (  # type: ignore
    Predicate,
    Association
)

from koza.cli_runner import koza_app  # type: ignore

source_name = "subject2exposure"
full_source_name = "pegs_survey"

row = koza_app.get_row(source_name)
respondent = 'epr_number:' + row['epr_number']
cols = [x for x in row.keys() if x != 'epr_number']

for col in cols:
    if str(row[col]) == '1':
        try:
            ecto_curie = koza_app.translation_table.resolve_term(col.replace('_CHILDQ', '').replace('_PARQ', ''))
            print(ecto_curie)
            association = Association(
                id="uuid:" + str(uuid.uuid1()),
                subject=respondent,
                predicate=Predicate.affected_by,
                object=ecto_curie,
                source=full_source_name
            )
            koza_app.write(association)
        except KeyError:
            pass
