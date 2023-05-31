module fvs_api
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

end module fvs_api