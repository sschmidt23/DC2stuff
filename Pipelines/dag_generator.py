#!/usr/bin/env python
import os
import glob
import argparse
import subprocess
import yaml

parser = argparse.ArgumentParser()
parser.add_argument('cwl_file', help='Workflow description file')
parser.add_argument('--workflow_name', type=str, default=None,
                    help='Workflow name. If None, derive from cwl_file name.')
args = parser.parse_args()

workflow_name = args.workflow_name
if workflow_name is None:
    workflow_name = os.path.basename(args.cwl_file[:-len('.cwl')])

workflow = yaml.load(open(args.cwl_file))

steps = workflow['steps'].keys()
data_products = set()
for step, dependencies in workflow['steps'].items():
    data_products.update(dependencies['in'].keys())
    data_products.update(dependencies['out'])

dotfile = '%s.dot' % workflow_name
pngfile = '%s.png' % workflow_name
with open(dotfile, 'w') as output:
    output.write('digraph %s {\n' % workflow_name)
    output.write('; '.join(['node [shape=ellipse]'] + steps) + '\n')
    output.write('; '.join(['node [shape=box]'] + list(data_products)) + '\n')
    for step, deps in workflow['steps'].items():
        for dp in deps['in'].keys():
            output.write('"%s" -> %s;\n' % (dp, step))
        for dp in deps['out']:
            output.write('%s -> "%s";\n' % (step, dp))
    output.write('}\n')
subprocess.check_call('dot -Tpng %s > %s' % (dotfile, pngfile), shell=True)

for item in glob.glob(dotfile):
    os.remove(item)
