module globals
    implicit none
    INCLUDE 'PRGPRM.F90'
    INCLUDE 'COEFFS.F90'
    INCLUDE 'ESPARM.F90'
    INCLUDE 'ESCOMN.F90'
    INCLUDE 'PDEN.F90'
    INCLUDE 'ECON.F90'
    INCLUDE 'HTCAL.F90'
    INCLUDE 'CONTRL.F90'
    INCLUDE 'PLOT.F90'
    INCLUDE 'RANCOM.F90'
    INCLUDE 'SCREEN.F90'
    INCLUDE 'VARCOM.F90'
    INCLUDE 'FVSSTDCM.F90'
    
    INCLUDE 'ARRAYS.F90'
    INCLUDE 'OUTCOM.F90'
    INCLUDE 'WORKCM.F90'
    
    INCLUDE 'FMPARM.F90'
    INCLUDE 'FMCOM.F90'

    ! FVS functionality controls
    logical :: calc_forest_type=.true.
    logical :: fast_age_search=.false.
    logical :: use_fvs_morts=.false.

    save

    contains

end module globals