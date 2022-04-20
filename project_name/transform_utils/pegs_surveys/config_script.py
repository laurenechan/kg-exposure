import yaml
import pandas as pd
from pprint import pprint
with open("subject2phenotype.yaml", "r") as s2p:
    s2py = yaml.load(s2p)
    pprint(s2py.keys())

columns = pd.read_csv("../../../data/raw/epr_he.csv").columns
print(list(columns))
s2py["columns"] = list(columns)

with open("subject2phenotypetest.yaml", "w") as s2p:
    yaml.dump(s2py, s2p)