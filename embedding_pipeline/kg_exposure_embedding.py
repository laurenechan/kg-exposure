#!/usr/bin/env python3
# -*- coding: utf-8 -*-

!python -m pip uninstall matplotlib
!pip install matplotlib==3.1.3 -U
!pip install -qU grape

# kg_file = ../../data/merged/merged-kg.tar.gz
#
# !tar -xvzf kg_file
# merged_node_filename='merged-kg_nodes.tsv'
# merged_edge_filename='merged-kg_edges.tsv'
#
# # this is a very high degree node that isn't meaningful for node embeddings
# # Definition: A term that is metadata complete, has been reviewed, and problems have been identified that require discussion before release. Such a term requires editor note(s) to identify the outstanding issue
# !grep -v IAO:0000428 merged-kg_edges.tsv > tmp
# !mv tmp merged-kg_edges.tsv
#
# from grape import Graph
#
# g = Graph.from_csv(
#     node_path=merged_node_filename,
#     edge_path=merged_edge_filename,
#     node_list_separator="\t",
#     edge_list_separator="\t",
#     node_list_header=True,  # Always true for KG-Hub KGs
#     edge_list_header=True,  # Always true for KG-Hub KGs
#     nodes_column='id',  # Always true for KG-Hub KGs
#     node_list_node_types_column='category',  # Always true for KG-Hub KGs
#     sources_column='subject',  # Always true for KG-Hub KGs
#     destinations_column='object',  # Always true for KG-Hub KGs
#     directed=False,
#     name="kg-exposure",
#     verbose=True
# )
# g
#
# # select largest components
# g = g.remove_disconnected_nodes()
# g = g.remove_components(top_k_components=1)
# #connected component , pick the biggest connected component, the space where there is a large connection, needs the main connected component, won't be
# #able to look at stuff that is beyond the main component since it doesn't have that much info
#
# from grape.embedders import FirstOrderLINEEnsmallen
# embedding = FirstOrderLINEEnsmallen().fit_transform(g)
#
# from grape import GraphVisualizer
# visualizer = GraphVisualizer(g)
#
# # You can either provide the model name
# #visualizer.fit_nodes("First-order LINE", library_name="Ensmallen")
# # Or provide a precomputed embedding
# #
# # visualizer.fit_nodes(numpy_array_with_embedding)
# # visualizer.fit_nodes(pandas_dataframe_with_embedding)
# #
# # or alternatively provide the model to be used:
# #
# # from grape.embedders import FirstOrderLINEEnsmallen
# # visualizer.fit_nodes(FirstOrderLINEEnsmallen())
# #
# # In this tutorial, we use the embedding we have just computed above:
#
# visualizer.fit_nodes(embedding)
#
# # And now we can visualize the node types:
# visualizer.plot_node_types()
#
# visualizer.plot_node_degree_distribution()
#
# # lots of nodes with very few neighbors
#
# visualizer.fit_and_plot_all(embedding)
#
# from grape.edge_prediction import RandomForestEdgePrediction
# #from grape.embedders import FirstOrderLINEEnsmallen
# #from grape.datasets.string import HomoSapiens
#
# # %%time
# # graph = HomoSapiens()\
# #     .filter_from_ids(min_edge_weight=700)\
# #     .remove_disconnected_nodes()
#
# train, test = g.connected_holdout(train_size=0.7)
#
# # Commented out IPython magic to ensure Python compatibility.
# # %%time
# # embedding = FirstOrderLINEEnsmallen().fit_transform(train)
#
# # Commented out IPython magic to ensure Python compatibility.
# # %%time
# # model = RandomForestEdgePrediction()
# # model.fit(
# #     graph=train,
# #     node_features=embedding
# # )
#
# [
#     method_name
#     for method_name in dir(model)
#     if method_name.startswith("predict")
# ]
#
# # Commented out IPython magic to ensure Python compatibility.
# # %%time
# # # A perfect model should correctly predict the existance
# # # of all of these edges.
# # model.predict_proba(
# #     graph=test,
# #     node_features=embedding,
# #     return_predictions_dataframe=True
# # )
#
# # Commented out IPython magic to ensure Python compatibility.
# # %%time
# # # A perfect model should correctly predict the non-existance
# # # of all of these edges.
# # model.predict_proba(
# #     graph=graph.sample_negative_graph(number_of_negative_samples=test.get_number_of_edges()),
# #     node_features=embedding,
# #     return_predictions_dataframe=True
# )