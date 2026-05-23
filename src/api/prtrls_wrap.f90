subroutine prtrls_wrap(iwho)
    ! Intercept calls to the treelist printer
    use tree_data, only: save_tree_data,copy_tree_data,copy_mort_data,copy_cuts_data
    use downwood_data, only: copy_downwood
    use carbon_data, only: copy_forest_carbon,copy_harvest_carbon
    use globals, only: wk4

    implicit none
    integer iwho

    ! Copy tree arrays
    select case (iwho)

        case (1)

            call copy_tree_data()
            call copy_mort_data()
            call copy_forest_carbon()
            call copy_harvest_carbon()
            call copy_downwood()

        case (2)
            ! Called after cuts to copy the capture the trees removed during thinning
            call copy_cuts_data()

        case (3)
            ! Also called from cuts after thinning to print the after-thin treelist

    end select

    call prtrls(iwho)

end subroutine prtrls_wrap