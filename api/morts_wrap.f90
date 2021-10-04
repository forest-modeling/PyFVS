subroutine morts
! Replaces the base morts routine to switch between the original FVS
! mortality routines and the ported ORGANON routines.

    use globals, only: use_fvs_morts
    implicit none

    if (use_fvs_morts) then
        call morts_fvs
    else
        ! Call the default morts subroutine
        call morts_default
    end if
    
end subroutine morts

subroutine morcon
    use globals, only: use_fvs_morts
    implicit none

    if (use_fvs_morts) then
        call morcon_fvs
    else
        ! Call the default morcon entry
        call morcon_default
    end if
end subroutine morcon