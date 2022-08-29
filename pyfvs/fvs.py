"""
pyfvs.fvs

Class module for controlling and interogating FVS using the Python variant
modules compiled with Open-FVS.

Created on Nov 29, 2014

@author: tod.haren@gmail.com
"""

from dataclasses import field
from distutils.log import debug
import os
import sys
import re
import shutil
import logging
import logging.config
import random
import importlib
import tempfile
import warnings
import datetime

import numpy as np
import pandas as pd
import pandas.io

import pyfvs
from pyfvs.keywords import keywords as kw

# FIXME: This is a hack for PyDev scripting
# os.chdir(os.path.split(__file__)[0])

pyfvs.init_logging()
log = logging.getLogger('pyfvs.fvs')

def deprecation(msg, level=1):
    """
    Warn users about deprecated features.
    """
    if level==1:
        warnings.warn(msg, DeprecationWarning, stacklevel=2)

    elif level>1:
        raise RuntimeError(msg)

class FVS(object):
    """
    Provides an abstraction layer and convenience methods for running FVS.

    Access to the FVS API routines as well as additional FVS core routines,
        and common arrays and variables are accessible using standard Python
        attribute access conventions, eg. cycles = fvs.globals.ncyc to find out
        how many projection cycles were executed. API and other subroutines
        have expected input variables and return numpy arrays or Python objects.

    See the auto-generated HTML help file provided with each variant library
        for a complete list of available subroutines and common variables.

    * NOTE: The FVS subroutines, etc. are all converted to lower case by F2PY.

    Attributes:
        variant: FVS variant abbreviation, PN, WC, etc. (Required)
        stochastic: If True the FVS random number generater will be
                reseeded on each run. If False the generator will
                be set to a fixed value of 1.0. (Optional)
        bootstrap: Number of bootstrap resamples of the plot data to
                execute. (Optional)

    Usage:
        fvs = FVS(<variant abbreviation>)
        fvs.run_fvs(<path to keyword file>)

       # Return a tuple of species codes given an FVS ID using the FVS API.
       spp_attrs = fvs.fvsspeciescode(16)
    """
    def __init__(self, variant, stochastic=False, bootstrap=0, cleanup=True, treelist_format=None
            , workspace=None):
        """
        Initialize a FVS variant library.
        """
        # TODO: Document configuration options

        self.variant = variant
        self.stochastic = stochastic
        self.bootstrap = bootstrap
        self.cleanup = cleanup
        self.workspace = workspace

        self.root = None
        self.keywords_file = None

        # Resolve the confuse configuration files
        self.config = pyfvs.config

        self._random_seed = 55329  # Default FVS random number seed

        self.fvslib_path = None
        self.fvslib = None

        if self._workspace is None:
            self._workspace = self.config['workspace'].get()

        if treelist_format is None:
            # Use the default PyFVS treelist template
            self.treelist_tmplt = pyfvs.treelist_format['template']
            self.treelist_fmt = pyfvs.treelist_format['fvs_format']

        else:
            self.treelist_tmplt = treelist_format['template']
            self.treelist_fmt = treelist_format['fvs_format']

        self._tree_fields = re.findall('{(.+?):.*?}', self.treelist_tmplt)
        self._inv_tree_defaults = dict(
            tree_history=1, dg_incr=0.0, live_ht=0.0
            , trunc_ht=0.0, htg_incr=0.0, crown_ratio=0
            , damage1=0, severity1=0
            , damage2=0, severity2=0
            , damage3=0, severity3=0
            , tree_val=1, tree_rx=1
            , plot_slope=0, plot_aspect=0, plot_habitat=0
            , plot_topo_pos=0, plot_site_prep=0
            , tree_age=0.0
        )

        self._load_fvslib()

        # if self.fvslib is None:
            # raise ValueError('Error initializing the FVS library.')

        self._keywords = None
        # self.fvs_trees = FVSTrees(self)
        self._inventory_trees = None
        self._spp_codes = None
        self._spp_seq = None
        self._spp_fia_codes = None
        self._spp_plant_codes = None

        # Keep a list of files and folders to cleanup
        self._artifacts = []

        # print(self.workspace)

        self.version_info = dict(
            variant = self.variant
            , comp_date = self.fvslib.globals.compile_date.astype(str)
            , comp_time = self.fvslib.globals.compile_time.astype(str)
            , rev_tag = self.fvslib.globals.svn.astype(str)
            , rev_date = self.fvslib.revise(self.variant).strip().decode()
            )


    # @property
    # def trees(self):
    #     deprecation('FVS.trees is deprecated. Use FVS.fvs_trees or FVS.inventory_trees')
    #     return self.fvs_trees

    @property
    def inventory_trees(self):
        """
        A dataframe of inventory tree records.

        Columns correspond to the description in Essential FVS section 4.2:
            (plot_id,tree_id,prob,tree_history,species,dbh,dg_incr
                ,live_ht,trunc_ht,htg_incr,crown_ratio,
                ,dmg1,svr1,dmg2,svr2,dmg3,svr3
                ,value_class
        """

        return self._inventory_trees

    @inventory_trees.setter
    def inventory_trees(self, trees):
        """
        Set the inventory trees dataframe
        """

        ## TODO: Check for required fields
        ## TODO: Defer loading arrays until the simulation is started

        ## FVS array : Input field
        field_map = dict(
            plot_id='plot_id'
            , tree_id='tree_id'
            , history='history'
            , prob='prob'
            , species='species'
            , diameter='diameter'
            , diameter_growth='diameter_growth'
            , height='height'
            , total_height='total_height'
            , height_growth='height_growth'
            , crown='crown'
            , age='age'
        )

        trees = trees.loc[:,field_map.values()].copy()
        trees.rename(columns={v:k for k,v in field_map.items()}, inplace=True)

        # Now load the arrays
        inv = self.fvslib.inventory_trees
        nrows = trees.shape[0]
        inv.initialize(nrows)

        inv.plot_id = trees['plot_id']
        inv.tree_id = trees['tree_id'] #.astype(int)

        inv.tree_status = trees['history']

        inv.trees = trees['prob']
        inv.species[:nrows] = trees['species']
        inv.diameter = trees['diameter']
        inv.diameter_growth = trees['diameter_growth']
        inv.height = trees['height']

        # # Broken and dead tops have actualht<height
        # tht = np.zeros(n)
        # m = plot_trees['actualht']<plot_trees['ht']
        # tht[m] = plot_trees['actualht'][m]
        # inv.total_height = tht

        inv.height_growth = trees['height_growth']
        inv.crown_ratio = trees['crown']
        inv.tree_age = trees['age']

        ## TODO: Add damage/severity columns

        # # check for required fields
        # rqd = ['plot_id','tree_id','tree_count','species','diameter']
        # missing = [fld for fld in rqd if not fld in trees.columns]
        # if missing:
        #     raise ValueError(
        #             'Inventory trees missing required fields: '
        #             '{}'.format(str(missing)))

        # print(trees)
        self._inventory_trees = trees

    def _load_fvslib(self):
        """
        Load the requested FVS variant library.
        """

        # FIXME: Variant libraries should be compiled without the climate fvs trailing 'c'
        variant_ext = 'pyfvs.fvs%s' % self.variant.lower()[:2]
        try:
            self.fvslib = importlib.import_module(variant_ext)

        except ImportError:
            log.error('No library found for variant {}.'.format(self.variant))
            raise

        except:
            raise

        log.debug('Loaded FVS variant {} library from {}'.format(
                self.variant, self.fvslib.__file__))

        # Initialize the FVS parameters and arrays
        # FIXME: This api function is subject to change
        self.fvslib.fvs_step.init_blkdata()
        self.fvslib.tree_data.init_tree_data()
        # self.fvslib.initialize_api.init()

    # TODO: Add species code translation methods.
    @property
    def spp_codes(self):
        """
        Return the list of FVS species codes used in this variant.
        """
        if self._spp_codes is None:
            self._spp_codes = [s.decode().strip() for s in self.fvslib.globals.jsp]

        return self._spp_codes

    @property
    def spp_seq(self):
        """
        Return a dictionary mapping of species translations {fvs abbv: fvs seq,...}
        """
        if self._spp_seq is None:
            maxspp = self.globals.maxsp
            seq = {self.spp_codes[x]:x + 1 for x in range(maxspp)}
            self._spp_seq = seq

        return self._spp_seq

    @property
    def spp_fia_codes(self):
        """
        Return a dictionary mapping of species translations {fvs abbv: fia code,...}
        """
        if self._spp_fia_codes is None:
            fiajsp = [int(c.replace(b'    ', b'0')) for c in self.fvslib.globals.fiajsp]
            self._spp_fia_codes = dict(zip(self.spp_codes,fiajsp))

        return self._spp_fia_codes

    @property
    def spp_plants_codes(self):
        """
        Return a dictionary mapping of species translations {fvs abbv: plants code,...}
        """
        if self._spp_plant_codes is None:
            jsp = [s.strip().decode('utf-8') for s in self.fvslib.globals.plnjsp]
            self._spp_plants_codes = dict(zip(self.spp_codes,jsp))

        return self._spp_plants_codes

    def __getattr__(self, attr):
        """
        Return an attribute from self.fvslib if it is not defined locally.
        """
        if self.fvslib is None:
            # return None
            raise AttributeError

        try:
            v = getattr(self.fvslib, attr, None)
            if v is None:
                v = getattr(self.fvslib.globals, attr)

        except AttributeError:
            msg = 'No FVS object "{}".'.format(attr,)
            # log.exception(msg)
            raise AttributeError(msg)

        return v

    def set_random_seed(self, seed=None):
        """
        Reseed the FVS random number generator.  If seed is provided it will
        be used as the seed, otherwise a random number will be used.

        Args:
            seed: An odd number to seed the random number generator with.
        """

        if seed is None:
            self._random_seed = random.choice(range(1, 100000, 2))
        else:
            self._random_seed = seed

        # Seed the FVS random number generator
        self.ransed(True, self._random_seed)

        # Seed the numpy and python random number generators as well
        np.random.seed(self._random_seed)
        random.seed(self._random_seed)

    def _init_fvs(self, keywords):
        """
        Initialize FVS with the given keywords file.

        Args:
            keywords: Path of the keyword file initialize FVS with.
        """

        if not os.path.exists(keywords):
            msg = 'The specified keyword file does not exist: {}'.format(keywords)
            log.error(msg)
            raise ValueError(msg)

        self.keywords = keywords
        self.fvslib.fvssetcmdline('--keywordfile={}'.format(keywords))

    @property
    def workspace(self):
        """
        Return the current workspace folder.
        """
        pfx = self.config['prefix'].get()
        if (self._workspace is None
                or not os.path.exists(self._workspace)):
            self._workspace = tempfile.mkdtemp(prefix=pfx)
            self._artifacts.append(self._workspace)

        return self._workspace

    @workspace.setter
    def workspace(self, workspace):
        """
        Set the current workspace folder.

        Args:
            workspace: Path to set as the current FVS workspace.
        """
        if not workspace is None and not os.path.exists(workspace):
            raise ValueError('Workspace folder must already exist.')

        self._workspace = workspace

    # TODO: Further define how KeywordSet objects are used by and FVS instance
    #       They should be the preferred source, instead of a path to an
    #       existing file.
    @property
    def keywords(self):
        """
        Return the current keywords instance, creating one if necessary.
        """
        if self._keywords is None:
            self.init_keywords()

        return self._keywords

    @keywords.setter
    def keywords(self, keywords):
        """
        Set the current keywords instance.

        Args:
            keywords: Instance of KeywordSet class.
        """

        if not isinstance(keywords, kw.KeywordSet):
            raise TypeError('kwd object must be an instance of KeywordSet')

        self._keywords = keywords

    def init_keywords(self, title='', comment=''):
        """
        Return an initialized KeywordSet instance.

        Args:
            title: Keywords title
            comment: Keywords comment

        Returns:
            keywords: An initialized KeywordSet object
        """
        if not title:
            now = datetime.datetime.strftime(
                    datetime.datetime.now(), '%Y%m%d_%H%M%S')
            title = '{}_{}'.format(self.variant,now)

        self._keywords = kw.KeywordSet(
                title=title, comment=comment, top_level=True
                )
        return self._keywords

    def init_projection(self, keywords=None, trees=None):
        """
        Initialize a projection with the provided keywords.

        Args:
            keywords: Path to the FVS keywords file, or a KeywordSet instance.
                    If None then use self.keywords.
            trees: Inventory treelist instance.
        """

        if keywords is None:
            keywords = self.keywords

        if keywords is None:
            print('Run has no Keywords')

        if isinstance(keywords, kw.KeywordSet):

            # FIXME: keyword implicitly know their relative position
            keywords.top_level = True
            keywords.parent = None

            # TODO: Add option to raise exceptions for missing keywords
            if not keywords.find('STDINFO') and not keywords.find('STANDSQL'):
                print('No STDINFO keyword')

            if not keywords.find('DESIGN') and not keywords.find('STANDSQL'):
                print('No DESIGN keyword')

            if not keywords.find('TREEFMT') and not keywords.find('TREESQL'):
                keywords += kw.TREEFMT(self.treelist_fmt)

            fn = keywords.title.lower()
            fn = fn.replace(' ', '_')
            self.root = os.path.join(self.workspace, fn)
            if not os.path.exists(self.root):
                os.makedirs(self.root)

            keywords_fn = os.path.join(
                    self.root
                    , '{}.key'.format(fn)
                    )
            log.debug(f'Keywords File: {keywords_fn}')
            keywords.write(keywords_fn)

            self._artifacts.append(keywords_fn)

            # Write out the inventory trees
            has_inv = self.fvslib.inventory_trees.row_count()>0
            if not has_inv and not keywords.find('TREESQL'):
                # print('***NO TREESQL')
                pth, fn = os.path.split(keywords_fn)
                fn, ext = os.path.splitext(fn)
                trees_fn = os.path.join(
                        self.root
                        , '{}.tre'.format(fn)
                        )
                if not trees is None:
                    self.write_treelist(trees, trees_fn)
                    self._artifacts.append(trees_fn)

                elif not self.inventory_trees is None:
                    self.write_treelist(self.inventory_trees, trees_fn)
                    self._artifacts.append(trees_fn)

                else:
                    if not os.path.exists(trees_fn) and not keywords.find('NOTREES'):
                        log.info('No inventory tree records, assume a bareground projection.')
                        keywords += kw.NOTREES()

        else:
            # Handle keywords as a file path
            self.root = os.path.dirname(keywords)
            keywords_fn = keywords

        if not os.path.isfile(keywords_fn):
            msg = 'The keyword file does not exist: {}'.format(keywords_fn)
            log.error(msg)
            raise ValueError(msg)

        # fvs_init requires a path
        r = self.fvs_step.fvs_init(keywords_fn)

        # TODO: Handle and format error codes
        if not r == 0:
            log.error(f'FVS returned non-zero: {r}\n{keywords_fn}')

        if self.stochastic:
            self.set_random_seed()

        self.keywords_file = keywords_fn

    def iter_projection(self):
        """
        Return a generator to iterate through the projection cycles.
        """
        deprecation('FVS.iter_projection is deprecated. Use FVS iterator protocol.', level=2)
        return self.__iter__()

    def __iter__(self):
        """
        Iterate through the growth cycles of a projection.
        """
        if self.fvs_step.sim_status <= 0:
            self.init_projection()

        # Don't assume we're at the beginning
        cycles = self.num_cycles - self.current_cycle
        for n in range(cycles):
            r = self.fvs_step.fvs_grow()
            # TODO: Check return code and raise execption for critical errors
            yield n

        self.end_projection()

    def grow_projection(self, cycles=1):
        deprecation('FVS.grow_projection is deprecated, use FVS.grow.', level=2)
        r = self.grow(cycles)

    def run(self):
        """
        Convenience method to execute and end a complete projection.
        """

        self.grow(cycles=0)
        self.end_projection()

    def grow(self, cycles=1):
        """
        Execute the FVS projection for an arbitrary number of cycles.

        Args:
            cycles: Number of cycles to execute. Set to zero to run all
                remaining cycles.
        """

        if self.fvs_step.sim_status <= 0:
            self.init_projection()

        if not cycles:
            cycles = self.num_cycles - self.current_cycle

        r = -1
        for n in range(cycles):
            r = self.fvs_step.fvs_grow()
            # TODO: Handle non-zero exit codes

        return r

    def __del__(self):
        """
        Cleanup when the instance is destroyed.
        """
        log.debug(f'Cleanup FVS() object: "{self._workspace}"')
        try:
            if self.fvs_step.sim_status > 0:
                self.end_projection()
        except:
            # FIXME: should this pass silently?
            pass

    def end_projection(self):
        """
        Terminate the current projection.
        """

        r = 0
        if self.fvs_step.sim_status > 0:
            # Finalize the projection
            r = self.fvs_step.fvs_end()

        if self.cleanup:
            for a in self._artifacts:
