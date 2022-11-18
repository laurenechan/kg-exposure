import uuid

from biolink_model_pydantic.model import ( #type: ignore
    OrganismalEntity
)

from koza.cli_runner import koza_app #type: ignore

source_name="survey_respondents"
full_source_name="pegs_survey"


row = koza_app.get_row(source_name)
respondent = OrganismalEntity(id='epr_number:' + row['epr_number'], source=full_source_name)
koza_app.write(respondent)


