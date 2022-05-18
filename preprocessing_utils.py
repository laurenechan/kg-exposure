import pandas as pd
import yaml
from yaml import FullLoader
import os
from pprint import pprint

# Declare environment variables
env = dict(os.environ)
env['PATH'] = os.environ['PATH']
env['PATH'] += os.pathsep


class SourceProcessing(object):
    def __init__(self, source_file_path):
        self.source_file_path = source_file_path
        self.sourc_file_df = self.load_source_file()
        self.ingest_config_yaml = None

    def load_source_file(self):
        return pd.read_csv(self.source_file_path)

    def load_ingest_config(self, config_path):
        with open(config_path, 'r') as cp:
            self.ingest_config_yaml = yaml.load(cp, Loader=FullLoader)

    def return_ingest_specific_file(self, output_path, ingest_name):
        columns = self.ingest_config_yaml['columns']
        self.sourc_file_df[columns].to_csv(f"{output_path}testEPR{ingest_name}.csv", index=False)



sp_he = SourceProcessing("data/raw/testPatientEpr_he_random_1.csv")
# phenotypes
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys/subject2phenotype.yaml")
sp_he.return_ingest_specific_file("data/raw/", "subject2phenotype")
#diseases
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys/subject2disease.yaml")
sp_he.return_ingest_specific_file("data/raw/", "subject2disease")
#respondent nodes
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys/survey_respondents.yaml")
sp_he.return_ingest_specific_file("data/raw/", "survey_respondents")

#exposures
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys/subject2exposure.yaml")
sp_he.return_ingest_specific_file("data/raw/", "subject2exposure")

#medical actions
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys/subject2medaction.yaml")
sp_he.return_ingest_specific_file("data/raw/", "subject2medaction")


#
# # exposome 1 survey
# sp_exp1 = SourceProcessing("data/raw/testPatientEpr_exp1_random_1.csv")
# sp_exp1.load_ingest_config("kg_pegs/transform_utils/pegs_surveys/subject2exposure.yaml")
# sp_exp1.return_ingest_specific_file("data/raw/", "subject2exposure")