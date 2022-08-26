module downwood_data
    ! Capture down wood estimates
    use globals, only: maxcy1, cwdvol
    implicit none

    real, dimension(16,maxcy1) :: downwood_summary

    contains

    subroutine copy_downwood()
        ! Copy down wood estimates for the current cycle
        use globals, only: icyc

        integer :: x

        ! Adapted from fmdout.f, line 455
        !   where CWDVOL is copied into V1
        downwood_summary(1,icyc) = CWDVOL(3,1,2,5)+CWDVOL(3,2,2,5)+CWDVOL(3,3,2,5)
        downwood_summary(2,icyc) = CWDVOL(3,4,2,5)
        downwood_summary(3,icyc) = CWDVOL(3,5,2,5)
        downwood_summary(4,icyc) = CWDVOL(3,6,2,5)
        downwood_summary(5,icyc) = CWDVOL(3,7,2,5)
        downwood_summary(6,icyc) = CWDVOL(3,8,2,5)
        downwood_summary(7,icyc) = CWDVOL(3,9,2,5)
        downwood_summary(8,icyc) = CWDVOL(3,10,2,5)
        downwood_summary(9,icyc) = CWDVOL(3,1,1,5)+CWDVOL(3,2,1,5)+CWDVOL(3,3,1,5)
        downwood_summary(10,icyc) = CWDVOL(3,4,1,5)
        downwood_summary(11,icyc) = CWDVOL(3,5,1,5)
        downwood_summary(12,icyc) = CWDVOL(3,6,1,5)
        downwood_summary(13,icyc) = CWDVOL(3,7,1,5)
        downwood_summary(14,icyc) = CWDVOL(3,8,1,5)
        downwood_summary(15,icyc) = CWDVOL(3,9,1,5)
        downwood_summary(16,icyc) = CWDVOL(3,10,1,5)

    end subroutine copy_downwood

end module downwood_data
