from collections import defaultdict

def parse_keyfile(fname):
    my_dict = defaultdict(str)
    with open(fname) as f:
        for line in f:
            fields = line.strip().split(' ')
            k = fields[0].replace(':', '')
            v = fields[1]
            my_dict[k] = v
    return(my_dict)


chebi_file = 'translation_map_nutrients.yaml'

chebi_d = parse_keyfile(chebi_file)
# print(f'we got {len(chebi_d)} chebi items')
# for k,v in chebi_d.items():
#     print(k,v)


foodon_file = 'translation_map_foodon2fdc_id.yaml'

foodon_d = parse_keyfile(foodon_file)
# print(f'we got {len(foodon_d)} foodon items')
# for k,v in foodon_d.items():
#     #print(k,v)

fname = '../../../data/raw/food_nutrient_raw_data.csv'
edgefile = '../../../data/transformed/USDA_nutrients/foodon2chebi.tsv'
predicate = 'biolink:has_nutrient'


with open(fname) as f, open(edgefile, 'wt') as edges:
    for line in f:
        fields = line.strip().split(',')
        print(fields)
        fdc_id = fields[1]
        nutrient_id = fields[2]
        if fdc_id in foodon_d:
            foodon = foodon_d[fdc_id]
        else:
            foodon = 'FDC:' + fdc_id

        #chebi = chebi_d.get(nutrient_id, 'na')
        if nutrient_id in chebi_d:
            chebi = chebi_d[nutrient_id]
        else:
            chebi = 'NUTR:' + nutrient_id

        print(foodon, chebi)
        edges.write('\t'.join([foodon, predicate, chebi]))
        edges.write('\n')
