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
associations=[]

for col, value in row.items():
    if value == "1":
        print(respondent, col, value)

## we need to figure out how to select the correct cells to select from, the class is str, typing might be missing, line 24 conditional not working

# mondo_curies=[]
# for col in [x for x in row.keys() if x != 'epr_number']:
#     # if str(row[col]) == '1':
#     #     print(col)
#         mondo_curie = koza_app.translation_table.resolve_term(col)
#         mondo_curies.append(mondo_curie)
#         # # Association
#         association = EntityToDiseaseAssociation(
#             id="uuid:" + str(uuid.uuid1()),
#             subject=respondent,
#             predicate=Predicate.affected_by,
#             object=mondo_curie,
#             source=full_source_name
#         )
#         associations.append(association)
# print(respondent)
# print(associations)
# print(mondo_curies)
# for assoc in associations:
#     koza_app.write(assoc)



