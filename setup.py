"""
    Setup file for PyFVS.
    Use setup.cfg to configure your project.

    This file was generated with PyScaffold 4.2.
    PyScaffold helps you to put up the scaffold of your new Python project.
    Learn more under: https://pyscaffold.org/
"""
from skbuild import setup

if __name__ == "__main__":
    try:
        setup(
            use_scm_version={"version_scheme": "no-guess-dev"}
            # , cmake_install_dir='./src/pyfvs'
            
            ## TODO: This could be specified in setup.cfg, but I couldn't get the 
            ##    compiled pyd extensions to install correctly
            , packages=['pyfvs', 'pyfvs.keywords']
            # , package_dir = {'': 'src'}
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
    
            )
    except:  # noqa
        print(
            "\n\nAn error occurred while building the project, "
            "please ensure you have the most updated version of setuptools, "
            "setuptools_scm and wheel with:\n"
            "   pip install -U setuptools setuptools_scm wheel\n\n"
        )
        raise
