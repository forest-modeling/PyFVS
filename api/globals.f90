! Load all common blocks and shared variables into a common namespace
! Thise provides API level access to shared data
!
! GFortran does not allow mixing free and fixed form comments in the
! same source file. F77 include files are translated to F90 freeform.
!
module globals
    implicit none

    character(len=10) :: svn

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

    INCLUDE 'OPCOM.F90'

    INCLUDE 'ARRAYS.F90'
    INCLUDE 'OUTCOM.F90'
    INCLUDE 'WORKCM.F90'

    INCLUDE 'FMPARM.F90'
    INCLUDE 'FMCOM.F90'
    INCLUDE 'FMFCOM.F90'

    INCLUDE 'SVDATA.F90'

    save

    contains

end module globals