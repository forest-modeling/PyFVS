
import os
import sys
import logging

import click

import pyfvs
from .fvs import FVS

pyfvs.init_logging()
log = logging.getLogger('pyfvs.__main__')

@click.group(invoke_without_command=True)
@click.pass_context
@click.option('--version', is_flag=True, help='Print the version of PyFVS and exit')
def cli(ctx, version=False):
    """
    PyFVS Command Line Interface

    PyFVS is on GitHub (https://github.com/forest-modeling/PyFVS)
    """
    if version:
        print(pyfvs.__version__)
        sys.exit(0)

@cli.command(name='run')
@click.pass_context
@click.argument('variant', metavar='<variant>')
@click.option('-k', '--keywords', type=click.Path(exists=True), help='Path to the FVS keyword file to execute.')
@click.option('-b', '--bootstrap', is_flag=True, help='(not impl) Bootstrap resampling of sample plot data.')
@click.option('-d', '--debug', is_flag=True, help='Set logging level to debug.')
@click.option('-s', '--stochastic', is_flag=True, help='Run FVS with stochastic components.')
@click.option('-p', '--prompt', is_flag=True, help='Prompt the user for I/O files.')
@click.option('--fvs-mort', is_flag=True, help='Use the former FVS mortality functions for PN & WC variants.')
@click.option('--forest-type', is_flag=True, help='Calculate FVS forest type.')
def run(ctx, 
    variant, keywords=None, bootstrap=False, debug=False, stochastic=False, prompt=False
    , fvs_mort=False, forest_type=False
    ):
    """
    Run the FVS <varian> using the PyFVS command line

    \b
    Basic Usage:
        pyfvs run <variant> <keyword file>
        python -m pyfvs run <variant> <keyword file>
    """

    # Don't run the main routine if a sub-command was called
    if not ctx.invoked_subcommand is None:
        return None

    if bootstrap > 0:
        log.info('Bootstrap resampling of plot data is not implemented.')

    if debug:
        log.setLevel(logging.DEBUG)

    if keywords is None or prompt:
        # Run FVS in prompt mode
        r = FVS(variant).fvs()
        sys.exit(r)

    if keywords is None and not prompt:
        raise click.UsageError('A keyword file must be provided unless prompt is True')

    if not os.path.exists(keywords):
        msg = 'The keyword file is does not exist: {}'.format(keywords)
        log.error(msg)
        sys.exit(1)

    # Execute the run
    try:
        fvs = FVS(variant, stochastic=stochastic)

    except ImportError:
        log.error((
            'Variant code \'{}\' is not '
            'a supported variant.\n'
            'Supported variants: {}'
            ).format(variant, '; '.join(pyfvs.list_variants()))
            )
        sys.exit(1)

    except:
        sys.exit(1)
    
    # 
    fvs.globals.use_fvs_morts = fvs_mort
    fvs.globals.fast_age_search = False
    fvs.globals.calc_forest_type = forest_type
     
    try:
        fvs.execute_projection(keywords)
    except:
        log.exception('Error running FVS.')
        sys.exit(1)

    cols = ['year','age','tpa','baa','top_ht','tcuft','mcuft','mbdft','rem_mbdft','mort']
    print(fvs.summary.loc[:,cols])
    # print(fvs.summary.columns)
    # print(fvs.outcom_mod.iosum[:6, :fvs.num_cycles + 1].T)
#     print(fvs.get_summary('merch bdft'))

@cli.command(name='list-variants')
# @cli.command(name='help-variants')
def list_variants():
    'List the supported FVS variants'
    vars = pyfvs.list_variants()
    msg = 'Supported FVS variants:\n'
    for v,s in vars.items():
        msg += '  {} - ({}) - {}\n'.format(v,s['lib'],s['status'])
        
    print(msg)
    sys.exit(0)

@cli.command(name='run-tests')
@click.pass_context
def run_tests(ctx):
    'Run tests against the supported variants'
    print('run-tests not implemented')

if __name__ == '__main__':
    cli()