#                 try: os.remove(a)
#                 except: pass
                try:
                    if os.path.exists(a) and os.path.isdir(a):
                        shutil.rmtree(a)
                        if a == self._workspace:
                            self._workspace = None
                    else:
                        os.remove(a)

                except:
                    log.debug(f'Unable to remove: {a}')
                    # raise
                    pass

            self._artifacts = []

        if r == 1:
            err = error_codes.get(r, 'Unspecified Error')
            msg = 'FVS returned error code {}: {}.'.format(r, err)
            log.error(msg)
            raise IOError(msg)

        if r != 0 and r <= 10:
            err = error_codes.get(r, 'Unspecified Error')
            msg = 'FVS returned error code {}: {}.'.format(r, err)
            log.warning(msg)

        if r > 10:
            log.error('FVS encountered an error, {}'.format(r))

        return r

    def execute_projection(self, kwds=None, trees=None):
        """
        Convenience method to execute all cycles.

        Args:
            keywords: Path of the keyword file initialize FVS with.
            trees: Trees dataset
        """

        self.init_projection(keywords=kwds, trees=trees)
        self.grow(cycles=0)
        r = self.end_projection()
        return r

    def write_treelist(self, trees, treelist_path):
        """
        Write out an FVS treelist file

        Args:
            trees: Pandas dataframe of tree records.
                    May also be an iterator of plot level tree dataframes.
            path: Treelist file path.
        """

        tmplt = self.treelist_tmplt

        for fld in self._tree_fields:
            if not fld in trees.columns:
                trees[fld] = self._inv_tree_defaults[fld]

        if hasattr(trees, 'fvs_treelist'):
            with open(treelist_path, 'w') as out:
                out.write(trees.fvs_treelist())

        elif isinstance(trees, pd.DataFrame):
            names = self._tree_fields

            with open(treelist_path, 'w') as out:
                for r, rec in trees.loc[:,names].iterrows():
                    print(tmplt)
                    print(trees.loc[:,names].info())
                    # row = tmplt.format(**dict(zip(names, rec))) + '\n'
                    row = tmplt.format(**rec.to_dict()) + '\n'
                    print(row)
                    out.write(row)

            # print(trees.loc[:,names])
            raise

        elif isinstance(trees, (list, tuple)):
            with open(treelist_path, 'w') as out:
                for plot in trees:
                    if isinstance(plot, np.ndarray):
                        names = plot.dtype.names
                        for rec in plot:
                            out.write(tmplt.format(
                                    **dict(zip(names, rec))) + '\n')
                    elif isinstance(plot, pd.DataFrame):
                        names = plot.columns.values
                        for r, rec in plot.iterrows():
                            out.write(tmplt.format(
                                    **dict(zip(names, rec))) + '\n')

                    elif isinstance(plot, str):
                        # Assume the plot data is a Pandas dataframe in JSON clothing
                        plot_df = pandas.io.json.read_json(plot)
                        names = plot_df.columns.values
                        for r, rec in plot_df.iterrows():
                            out.write(tmplt.format(
                                    **dict(zip(names, rec))) + '\n')
                    else:
                        # TODO: Handle zero tree plots
                        continue
        else:
            raise ValueError('One or more trees are required, got nothing.')

    @property
    def current_cycle(self):
        return int(self.globals.icyc)

    @property
    def year(self):
        return int(self.globals.iy[self.current_cycle])

    @property
    def num_cycles(self):
        return int(self.globals.ncyc)

    # @property
    # def treelist(self):
    #     """
    #     Return a dataframe of FVS trees.
    #     """
    #     cols =

    @property
    def trees(self):
        dt = np.dtype([
                ('cycle',np.uint8), ('year', np.uint16)
                , ('plot_seq',np.uint16), ('tree_seq',np.uint16), ('tree_id',np.uint16), ('spp_seq',np.uint16), ('age',np.uint16), ('live_tpa',np.float32), ('live_dbh',np.float32), ('dbh_incr',np.float32)
                , ('ht_total',np.float32), ('ht_incr',np.float32), ('cr_width',np.float32), ('cr_ratio',np.float32), ('ht_merch_cuft',np.float32), ('ht_merch_bdft',np.float32)
                , ('cuft_total',np.float32), ('cuft_net',np.float32), ('bdft_net',np.float32), ('defect_cuft',np.float32), ('defect_bdft',np.float32)
                ])

        N = self.tree_data.num_recs.sum()
        trees = np.zeros((N,), dtype=dt)
        cols = dt.names[2:]
        m = 0
        for i in range(self.num_cycles+1):
            n = self.tree_data.num_recs[i]
            for c in cols:
                trees[c][m:m+n] = getattr(self.tree_data, c)[:n,i]

            trees['cycle'][m:m+n] = i
            trees['year'][m:m+n] = self.globals.iy[i]

            m += n

        return pd.DataFrame(trees)
        # return trees

    @property
    def summary(self):
        """
        Return the FVS summary table as a Pandas DataFrame
        """

        cols = ['year','age','tpa','tcuft','mcuft','mbdft'
                ,'rem_tpa','rem_tcuft','rem_mcuft','rem_mbdft'
                ,'baa','ccf','top_ht','per_len','accr','mort'
                ,'sam_wgt','for_type','size','stock']

        df = pd.DataFrame.from_records(
            self.fvslib.globals.iosum[:, :self.num_cycles + 1].T
            , columns=cols)

        return df

    def get_summary(self, variable):
        """
        Return an FVS summary value through the current projection cycle.

        Args:
            variable: The summary variable to return. One of the following:
                year, age, tpa, total cuft, merch cuft, merch bdft,
                removed tpa, removed total cuft, removed merch cuft,
                removed merch bdft, baa after, ccf after, top ht after,
                period length, accretion, mortality, sample weight,
                forest type, size class, stocking class
        """

        # Map summary variable to the array index
        variables = {'year': 0
            , 'age': 1
            , 'tpa': 2
            , 'total cuft': 3
            , 'merch cuft': 4
            , 'merch bdft': 5
            , 'removed tpa': 6
            , 'removed total cuft': 7
            , 'removed merch cuft': 8
            , 'removed merch bdft': 9
            , 'baa after':10
            , 'ccf after':11
            , 'top ht after':12
            , 'period length':13
            , 'accretion':14
            , 'mortality':15
            , 'sample weight':16
            , 'forest type':17
            , 'size class':18
            , 'stocking class':19
            }

        try:
            i = variables[variable.lower()]

        except KeyError:
            msg = '{} is not an available summary variable({}).'.format(
                    variable, variables.keys())
            raise KeyError(msg)

        except:
            raise

        # Return the summary values for the cycles in the run
        return(self.fvslib.commmon.iosum[i, :self.num_cycles + 1])

