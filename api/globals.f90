! Load all common blocks and shared variables into a common namespace
! Thise provides API level access to shared data
!
module globals
    implicit none

    ! Values to be set by the compiler
    character(len=11), parameter :: compile_date = __DATE__
    character(len=8), parameter :: compile_time = __TIME__

    character(len=4) :: svn

    INCLUDE 'INCLUDESVN.F90'

    INCLUDE 'PRGPRM.F90'
    ! INCLUDE 'CONTRL.F90'
    INCLUDE 'COEFFS.F90'
    INCLUDE 'ESPARM.F90'
    INCLUDE 'ESCOMN.F90'
    INCLUDE 'ESTREE.F90'
    INCLUDE 'PDEN.F90'
    INCLUDE 'ECON.F90'
    INCLUDE 'HTCAL.F90'
    INCLUDE 'CONTRL.F90'
    INCLUDE 'PLOT.F90'
    INCLUDE 'RANCOM.F90'
    INCLUDE 'SCREEN.F90'
    INCLUDE 'VARCOM.F90'
    INCLUDE 'FVSSTDCM.F90'
    INCLUDE 'STDSTK.F90'

    INCLUDE 'ARRAYS.F90'
    INCLUDE 'OUTCOM.F90'
    INCLUDE 'WORKCM.F90'

    INCLUDE 'FMPARM.F90'
    INCLUDE 'FMCOM.F90'
    INCLUDE 'FMFCOM.F90'

    ! FVS functionality controls
    logical :: calc_forest_type=.true.
    logical :: fast_age_search=.false.
    logical :: use_fvs_morts=.false.

    ! Add merch rules (conifer,hardwood)
    logical :: use_api_mrules=.false.
    character(len=1), dimension(2) :: mrule_cor = (/'N','N'/)
    integer, dimension(2)          :: mrule_evod = (2, 2)
    real, dimension(2)             :: mrule_maxlen = (40.0, 32.0)
    real, dimension(2)             :: mrule_minlen = (12.0, 8.0)
    real, dimension(2)             :: mrule_minlent = (12.0, 8.0)
    integer, dimension(2)          :: mrule_opt = (23, 23)
    real, dimension(2)             :: mrule_stump = (1.0, 1.0)
    real, dimension(2)             :: mrule_mtopp = (5.0, 6.0)
    real, dimension(2)             :: mrule_mtops = (2.0, 2.0)
    real, dimension(2)             :: mrule_trim = (1.0, 1.0)
    real, dimension(2)             :: mrule_merchl = (12.0, 8.0) ! min sawtimber length
    real, dimension(2)             :: mrule_minbfd = (8.0, 10.0) ! min tree dbh for sawtimber

    save

    contains

end module globals