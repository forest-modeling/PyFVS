import os
import subprocess
import shutil
import re

from setuptools import Command
from skbuild import setup

# FIXME: reconcile README and copy to pyfvs package
description = open('./pyfvs/README.txt').readline().strip()
long_desc = open('./pyfvs/README.txt').read().strip()

version_path = 'pyfvs/_version.py'

def update_version():
    """
    Update the contents of _version.py with Git metadata.
    """
    try:
        r = subprocess.check_output(['git', 'status'])
        
    except:
        print('Error: git must be available in the PATH environment.')
        raise
        
    contents = open(version_path).read()
    s = re.search(r'__version__ = \'(?P<version>.*)\'', contents)
    version = s.group('version')
    
    commit = subprocess.check_output(
            ['git', 'rev-parse', '--short', '--verify', 'HEAD']
            ).decode('utf-8').strip()
    
    # Check for dirty state
    r = subprocess.check_output(
            ['git', 'status', '--short', '-uno']
            ).decode('utf-8').strip()
    if r:
        commit += '-dirty'
    
    contents = re.sub(
            r"(__git_commit__) = '(.*)'"
            , r"\1 = '{}'".format(commit)
            , contents)
    
    try:
        desc = subprocess.check_output(
                ['git', 'describe', '--tags', '--dirty']
                ).decode('utf-8').strip()
        
        # Check the most recent tag version
        m = re.match('pyfvs-v(?P<version>\d+\.\d+\.\d+)(.*)', desc)
        if m:
            tag_version = m.group('version')
        else:
            tag_version = version
        
        # If this is a more recent version, e.g. release canditate
        if version>tag_version:
            desc = ''
    
    except:
        # For shallow clones git describe may fail.
        desc = ''
        
    contents = re.sub(
            r"(__git_describe__) = '(.*)'"
            , r"\1 = '{}'".format(desc)
            , contents)

    fn = os.path.join(os.path.dirname(__file__), version_path)
    with open(fn, 'w') as fp:
        fp.write(contents)

    print('Updated {}: {}'.format(version_path, desc))

def get_version():
    try:
        f = open(version_path)
    except EnvironmentError:
        return None
    for line in f.readlines():
        mo = re.match("__version__ = '([^']+)'", line)
        if mo:
            ver = mo.group(1)
            return ver
    return None

class Version(Command):
    description = "update {} from Git repo".format(version_path)
    user_options = []
    boolean_options = []
    def initialize_options(self):
        pass
    def finalize_options(self):
        pass
    def run(self):
        update_version()
        print('Version is now {}'.format(get_version()))

setup(
    name='pyfvs'
    , version=get_version()
    , description=description
    , long_description=long_desc
    , url='https://github.com/forest-modeling/PyFVS'
    , download_url='https://github.com/forest-modeling/PyFVS/archive/main.zip'
    , author="Tod Haren"
    , author_email="tod.haren@gmail.com"
    , setup_requires=['numpy', 'cython'] #, 'skbuild', 'ninja', 'cmake', 'm2w64-gcc-fortran']
    , tests_require=['pytest',]
    , install_requires=['numpy',]
    , packages=['pyfvs', 'pyfvs.keywords']
    , package_data={
            # '.':['*.pyd', '*.cfg', '*.so', 'README.*']
            'pyfvs':[
                '*.yaml'
                , 'docs/*'
                , 'examples/*'
                , 'test/*.py'
                , 'test/*.db'
                , 'test/rmrs/*.key'
                , 'test/rmrs/*.save'
                ]
            }
    , include_package_data=True # package the files listed in MANIFEST.in
    , entry_points={
            'console_scripts': ['pyfvs=pyfvs.__main__:cli']
        }
    , classifiers=[
            'Development Status :: 3 - Alpha'
            , 'Environment :: Console'
            , 'Intended Audience :: Developers'
            , 'Intended Audience :: End Users/Desktop'
            , 'Intended Audience :: Science/Research'
            , 'Natural Language :: English'
            , 'Programming Language :: Python'
            , 'Programming Language :: Fortran'
            ]
    , keywords=''
    , cmdclass={"version": Version, }
    , cmake_args=['-DFVS_VARIANTS=wc,pn,op,oc,so,ca',] #,ec',] 
    )