error_codes = {
    1: 'Invalid keyword specified.',
    2: 'No STOP keyword record.',
    3: 'Forest code is outside the model range.',
    4: 'Bad keyword parameter.'
    }

class FVSTrees(object):
    """
    Provide runtime access to tree attribute arrays.
    """
    def __init__(self, parent):
        self.parent = parent

    # def as_dataframe(self):
    #     df = pandas.DataFrame(dict(
    #         plot_id=self.plot_id
    #         , tree_id=self.tree_id
    #         , species=self.species
    #         , tpa=self.tpa
    #         , dbh=self.dbh
    #         , height=self.height
    #         , age=self.age
    #         , cfv=self.cfv
    #         , bfv=self.bfv
    #     ))
    #     return df

    @property
    def num_recs(self):
        return self.parent.globals.itrn

    @property
    def plot_id(self):
        return self.parent.globals.itre[:self.num_recs + 1]

    @property
    def tree_id(self):
        return self.parent.globals.idtree[:self.num_recs + 1]

    @property
    def species(self):
        return self.parent.globals.isp[:self.num_recs + 1]

    @property
    def tpa(self):
        return self.parent.globals.prob[:self.num_recs + 1]

    @property
    def dbh(self):
        """Diameter at breast height"""
        return self.parent.globals.dbh[:self.num_recs + 1]

    @property
    def height(self):
        return self.parent.globals.ht[:self.num_recs + 1]

    @property
    def age(self):
        """Tree age"""
        return self.parent.globals.age[:self.num_recs + 1]

    @property
    def cfv(self):
        """Total cubic foot volume per tree"""
        return self.parent.globals.cfv[:self.num_recs + 1]

    @property
    def bfv(self):
        """Total scribner board foot volume per tree"""
        return self.parent.globals.bfv[:self.num_recs + 1]
