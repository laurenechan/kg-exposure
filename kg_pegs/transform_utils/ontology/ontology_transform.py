import os
import gzip
import shutil
from typing import Optional

from kg_pegs.transform_utils.transform import Transform
from kg_pegs.utils.robot_utils import convert_to_json
#from kgx import PandasTransformer, ObographJsonTransformer  # type: ignore
from kgx.cli.cli_utils import transform


ONTOLOGIES = {
    'ChebiTransform': 'chebi_kgx_tsv.tar.gz',
    'EnvoTransform': 'envo_kgx_tsv.tar.gz',
    'MondoTransform': 'mondo_kgx_tsv.tar.gz',
    'HpTransform': 'hp_kgx_tsv.tar.gz',
    'EctoTransform': 'ecto_kgx_tsv.tar.gz',
    'MaxoTransform': 'maxo_kgx_tsv.tar.gz',
    'FoodonTransform': 'foodon_kgx_tsv.tar.gz'
}

class OntologyTransform(Transform):
    """
    OntologyTransform parses an Obograph JSON form of an Ontology into nodes and edges.
    If it isn't in Obograph JSON format, it is transformed with ROBOT.
    If it needs to be decompressed, that happens here too.
    """
    def __init__(self, input_dir: str = None, output_dir: str = None):
        source_name = "ontologies"
        super().__init__(source_name, input_dir, output_dir)

    def run(self, data_file: Optional[str] = None) -> None:
        """Method is called and performs needed transformations to process
        an ontology.
        Args:
            data_file: data file to parse
        Returns:
            None.
        """
        if data_file: # if we specify a data file
            k = data_file.split('.')[0]
            data_file = os.path.join(self.input_base_dir, data_file)
            self.parse(k, data_file, k)
        else:
            # load all ontologies
            for k in ONTOLOGIES.keys():
                data_file = os.path.join(self.input_base_dir, ONTOLOGIES[k])
                self.parse(k, data_file, k)

    def parse(self, name: str, data_file: str, source: str) -> None:
        """Processes the data_file.
        Args:
            name: Name of the ontology
            data_file: data file to parse
            source: Source name
        Returns:
             None.
        """
        print(f"Parsing {data_file}")

        transform(inputs=[data_file], 
                    input_format='tsv',
                    input_compression='tar.gz',
                    output= os.path.join(self.output_dir, name), 
                    output_format='tsv')