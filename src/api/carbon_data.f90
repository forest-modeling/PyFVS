module carbon_data
    ! Capture carbon estimates at each cycle boundary

    !      1 = ABOVEGROUND TOTAL LIVE
    !      2 = ABOVEGOURND TOTAL MERCH
    !      3 = BELOWGROUND LIVE
    !      4 = BELOWGROUND DEAD (WHICH DECAYS)
    !      5 = STANDING DEAD
    !      6 = FOREST DOWN DEAD WOOD
    !      7 = FOREST FLOOR (LITTER AND DUFF)
    !      8 = FOREST SHRUB+HERB
    !      9 = TOTAL STAND CARBON
    !     10 = TOTAL CARBON REMOVED THIS REPORTING PERIOD
    !     11 = TOTAL CARBON RELEASED FROM FIRE

    use globals, only: maxcy1
    implicit none

    real, dimension(17,maxcy1) :: carbon_summary

    contains

    subroutine copy_forest_carbon()
        ! Copy stand carbon estimates for the current cycle
        ! Called from fmcrbout before the DB output
        use globals, only: icyc, carbval

        integer :: x

        do x= 1,11
            carbon_summary(x,icyc) = carbval(x)
        end do

    end subroutine copy_forest_carbon

    subroutine copy_harvest_carbon()
        ! Copy harvested carbon estimates for the current cycle
        ! Called from fmchrvout before the DB output
        use globals, only: icyc, carbval

        integer :: x

        do x= 12,18
            carbon_summary(x,icyc) = carbval(x)
        end do

    end subroutine copy_harvest_carbon

end module carbon_data
