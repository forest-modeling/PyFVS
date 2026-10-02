module fvs_api
  use iso_c_binding
  implicit none

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

  subroutine reset()
    calc_forest_type=.true.
    fast_age_search=.false.
    use_fvs_morts=.false.

    use_api_mrules=.false.
    mrule_cor = (/'N','N'/)
    mrule_evod = (2, 2)
    mrule_maxlen = (40.0, 32.0)
    mrule_minlen = (12.0, 8.0)
    mrule_minlent = (12.0, 8.0)
    mrule_opt = (23, 23)
    mrule_stump = (1.0, 1.0)
    mrule_mtopp = (5.0, 6.0)
    mrule_mtops = (2.0, 2.0)
    mrule_trim = (1.0, 1.0)
    mrule_merchl = (12.0, 8.0) ! min sawtimber length
    mrule_minbfd = (8.0, 10.0) ! min tree dbh for sawtimber

  end subroutine reset

  function get_mrule_idx(spp) result(idx)
    integer :: spp, idx

    ! TODO: Expand to lookup multiple species or groups of species
    idx = 1 ! conifer
    if (spp>=300) then
      idx = 2 ! hardwood
    end if

  end function get_mrule_idx

  ! Wrappers for subroutines in apisubs.f
  subroutine dim_sizes(ntrees,ncycles,nplots,maxtrees,maxspecies,maxplots,maxcycles)
    integer, intent(out) :: ntrees,ncycles,nplots,maxtrees,maxspecies,maxplots,maxcycles
    call fvsdimsizes(ntrees,ncycles,nplots,maxtrees,maxspecies,maxplots,maxcycles)
  end subroutine dim_sizes

  ! Wrappers for FVS library routines

  function calc_height(ifor, ispc, diameter) result(height)
    integer, intent(in) :: ifor, ispc
    real, intent(in) :: diameter
    real :: height, dbh
    integer :: mode
    external :: htdbh

    dbh = diameter
    height = 0.0
    mode = 0
    call htdbh(ifor, ispc, dbh, height, mode)
  end function calc_height

  function calc_dbh(ifor, ispc, height) result(diameter)
    integer, intent(in) :: ifor, ispc
    real, intent(in) :: height
    real :: diameter, tree_height
    integer :: mode
    external :: htdbh

    diameter = 0.0
    tree_height = height
    mode = 1
    call htdbh(ifor, ispc, diameter, tree_height, mode)
  end function calc_dbh

end module fvs_api