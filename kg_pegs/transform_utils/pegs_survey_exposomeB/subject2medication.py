import uuid

from biolink_model_pydantic.model import (  # type: ignore
    Predicate,
    Association
)

from koza.cli_runner import koza_app  # type: ignore

source_name = "pegsexb_subject2medication"

medication2chebi = koza_app.get_map("medication-to-chebi")

row = koza_app.get_row(source_name)

medication_columns = ["eb_b032a_med1_name_CHILDQ",
                      "eb_b033a_med2_name_CHILDQ",
                      "eb_b034a_med3_name_CHILDQ",
                      "eb_b035a_med4_name_CHILDQ",
                      "eb_b036a_med5_name_CHILDQ",
                      "eb_b037a_med6_name_CHILDQ",
                      "eb_b038a_med7_name_CHILDQ",
                      "eb_b039a_med8_name_CHILDQ",
                      "eb_b040a_med9_name_CHILDQ",
                      "eb_b041a_med10_name_CHILDQ"]

for col in medication_columns:
    respondent = 'epr_number:' + row['epr_number']
    answer = row[col]
    if answer != '.S' and answer != '.M':
        chebi_id = medication2chebi[answer.lower()]["chemical"]
        if answer is not None and chebi_id is not None:
            koza_app.write(Association(
                id="uuid:" + str(uuid.uuid1()),
                subject=respondent,
                predicate=Predicate.affected_by,
                object=chebi_id,
                source=source_name
            ))
        else:
            print(f"Could not find CHEBI for {answer}")

