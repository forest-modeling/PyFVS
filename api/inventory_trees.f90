module inventory_trees

  ! use iso_c_binding, only : c_char
  implicit none

  integer :: row_idx, num_rows
  integer, allocatable, dimension(:) :: plot_id, tree_id, history
  ! character(len=8, kind=c_char), allocatable, dimension(:) :: species
  ! character(len=1, kind=c_char), allocatable, dimension(:,:) :: species
  character*8 :: species(1000) ! This works with F2PY and Numpy arrays
  ! character(len=8), allocatable, dimension(:) :: species
  !f2py character(f2py_len=8) species
  ! character(len=8) :: species(1000)
  real, allocatable, dimension(:) :: trees, diameter, diameter_growth
  real, allocatable, dimension(:) :: height, total_height, height_growth
  real, allocatable, dimension(:) :: crown_ratio, tree_age

  integer, allocatable, dimension(:,:) :: damage_codes
  ! (IDAMCD(J),J=1,6)
  ! IMC1 = IMC1(row_idx)
  ! KUTKOD(I) = plot_id(row_idx)
  ! IPVARS(1) = plot_id(row_idx)
  ! IPVARS(2) = plot_id(row_idx)
  ! IPVARS(3) = plot_id(row_idx)
  ! IPVARS(4) = plot_id(row_idx)
  ! IPVARS(5) = plot_id(row_idx)

  contains

  function row_count() result(n)
    integer :: n

    if (allocated(tree_id)) then
      n = size(tree_id, 1)
    else
      n = 0
    endif

    return

  end function

  subroutine initialize(ntrees)
    integer :: ntrees
    if (allocated(plot_id)) deallocate(plot_id)
    if (allocated(tree_id)) deallocate(tree_id)
    if (allocated(history)) deallocate(history)
    ! if (allocated(species)) deallocate(species)
    if (allocated(trees)) deallocate(trees)
    if (allocated(diameter)) deallocate(diameter)
    if (allocated(diameter_growth)) deallocate(diameter_growth)
    if (allocated(height)) deallocate(height)
    if (allocated(total_height)) deallocate(total_height)
    if (allocated(height_growth)) deallocate(height_growth)
    if (allocated(crown_ratio)) deallocate(crown_ratio)
    if (allocated(tree_age)) deallocate(tree_age)
    if (allocated(damage_codes)) deallocate(damage_codes)

    allocate(plot_id(ntrees))
    allocate(tree_id(ntrees))
    allocate(history(ntrees))
    ! allocate(character*8 :: species(ntrees))
    allocate(trees(ntrees))
    allocate(diameter(ntrees))
    allocate(diameter_growth(ntrees))
    allocate(height(ntrees))
    allocate(total_height(ntrees))
    allocate(height_growth(ntrees))
    allocate(crown_ratio(ntrees))
    allocate(tree_age(ntrees))
    allocate(damage_codes(6,ntrees))

    plot_id(:) = 0
    tree_id(:) = 0
    history(:) = 0
    species(:) = ''
    trees(:) = 0.0
    diameter(:) = 0.0
    diameter_growth(:) = 0.0
    height(:) = 0.0
    total_height(:) = 0.0
    height_growth(:) = 0.0
    crown_ratio(:) = 0.0
    tree_age(:) = 0.0
    damage_codes(:,:) = 0

  end subroutine

  subroutine print_trees()
    integer :: i

    write (*,*) 'Inventory Tree Arrays'
    do i=1,size(tree_id, 1)
      write (*,*) plot_id(i), tree_id(i), history(i), species(i), trees(i), diameter(i)
    end do

  end subroutine

end module