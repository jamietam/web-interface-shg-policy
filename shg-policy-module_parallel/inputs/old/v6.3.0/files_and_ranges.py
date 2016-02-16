import os
import os.path
from numpy import arange
import platform

version = 'v6.3.0'
if platform.system() == 'Windows':
    exe_name = 'lbc_smokehist_win.exe'
elif platform.system() == 'Darwin':
    exe_name = 'lbc_smokehist_osx.exe'
elif platform.system == 'Linux':
    exe_name = 'lbc_smokehist_linux.exe'

input_folder = '.'
templates_folder = 'templates'
src_folder = 'data/' + version
dest_folder = src_folder + '/mod'
ages = arange(100)
cohorts = arange(1890, 2091)
years = arange(1890, 2190)

untouched_input_files = os.listdir(os.path.join('data', version))
untouched_input_files = [ifile for ifile in untouched_input_files if ifile != 'mod']

