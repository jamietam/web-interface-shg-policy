#!/usr/bin/env python
from __future__ import division
import collections
from collections import OrderedDict
import csv
import glob
import json
import os
from os.path import join
import platform
import shutil
import time

from ipdb import set_trace

import matplotlib
matplotlib.use('Agg') 

from mako.template import Template
from matplotlib import pylab as plt
import matplotlib.pyplot as pl
from numpy import arange, array, ones, meshgrid, mean, ones_like
import pandas
from pandas import DataFrame, Series


# Module level constants
from inputs.files_and_ranges import *

# Uninitialized globals
executable = None
repeat = None
race = None
sex = None
yob = None
cessation_year = None
init_policy_deploy_year = None
init_fraction_already_covered = None
init_modifier = None
init_age_lower_limit = None
init_age_upper_limit = None
init_decay_rate = None
cess_policy_deploy_year = None
cess_fraction_already_covered = None
cess_modifier = None
cess_age_lower_limit = None
cess_age_upper_limit = None
cess_decay_rate = None


def read_demographics_file():
    global demographics
    demographics = pandas.read_csv(join('inputs', 'demographics.csv'))


def setup_local_run(input):

    globals().update(
        executable='lbc_smokehist.exe'
    )

    init_age_modifier = array(input['init_age_modifier'].split(','), dtype='float')
    init_percent_already_covered = 1 - init_age_modifier
    init_percent_already_covered = array(init_percent_already_covered, dtype='string')
    init_percent_already_covered = ','.join(init_percent_already_covered.tolist())

    cess_age_modifier = array(input['cess_age_modifier'].split(','), dtype='float')
    cess_percent_already_covered = 1 - cess_age_modifier
    cess_percent_already_covered = array(cess_percent_already_covered, dtype='string')
    cess_percent_already_covered = ','.join(cess_percent_already_covered.tolist())

    globals().update(
        init_fraction_already_covered=init_percent_already_covered,
        init_modifier=input['init_modifier'],
        init_age_lower_limit=input['init_age_lower_limit'],
        init_age_upper_limit=input['init_age_upper_limit'],
        init_decay_rate=input['init_decay_rate'],
        cess_fraction_already_covered=cess_percent_already_covered,
        cess_modifier=input['cess_modifier'],
        cess_age_lower_limit=input['cess_age_lower_limit'],
        cess_age_upper_limit=input['cess_age_upper_limit'],
        cess_decay_rate=input['cess_decay_rate'],
        init_policy_deploy_year=input['init_policy_deploy_year'],
        cess_policy_deploy_year=input['cess_policy_deploy_year']
    )


