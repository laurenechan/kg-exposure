import unittest
from parameterized import parameterized
from kg_pegs.utils.transform_utils import guess_bl_category, collapse_uniprot_curie
from kg_pegs.transform_utils.pegs_surveys import PegsSurveysTransform
import os

class TestTransformUtils(unittest.TestCase):
    def setUp(self) -> None:
        self.input_dir = 'tests/resources/'
        self.output_dir = 'tests/resources/'

    @parameterized.expand([
        ['', 'biolink:NamedThing'],
        ['UniProtKB', 'biolink:Protein'],
        ['ComplexPortal', 'biolink:Protein'],
        ['GO', 'biolink:OntologyClass'],
    ])
    def test_guess_bl_category(self, curie, category):
        self.assertEqual(category, guess_bl_category(curie))

    @parameterized.expand([
        ['foobar', 'foobar'],
        ['ENSEMBL:ENSG00000178607', 'ENSEMBL:ENSG00000178607'],
        ['UniprotKB:P63151-1', 'UniprotKB:P63151'],
        ['uniprotkb:P63151-1', 'uniprotkb:P63151'],
        ['UniprotKB:P63151-2', 'UniprotKB:P63151'],
    ])
    def test_collapse_uniprot_curie(self, curie, collapsed_curie):
        self.assertEqual(collapsed_curie, collapse_uniprot_curie(curie))


    def test_pegs_survey_transform(self):
        t = PegsSurveysTransform(self.input_dir, self.output_dir)
        this_output_dir = os.path.join(self.output_dir, "pegs_survey")
        t.run()

        # self.assertTrue(os.path.exists(this_output_dir))
        # shutil.rmtree(this_output_dir)
