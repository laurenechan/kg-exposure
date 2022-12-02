import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    Association
)

from koza.cli_runner import koza_app

source_name = "food2chemical"
full_source_name = "usda_acup"

row = koza_app.get_row(source_name)

food = row['food_id']
chemical = row['chemical_id']

association = Association(
    id="uuid:" + str(uuid.uuid1()),
    subject=food,
    predicate=Predicate.associated_with,
    object=chemical,
    source=full_source_name
)
koza_app.write(association)
