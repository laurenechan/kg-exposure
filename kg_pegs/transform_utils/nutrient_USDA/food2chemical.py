import logging
import uuid

from biolink_model_pydantic.model import ( #type: ignore
    Predicate,
    Association
)

from koza.cli_runner import koza_app

logger = logging.getLogger(__name__)

source_name = "nutrient_food2chemical"

row = koza_app.get_row(source_name)

try:
    food = koza_app.translation_table.resolve_term(int(row['fdc_id']))
except KeyError as key_error:
    logger.warning(key_error)
    koza_app.next_row()

try:
    chemical = koza_app.translation_table.resolve_term(int(row['nutrient_id']))
except KeyError as key_error:
    logger.warning(key_error)
    koza_app.next_row()

association = Association(
    id="uuid:" + str(uuid.uuid1()),
    category="biolink:Association",
    subject=food,
    predicate=Predicate.has_nutrient,
    object=chemical,
    source=source_name
)
koza_app.write(association)
