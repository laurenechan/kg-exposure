#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
from typing import Optional

from kg_pegs.transform_utils.transform import Transform
from koza.cli_runner import transform_source #type: ignore



PEGS_SOURCES = {
    'survey_respondent': 'testEPRsurvey_respondents.csv',
    'subject2phenotype': 'testEPRsubject2phenotype.csv',
    'subject2disease': 'testEPRsubject2disease.csv',
    'subject2exposure': 'testEPRsubject2exposure.csv',
    'subject2medaction': 'testEPRsubject2medaction.csv',
    'subject2process': 'testEPRsubject2process.csv'
}

PEGS_CONFIGS = {
    'survey_respondent': 'survey_respondents.yaml',
    'subject2phenotype': 'subject2phenotype.yaml',
    'subject2disease': 'subject2disease.yaml',
    'subject2exposure': 'subject2exposure.yaml',
    'subject2medaction': 'subject2medaction.yaml',
    'subject2process': 'subject2process.yaml'
}


TRANSLATION_TABLE = "./kg_pegs/transform_utils/translation_table.yaml"
LOCAL_TABLE = "./kg_pegs/transform_utils/pegs_surveys_he/translation_map_he.yaml"


class PegsSurveysTransform(Transform):
    """ This transform handles the Pegs Survey Subject 2 Phenotype Association Ingest
    """

    def __init__(self, input_dir: str = None, output_dir: str = None) -> None:
        source_name = "pegs_surveys_he"
        super().__init__(source_name, input_dir, output_dir)

    def run(self, pegs_file: Optional[str] = None) -> None:  # type: ignore
        """
        Set up Reactome file for Koza and call the parse function.
        """
        if pegs_file:
            for source in [pegs_file]:
                k = source.split('.')[0]
                data_file = os.path.join(self.input_base_dir, source)
                self.parse(k, data_file, k)
        else:
            for k in PEGS_SOURCES.keys():
                name = PEGS_SOURCES[k]
                data_file = os.path.join(self.input_base_dir, name)
                print('output ' +  data_file)
                self.parse(name, data_file, k)

    def parse(self, name: str, data_file: str, source: str) -> None:
        """
        Pegs parser
        """
        print(f"Parsing {data_file}")
        config = os.path.join("kg_pegs/transform_utils/pegs_surveys_he/",
                              PEGS_CONFIGS[source])
        output = self.output_dir
        # If source is unknown then we aren't going to guess
        if source not in PEGS_CONFIGS:
            raise ValueError(f"Source file {source} not recognized - not transforming.")
        else:
            print(f"Transforming using source in {config}")
            transform_source(source=config, output_dir=output,
                             output_format="tsv",
                             global_table=TRANSLATION_TABLE,
                             local_table=LOCAL_TABLE)
