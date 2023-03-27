import argparse
import numpy as np
import pandas as pd
from scipy.cluster.hierarchy import fcluster, linkage


def parse_args():
    parser = argparse.ArgumentParser(description='Cluster samples based on SNP distances.')
    parser.add_argument('-m', '--matrix', type=str, required=True,
                        help='Input matrix file name')
    parser.add_argument('-d', '--distance', type=float, default=1000,
                        help='Cluster distance threshold')
    parser.add_argument('-o', '--output', type=str, default='output.txt',
                        help='Output file name')
    parser.add_argument('-p','--paired', action="store_true",
                        help='Indicates that the pair distance input tab  is in long tabular form')
    return parser.parse_args()

def read_paried_tab(input_tab):
    # DataFrame from file
    df = pd.read_csv(input_tab, sep='\t', header=None, names=['row_name', 'col_name', 'value'])
    #  DataFrame to wide table
    df = df.pivot(index='row_name', columns='col_name', values='value')
    samples = df.index
    matrix = df.values
    return samples, matrix

def read_matrix(matrix_file):
    with open(matrix_file, 'r') as f:
        lines = f.readlines()
        # Skip the first line
        matrix_lines = lines[1:]
        # Get a list of sample names
        samples = lines[0].strip().split('\t')[1:]
        matrix = []
        for line in matrix_lines:
            values = line.strip().split('\t')[1:]
            row = [float(v) for v in values]
            matrix.append(row)
    return samples, np.array(matrix)


def cluster(samples, matrix, threshold, output_file):
    # Hierarchical clustering of distance matrices
    Z = linkage(matrix, 'ward')
    # Calculate clustering results based on clustering distance thresholds
    clusters = fcluster(Z, threshold, criterion='distance')
    # Write the clustering results to the output file
    with open(output_file, 'w') as f:
        for i in range(len(samples)):
            f.write(samples[i] + '\t' + str(clusters[i]) + '\n')



if __name__ == '__main__':
    args = parse_args()
    if args.paired:
        samples, matrix = read_paried_tab(args.matrix)
    else:
        samples, matrix = read_matrix(args.matrix)
    cluster(samples, matrix, args.distance, args.output)