def parse_results(file_name, year):
    people = []
    sims = [sim.split(';')[0:-1] for sim in open(file_name, 'r').read().split('\n')[0:-1]]
    for sim in sims:
        person = dict(
            race=int(sim[0]),
            sex=int(sim[1]),
            yob=int(sim[2]),
            init_age=int(sim[3]),
            cess_age=int(sim[4]),
            ocd_age=int(sim[5]),
        )
        if person['init_age'] != -999:
            smoking_history = array(sim[6:], dtype='float')
            years = int(smoking_history.shape[0] // 2)
            person['smoking_history'] = smoking_history.reshape(years, 2)
        people.append(person)
    return people


def count_switchers(people):
    n_switchers = 0
    for person in people:
        if 'smoking_history' in person:
            smoking_history = person['smoking_history']
            sh_mean = mean(smoking_history[:, 1])
            if sh_mean != int(sh_mean):
                n_switchers += 1
    return n_switchers


def count_smokers(people):
    n_smokers = 0
    for person in people:
        if 'smoking_history' in person:
            n_smokers += 1
    return n_smokers


def populate_template(inputs):
    input_template = Template(open(join(templates_folder, 'input.txt.mako')).read())
    repeat, race, sex, yob, cessation_year = inputs
    suffix = '_'.join([str(i) for i in inputs])
    output_file = 'output_{suffix}.txt'.format(**locals())

    init_prob = join('data', data_directory, 'mod', glob.glob1(join('data', data_directory), '*init*')[0])
    cess_prob = join('data', data_directory, 'mod', glob.glob1(join('data', data_directory), '*cess*')[0])
    ocd_prob = join('data', data_directory, 'mod', glob.glob1(join('data', data_directory), '*oc*')[0])
    cpd_data = join('data', data_directory, 'mod', glob.glob1(join('data', data_directory), '*cpd*')[0])

    template_context = dict(globals(), **locals())
    return input_template.render(**template_context)


def run_smoking_history_generator(inputs):
    suffix = '_'.join([str(i) for i in inputs])
    smokehist_exe = executable
    path = input_folder
    if platform.system() == 'Windows':
        command_string = '{smokehist_exe} {path}/input_{suffix}.txt'.format(**locals())
    else:
        command_string = './{smokehist_exe} {path}/input_{suffix}.txt'.format(**locals())
    print 'running ' + command_string
    os.system(command_string)


def create_input_file_from_template(inputs):
    input_file_content = populate_template(inputs)
    suffix = '_'.join([str(i) for i in inputs])
    path = input_folder
    input_file = open('{path}/input_{suffix}.txt'.format(**locals()), 'w')
    input_file.write(input_file_content)
    input_file.close()


def remove_input_file():
    path = os.path.join(input_folder, 'input.txt')
    if os.path.exists(path):
        os.remove(path)


def create_plots_for_error_checking(init_am, init_am_cohort, cess_am, cess_am_cohort):
    plot_contour(ages, years, init_am, join('output', 'init_am.png'))
    plot_contour(ages, years[0:init_am.shape[1]], init_am_cohort[:,0:init_am.shape[1]], join('output', 'init_am_cohort.png'))
    plot_contour(ages, years, cess_am, join('output', 'cess_am.png'))
    plot_contour(ages, years[0:init_am.shape[1]], cess_am_cohort[:,0:init_am.shape[1]], join('output', 'cess_am_cohort.png'))

def modify_initiation():
    init_am = create_am(ages, years, 'init')
    init_am_cohort = transform_from_year_to_cohort(init_am)
    init_file_name = glob.glob1(os.path.join('data', data_directory), '*init*')[0]
    apply_am(
        src=join(src_folder, init_file_name),
        dest=join(dest_folder, init_file_name),
        am=init_am_cohort
    )
    return init_am, init_am_cohort


def modify_cessation():
    cess_am = create_am(ages, years, 'cess')
    cess_am_cohort = transform_from_year_to_cohort(cess_am)
    cess_file_name = glob.glob1(os.path.join('data', data_directory), '*cess*')[0]
    apply_am(
        src=join(src_folder, cess_file_name),
        dest=join(dest_folder, cess_file_name),
        am=cess_am_cohort
    )
    return cess_am, cess_am_cohort


def modify_input_parameter_files_per_policy():
    init_am, init_am_cohort = modify_initiation()
    cess_am, cess_am_cohort = modify_cessation()
    create_plots_for_error_checking(init_am, init_am_cohort, cess_am, cess_am_cohort)
    

def copy_file(file_name):
    shutil.copy(join(src_folder,  file_name), 
                join(dest_folder, file_name))


def remove_compiled_files():
    [os.remove(pyc_file) for pyc_file in glob.glob('*.pyc')]


def copy_unmodified_input_files():
    for file_name in untouched_input_files:
        copy_file(file_name)


def run_policy_module():
    copy_unmodified_input_files()
    modify_input_parameter_files_per_policy()


def remove_mod_input_files():
    path = join('data', data_directory, 'mod')
    files = glob.glob1(path, '*.txt')
    for f in files:
        os.remove(join(path, f))


def run_shg_module(inputs):
    create_input_file_from_template(inputs)
    run_smoking_history_generator(inputs)


def extract_run_from_string(lines):
    desired_lines = []
    app = False
    for line in lines:
        if '<RUN>' in line:
            app = True
        if app:
            desired_lines.append(line)
        if '</RUN>' in line:
            app = False
    return desired_lines[1:-1]


def extract_runs(shg_output_file, shg_output_runs):
    results = extract_run_from_string(open(shg_output_file).readlines())
    ofile = open(shg_output_runs, 'w')
    for result in results:
        ofile.write(result)
    ofile.close()
    return len(results)


def plot_life_histories(people, yob, n):
    global sex
    smokers = [person for person in people if 'smoking_history' in person]
    plt.figure()
    for smoker in smokers:
        xs = smoker['smoking_history'][0:smoker['ocd_age'] - smoker['init_age'] + 1, 0]
        ys = smoker['smoking_history'][0:smoker['ocd_age'] - smoker['init_age'] + 1, 1]
        plt.plot(xs, ys, 'k-', alpha=0.15)
    plt.xlabel('Age')
    plt.ylabel('Cigarettes Per Day')
    plt.xlim(xmin=0, xmax=90)
    plt.ylim(ymin=0, ymax=70)
    gender = ''
    if sex == 0:
        gender = 'Males'
    elif sex == 1:
        gender = 'Females'
    plt.title('Life Histories\n{n} {gender} Born in {yob}'.format(**locals()))
    plt.savefig(join('output', 'life_histories_{n}_{gender}_y{yob}'.format(**locals())).lower())
    plt.close()


def extract_switching_occurences(file_names):
    years = []
    switching_proportions = []
    for file_name in file_names:
        year = ''.join([s for s in file_name if s.isdigit()])
        people = parse_results(year, file_name=join('output', file_name),
                               use_year=True)
        switchers = count_switchers(people)
        smokers = count_smokers(people)
        switching_proportion = switchers / smokers
        years.append(year)
        switching_proportions.append(switching_proportion)
    return DataFrame({
        'years': Series(years),
        'switching_proportions': Series(switching_proportions)
    })


def survivors(people, age):
    return len([x for x in people if
                (x['ocd_age'] >= age or x['ocd_age'] == -999)])


def smokers(people, age):
    return len([x for x in people if
                (x['init_age'] <= age and x['init_age'] != -999) and
                (x['cess_age'] > age or x['cess_age'] == -999) and
                (x['ocd_age'] > age or x['ocd_age'] == -999)])


def former_smokers(people, age):
    return len([x for x in people if
                (x['cess_age'] < age and x['cess_age'] != -999) and
                (x['ocd_age'] > age or x['ocd_age'] == -999)])


def query_adjusted_rates(age):
    return init_and_cess_rates[(i_run, 'init', int(sex), int(yob), int(age))], init_and_cess_rates[(i_run, 'cess', int(sex), int(yob), int(age))]


def query_baseline_rates(age):
    return baseline_init_and_cess_rates[(i_run, 'init', int(sex), int(yob), int(age))], baseline_init_and_cess_rates[(i_run, 'cess', int(sex), int(yob), int(age))]


def calc_prevalence(people, inputs):
    age_prevalence = []
    yob = inputs[3]
    for age in range(100):
        n_smokers = smokers(people, age)
        n_survivors = survivors(people, age)
        n_former_smokers = former_smokers(people, age)
        init_rate, cess_rate = query_adjusted_rates(age)
        baseline_init_rate, baseline_cess_rate = query_baseline_rates(age)
        year = yob + age
        if n_survivors and year <= 2100:
            entry = OrderedDict()
            entry['policy_number'] = int(i_run)
            entry['race'] = int(0)
            entry['gender'] = int(sex)
            entry['cohort'] = int(yob)
            entry['age'] = int(age)
            entry['year'] = int(yob + age)
            entry['baseline_initiation_rate'] = float(baseline_init_rate)
            entry['baseline_cessation_rate'] = float(baseline_cess_rate)
            entry['initiation_rate'] = float(init_rate)
            entry['cessation_rate'] = float(cess_rate)
            entry['survivors'] = int(n_survivors)
            entry['alive_smokers'] = int(n_smokers)
            entry['smoking_prevalence'] = float(n_smokers / n_survivors)
            entry['former_smokers'] = int(n_former_smokers)
            entry['former_prevalence'] = float(n_former_smokers / n_survivors)
            age_prevalence.append(entry)
    return age_prevalence


def post_process_shg(inputs):
    suffix = '_'.join([str(i) for i in inputs])
    runs_file = join('output', 'output_runs_{suffix}.txt'.format(**locals()))
    n = extract_runs(shg_output_file=join('output',
                     'output_{suffix}.txt').format(**locals()),
                     shg_output_runs=runs_file)

    # create life histories json file
    people = parse_results(runs_file, yob)
    plot_life_histories(people=people, yob=yob, n=n)
    for person in people:
        if 'smoking_history' in person:
            person['smoking_history'] = person['smoking_history'].tolist()
    open(join('output', 'individuals_{suffix}.json'.format(**locals())), 'w').write(json.dumps(people, indent=2))

    # create prevalence results file
    prevalence = calc_prevalence(people, inputs)
    open(join('output', 'prevalence_{suffix}.json'.format(**locals())), 'w').write(json.dumps(prevalence, indent=2))


def delete_smoking_histories(individuals):
    for individual in individuals:
        if 'smoking_history' in individual:
            individual.pop('smoking_history')
    return individuals


def write_histories_csv(individuals):
    individuals = delete_smoking_histories(individuals)
    individuals_csv_file = open(join('output', 'individuals.csv'), 'w')
    keys = individuals[0].keys()
    dict_writer = csv.DictWriter(individuals_csv_file, keys)
    dict_writer.writer.writerow(keys)
    dict_writer.writerows(individuals)


def write_prevalence_csv(prevalences):
    keys = prevalences[0].keys()
    prevalences_csv_file = open('prevalences.csv', 'wb')
    dict_writer = csv.DictWriter(prevalences_csv_file, keys)
    dict_writer.writer.writerow(keys)
    dict_writer.writerows(prevalences)


def combine_results():
    prevalence_files = []
    for r, d, f in os.walk('runs'):
        for files in f:
            if files.endswith('json') and files.startswith('prev'):
                prevalence_files.append(os.path.join(r, files))
    print prevalence_files
    prevalences = []
    for prevalence_file in prevalence_files:
        for prevalence in json.loads(open(prevalence_file).read(), object_pairs_hook=collections.OrderedDict):
            prevalences.append(prevalence)
    with open('prevalence.json', 'w') as prevalences_file:
        prevalences_file.write(json.dumps(prevalences, indent=2))

    print 'len(prevalences) = ' + str(len(prevalences))

    write_prevalence_csv(prevalences)


def run_shgs():
    for row in demographics.itertuples():
        i = row[0]; inputs = row[1:]
        globals().update(
            repeat=inputs[0],
            race=inputs[1],
            sex=inputs[2],
            yob=inputs[3],
            cessation_year=inputs[4]
        )
        run_shg_module(inputs)
        post_process_shg(inputs)


def apply_am(src, dest, am):
    global init_and_cess_rates
    global baseline_init_and_cess_rates
    file_contents = open(src, 'r').readlines()
    n_header_lines = int(file_contents[0].strip()) + 1

    if 'init' in dest:
        mode = 'init'
    elif 'cess' in dest:
        mode = 'cess'

    # Write header lines
    dest = open(dest, 'w')
    [dest.write(file_contents[i]) for i in range(n_header_lines)]

    # Transform and write remaining rows
    for n_row, row in enumerate(file_contents[n_header_lines:]):
        new_cells = []
        gender, age = row.split(',')[1:3]
        for n_column, cell in enumerate(row.split(',')):
            if n_column >= 3:
                yob = file_contents[5].split(',')[n_column].split('-')[0]
                composite_key = (i_run, mode, int(gender), int(yob), int(age))
                baseline_init_and_cess_rates[composite_key] = float(cell)
                cell = float(cell) * am[n_row % 100, n_column - 3]
                init_and_cess_rates[composite_key] = float(cell)
                cell = '%11.9f' % cell
            new_cells.append(cell)
        dest.write(','.join(new_cells) + '\n')
    dest.close()


def transform_from_year_to_cohort(adj_mat):
    M, N = adj_mat.shape
    adj_mat_transformed = ones((M, M + N - 1))
    for age in range(M):
        for calendar_year in range(N):
            cohort = calendar_year - age
            adj_mat_transformed[age, cohort] = adj_mat[age, calendar_year]
    return adj_mat_transformed


def create_am(ages, years, pre):
    am = ones((len(ages), len(years)))
    if pre is 'init':
        mods = array(init_modifier.split(','), dtype='float')
        reducer = 1 - array(init_fraction_already_covered.split(','), dtype='float')
        deploy_years = array(init_policy_deploy_year.split(','), dtype='int')
        lower_ages = array(init_age_lower_limit.split(','), dtype='int')
        upper_ages = array(init_age_upper_limit.split(','), dtype='int')
        decay_rate = 1 - array(init_decay_rate.split(','), dtype='float')
        mods = mods * reducer
        deploy_years = deploy_years - years[0]
        for i in range(len(deploy_years)):
            temp = ones((len(ages), len(years)))
            for j in range(deploy_years[i], am.shape[1]):
                temp[lower_ages[i]:upper_ages[i], j] = 1-mods[i] * (decay_rate[i]) ** (j - deploy_years[i])
            am = am * temp
    elif pre is 'cess':
        mods = array(cess_modifier.split(','), dtype='float')
        reducer = 1 - array(cess_fraction_already_covered.split(','), dtype='float')
        deploy_years = array(cess_policy_deploy_year.split(','), dtype='int')
        lower_ages = array(cess_age_lower_limit.split(','), dtype='int')
        upper_ages = array(cess_age_upper_limit.split(','), dtype='int')
        decay_rate = 1 - array(cess_decay_rate.split(','), dtype='float')
        mods = mods * reducer
        deploy_years = deploy_years - years[0]
        for i in range(len(deploy_years)):
            temp = ones((len(ages), len(years)))
            for j in range(deploy_years[i], am.shape[1]):
                temp[lower_ages[i]:upper_ages[i], j] = 1+mods[i]  * (decay_rate[i]) ** (j - deploy_years[i])
            am = am * temp
    return am


def plot_contour(x, y, z, file_name):
    xx, yy = meshgrid(y, x)
    plt.figure()
    plt.pcolor(xx, yy, z, vmax=abs(z).max(), vmin=abs(z).min())
    cbar = plt.colorbar()
    cbar.ax.set_ylabel('Scalar Modifier', rotation=270)
    plt.xlabel('Calendar Years')
    plt.ylabel('Age')
    with open(str(file_name), 'wb') as f:
        plt.savefig(f, format='png')
    plt.close()

def csv_to_list_of_dicts(ifile):
    ifile = open(ifile, 'r')
    contents = ifile.read()
    ifile.close()
    lines = contents.split('\n')
    list_of_dicts = []
    for i, line in enumerate(lines):
        if i is 0:
            fields = line.split(';')
            fields = [f.strip() for f in fields]
        else:
            keys = fields
            values = line.split(';')
            values = [v.strip() for v in values]
            obj = dict(zip(keys, values))
            for key, value in obj.items():
                if ';' in value:
                    obj[key] = value.replace(';', ',')
            list_of_dicts.append(obj)
    return list_of_dicts

def remove_old_runs():
    if os.path.exists('runs'):
        shutil.rmtree('runs')
    if os.path.exists('output'):
        shutil.rmtree('output')
    if not os.path.exists('output'):
        os.mkdir('output')

def move_outputs(inputs):
    if not os.path.exists('runs'):
        os.mkdir('runs')
    shutil.move('output', join('runs', 'run' + str(i_run)))
    if not os.path.exists('output'):
        os.mkdir('output')

def main():
    print 'Removing previously compiled python files'
    remove_compiled_files()

    print 'Removing old input files and old runs'
    print 'Note, this module only cleans up before runs, not after'
    try:
        [os.remove(f) for f in glob.glob('input_*')]
    except:
        pass
    try:
        shutil.rmtree('output')
    except:
        pass
    try:
        remove_old_runs()
    except:
        pass


    global init_and_cess_rates
    global baseline_init_and_cess_rates
    global demographics
    init_and_cess_rates = {}
    baseline_init_and_cess_rates = {}

    print 'Reading inputs'
    inputs = csv_to_list_of_dicts(os.path.join('inputs', 'policies.csv'))
    read_demographics_file()

    shutil.copy(join('executables', version, exe_name), './lbc_smokehist.exe')

    print 'Running the simulations:'
    for i_run, run_input in enumerate(inputs):
        time.sleep(2)
        print 'run number ' + str(i_run)
        globals().update(i_run=i_run)
        setup_local_run(run_input)
        run_policy_module()
        run_shgs()
        move_outputs(run_input)
    
    print 'Cleaning up'
    combine_results()
    os.remove('./lbc_smokehist.exe')

    print 'Formatting output'
    os.system("node convert-results.js")
    [os.remove(f) for f in glob.glob('prev*') if f != 'prevalences.csv']

    # Try to move the prevalence file to the viewer if possible
    try:
        # rename existing file by its modification date
        dest = join('..', 'recline', 'demos', 'shg-demo', 'prevalences.csv') 
        mod_time = os.path.getmtime(dest)
        shutil.copy(dest, dest.replace('.csv', '_' + str(mod_time).split('.')[0] + '.csv'))
        shutil.copy('prevalences.csv', join('..', 'recline', 'demos', 'shg-demo'))
    except:
        print 'For one reason or another, I could not move your prevalence results over to recline.js for viewing'


if __name__ == '__main__':
    main()
