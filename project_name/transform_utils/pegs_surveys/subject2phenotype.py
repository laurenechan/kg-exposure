import uuid

from biolink_model_pydantic.model import ( #type: ignore
    OrganismalEntity,
    PhenotypicFeature,
    Predicate,
    EntityToPhenotypicFeatureAssociation
)

# from koza.cli_runner import koza_app #type: ignore
#
# source_name="subject2phenotype"
# full_source_name="pegs_survey"
#
# row = koza_app.get_row(source_name)
#print(row)


# hp_curie = koza_app.translation_table.resolve_term(row["variable"])
# print(hp_curie)

# # Entities
# subject = OrganismalEntity(id='epr_number:' + row['epr_number'])
# phenotype = PhenotypicFeature(id=hp_curie,
#                     source=full_source_name)
#
#
#
# # if str(row["he_b007_hypertension_PARQ"]) != '1':
# #     koza_app.next_row()
#
#
#
# # Association
# association = EntityToPhenotypicFeatureAssociation(
#     id="uuid:" + str(uuid.uuid1()),
#     subject=subject.id,
#     predicate=Predicate.has_phenotype,
#     object=phenotype.id,
#     source=full_source_name
# )

#koza_app.write(subject, association, phenotype)

