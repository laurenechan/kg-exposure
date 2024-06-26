#!/usr/bin/env python
# -*- coding: utf-8 -*-
import logging
from typing import List

from kg_pegs.transform_utils.ontology.ontology_transform import ONTOLOGIES
from kg_pegs.transform_utils.pegs_surveys_he.pegs_surveys_he import PegsSurveysTransform as PegsSurveysTransformHe
from kg_pegs.transform_utils.pegs_surveys_exposomeA.pegs_surveys_exposomeA import PegsSurveysTransform as PegsSurveysTransformExpA
from kg_pegs.transform_utils.pegs_surveys_exposomeB.pegs_surveys_exposomeB import PegsSurveysTransform as PegsSurveysTransformExpB
from kg_pegs.transform_utils.usda_acup.ag_chems_transform import AgChemTransform as AgChemTransform

from kg_pegs.transform_utils.ontology import OntologyTransform
from kg_pegs.transform_utils.ontology.ontology_transform import ONTOLOGIES

DATA_SOURCES = {
    'PegsSurveysTransformHe': PegsSurveysTransformHe,
    'PegsSurveysTransformExpA': PegsSurveysTransformExpA,
    'PegsSurveysTransformExpB': PegsSurveysTransformExpB,
    'AgChemTransform': AgChemTransform,
    'MondoTransform': OntologyTransform,
    'ChebiTransform': OntologyTransform,
    'EnvoTransform': OntologyTransform,
    'HpTransform': OntologyTransform,
    'EctoTransform': OntologyTransform,
    'MaxoTransform': OntologyTransform,
    'FoodonTransform': OntologyTransform,
    'GOTransform': OntologyTransform
}

def transform(input_dir: str, output_dir: str, sources: List[str] = None) -> None:
    """Call scripts in kg_pegs/transform/[source name]/ to transform each source into a graph format that
    KGX can ingest directly, in either TSV or JSON format:
    https://github.com/biolink/kgx/blob/master/specification/kgx-format.md

    Args:
        input_dir: A string pointing to the directory to import data from.
        output_dir: A string pointing to the directory to output data to.
        sources: A list of sources to transform.

    Returns:
        None.

    """
    if not sources:
        # run all sources
        sources = list(DATA_SOURCES.keys())

    for source in sources:
        if source in DATA_SOURCES:
            logging.info(f"Parsing {source}")
            t = DATA_SOURCES[source](input_dir, output_dir)
            if source in ONTOLOGIES.keys():
                t.run(ONTOLOGIES[source])
            else:
                t.run()
