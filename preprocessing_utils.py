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



sp_he = SourceProcessing("data/raw/epr_he/testPatientEpr_he_random_1.csv")

# phenotypes
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_he/subject2phenotype.yaml")
sp_he.return_ingest_specific_file("data/raw/epr_he/", "subject2phenotype")
# diseases
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_he/subject2disease.yaml")
sp_he.return_ingest_specific_file("data/raw/epr_he/", "subject2disease")
# respondent nodes
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_he/survey_respondents.yaml")
sp_he.return_ingest_specific_file("data/raw/epr_he/", "survey_respondents")

# exposures
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_he/subject2exposure.yaml")
sp_he.return_ingest_specific_file("data/raw/epr_he/", "subject2exposure")

# medical actions
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_he/subject2medaction.yaml")
sp_he.return_ingest_specific_file("data/raw/epr_he/", "subject2medaction")

# biological process
sp_he.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_he/subject2process.yaml")
sp_he.return_ingest_specific_file("data/raw/epr_he/", "subject2process")


# # exposome A (external) survey
# sp_expA = SourceProcessing("data/raw/data/raw/testPatientEpr_expA.csv")
#
# sp_expA.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_ExpA/subject2exposure.yaml")
# sp_expA.return_ingest_specific_file("data/raw/epr_expA", "subject2exposure")
#
# # exposome B (internal) survey
# sp_expB = SourceProcessing("data/raw/testPatientEpr_expB.csv")
#
# sp_expB.load_ingest_config("kg_pegs/transform_utils/pegs_surveys_ExpB/subject2exposure.yaml")
# sp_expB.return_ingest_specific_file("data/raw/epr_expB", "subject2exposure")