! Module to store dynamic version info

module version
    implicit none

    ! Values to be set by the compiler
    ! NOTE: These are for GNU compilers
    !       Add the '-cpp' compiler argument for gfortran
    character(len=11), parameter :: compile_date = __DATE__
    character(len=8), parameter :: compile_time = __TIME__

end module version