!!!-------------------------------------------------------------------------
!!! project : pansy
!!! program : ctqmc_core module
!!!           ctqmc_clur module
!!!           ctqmc_flvr module
!!!           ctqmc_mesh module
!!!           ctqmc_meat module
!!!           ctqmc_umat module
!!!           ctqmc_fmat module
!!!           ctqmc_mmat module
!!!           ctqmc_gmat module
!!!           ctqmc_wmat module
!!!           ctqmc_smat module
!!!           context    module
!!! source  : ctqmc_context.f90
!!! type    : module
!!! author  : li huang (email:huangli712@yahoo.com.cn)
!!!           yilin wang (email:qhwyl2006@126.com)
!!! history : 09/16/2009 by li huang
!!!           09/17/2009 by li huang
!!!           09/19/2009 by li huang
!!!           09/20/2009 by li huang
!!!           09/21/2009 by li huang
!!!           09/22/2009 by li huang
!!!           09/27/2009 by li huang
!!!           11/01/2009 by li huang
!!!           11/10/2009 by li huang
!!!           11/18/2009 by li huang
!!!           12/01/2009 by li huang
!!!           12/05/2009 by li huang
!!!           02/21/2010 by li huang
!!!           02/23/2010 by li huang
!!!           06/08/2010 by li huang
!!!           08/18/2014 by yilin wang
!!! purpose : define the key data structure and global arrays/variables for
!!!           hybridization expansion version continuous time quantum Monte
!!!           Carlo (CTQMC) quantum impurity solver and dynamical mean field
!!!           theory (DMFT) self-consistent engine
!!! status  : unstable
!!! comment :
!!!-------------------------------------------------------------------------

!!=========================================================================
!!>>> module ctqmc_core                                                 <<<
!!=========================================================================

!!>>> containing core (internal) variables used by continuous time quantum
!!>>> Monte Carlo quantum impurity solver
  module ctqmc_core
     use constants, only : dp, zero

     implicit none

! current perturbation expansion order
     integer, public, save  :: ckink = 0

! sign change related with current diagram update operation
     integer, public, save  :: csign = 1

! counter for negative sign, used to measure the sign problem
     integer, public, save  :: cnegs = 0

! averaged sign values, used to measure the sign problem
     integer, public, save  :: caves = 0

!-------------------------------------------------------------------------
!::: core variables: real, matrix trace                                :::
!-------------------------------------------------------------------------

! matrix trace of flavor part, current value
     real(dp), public, save :: matrix_ptrace = zero

! matrix trace of flavor part, proposed value
     real(dp), public, save :: matrix_ntrace = zero

!-------------------------------------------------------------------------
!::: core variables: real, insert action counter                       :::
!-------------------------------------------------------------------------

! insert kink (operators pair) statistics: total insert count
     real(dp), public, save :: insert_tcount = zero

! insert kink (operators pair) statistics: total accepted insert count
     real(dp), public, save :: insert_accept = zero

! insert kink (operators pair) statistics: total rejected insert count
     real(dp), public, save :: insert_reject = zero

!-------------------------------------------------------------------------
!::: core variables: real, remove action counter                       :::
!-------------------------------------------------------------------------

! remove kink (operators pair) statistics: total remove count
     real(dp), public, save :: remove_tcount = zero

! remove kink (operators pair) statistics: total accepted remove count
     real(dp), public, save :: remove_accept = zero

! remove kink (operators pair) statistics: total rejected remove count
     real(dp), public, save :: remove_reject = zero

!-------------------------------------------------------------------------
!::: core variables: real, lshift action counter                       :::
!-------------------------------------------------------------------------

! lshift kink (operators pair) statistics: total lshift count
     real(dp), public, save :: lshift_tcount = zero

! lshift kink (operators pair) statistics: total accepted lshift count
     real(dp), public, save :: lshift_accept = zero

! lshift kink (operators pair) statistics: total rejected lshift count
     real(dp), public, save :: lshift_reject = zero

!-------------------------------------------------------------------------
!::: core variables: real, rshift action counter                       :::
!-------------------------------------------------------------------------

! rshift kink (operators pair) statistics: total rshift count
     real(dp), public, save :: rshift_tcount = zero

! rshift kink (operators pair) statistics: total accepted rshift count
     real(dp), public, save :: rshift_accept = zero

! rshift kink (operators pair) statistics: total rejected rshift count
     real(dp), public, save :: rshift_reject = zero

!-------------------------------------------------------------------------
!::: core variables: real, reflip action counter                       :::
!-------------------------------------------------------------------------

! reflip kink (operators pair) statistics: total reflip count
     real(dp), public, save :: reflip_tcount = zero

! reflip kink (operators pair) statistics: total accepted reflip count
     real(dp), public, save :: reflip_accept = zero

! reflip kink (operators pair) statistics: total rejected reflip count
     real(dp), public, save :: reflip_reject = zero

  end module ctqmc_core

!!=========================================================================
!!>>> module ctqmc_clur                                                 <<<
!!=========================================================================

!!>>> containing perturbation expansion series related arrays (colour part)
!!>>> used by continuous time quantum Monte Carlo quantum impurity solver
  module ctqmc_clur
     use constants, only : dp

     use stack, only: istack, istack_create, istack_destroy

     implicit none

! memory address index for the imaginary time \tau_s
     integer, public, save, allocatable :: index_s(:,:)

! memory address index for the imaginary time \tau_e
     integer, public, save, allocatable :: index_e(:,:)

! imaginary time \tau_s of create  operators
     real(dp), public, save, allocatable :: time_s(:,:)

! imaginary time \tau_e of destroy operators
     real(dp), public, save, allocatable :: time_e(:,:)

! exp(i\omega t), s means create  operators
     complex(dp), public, save, allocatable :: exp_s(:,:,:)

! exp(i\omega t), e means destroy operators
     complex(dp), public, save, allocatable :: exp_e(:,:,:)

! container for the empty (unoccupied) memory address index
     type (istack), public, save, allocatable :: empty_s(:)

! container for the empty (unoccupied) memory address index
     type (istack), public, save, allocatable :: empty_e(:)

  end module ctqmc_clur

!!=========================================================================
!!>>> module ctqmc_flvr                                                 <<<
!!=========================================================================

!!>>> containing perturbation expansion series related arrays (flavor part)
!!>>> used by continuous time quantum Monte Carlo quantum impurity solver
  module ctqmc_flvr
     use constants, only : dp

     use stack, only: istack, istack_create, istack_destroy

     implicit none

! container for the empty (unoccupied) memory address index of operators
     type (istack), public, save :: empty_v

! memory address index for the imaginary time \tau (auxiliary)
     integer, public, save, allocatable  :: index_t(:)

! memory address index for the imaginary time \tau
     integer, public, save, allocatable  :: index_v(:)

! to record type of operators, 1 means create operators, 0 means destroy operators
     integer, public, save, allocatable  :: type_v(:)

! to record flavor of operators, from 1 to norbs
     integer, public, save, allocatable  :: flvr_v(:)

! imaginary time \tau for create and destroy operators
     real(dp), public, save, allocatable :: time_v(:)

! exp(-H\tau), exponent matrix for local hamiltonian multiply \tau (the last point)
     real(dp), public, save, allocatable :: expt_t(:,:)

! exp(-H\tau), exponent matrix for local hamiltonian multiply \tau
     real(dp), public, save, allocatable :: expt_v(:,:)

  end module ctqmc_flvr

!!========================================================================
!!>>> module ctqmc_mesh                                                <<<
!!========================================================================

!!>>> containing mesh related arrays used by continuous time quantum Monte
!!>>> Carlo quantum impurity solver
  module ctqmc_mesh
     use constants, only : dp

     implicit none

! imaginary time mesh
     real(dp), public, save, allocatable :: tmesh(:)

! real matsubara frequency mesh
     real(dp), public, save, allocatable :: rmesh(:)

! complex matsubara frequency mesh
     complex(dp), public, save, allocatable :: cmesh(:)

  end module ctqmc_mesh

!!========================================================================
!!>>> module ctqmc_meat                                                <<<
!!========================================================================

!!>>> containing physical observables related arrays used by continuous
!!>>> time quantum Monte Carlo quantum impurity solver
  module ctqmc_meat !!>>> To tell you a truth, meat means MEAsuremenT
     use constants, only : dp

     implicit none

! histogram for perturbation expansion series
     integer,  public, save, allocatable :: hist(:)

! auxiliary physical observables
! paux(1) : total energy, Etot
! paux(2) : potential engrgy, Epot
! paux(3) : kinetic energy, Ekin
! paux(4) : magnetic moment, < Sz >
! paux(5) : average of occupation, < N > = < N1 >
! paux(6) : average of occupation square, < N2 >
! paux(7) : reserved
! paux(8) : reserved
     real(dp), public, save, allocatable :: paux(:)

! probability of eigenstates of local hamiltonian matrix
     real(dp), public, save, allocatable :: prob(:)

! impurity occupation number, < n_i >
     real(dp), public, save, allocatable :: nmat(:)

! impurity double occupation number matrix, < n_i n_j >
     real(dp), public, save, allocatable :: nnmat(:,:)

! diagonal elements of current matrix product of flavor part
! it is used to calculate the probability of eigenstates
     real(dp), public, save, allocatable :: ddmat(:,:)

  end module ctqmc_meat

!!=========================================================================
!!>>> module ctqmc_umat                                                 <<<
!!=========================================================================

!!>>> containing util-matrix related arrays used by continuous time quantum
!!>>> Monte Carlo quantum impurity solver
  module ctqmc_umat
     use constants, only : dp

     implicit none

!-------------------------------------------------------------------------
!::: ctqmc status variables                                            :::
!-------------------------------------------------------------------------

! current perturbation expansion order for different flavor channel
     integer,  public, save, allocatable :: rank(:)

!-------------------------------------------------------------------------
!::: input data variables                                              :::
!-------------------------------------------------------------------------
! symmetry properties for correlated orbitals
     integer,  public, save, allocatable :: symm(:)

! impurity level for correlated orbitals
     real(dp), public, save, allocatable :: eimp(:)

! eigenvalues for local hamiltonian matrix
     real(dp), public, save, allocatable :: eigs(:)

! occupation number for the eigenstates of local hamiltonian matrix
     real(dp), public, save, allocatable :: naux(:)

! total spin for the eigenstates of local hamiltonian matrix
     real(dp), public, save, allocatable :: saux(:)

! identity matrix
     complex(dp), public, save, allocatable :: unity(:,:)

  end module ctqmc_umat

!!=========================================================================
!!>>> module ctqmc_mmat                                                 <<<
!!=========================================================================

!!>>> containing M-matrix and G-matrix related arrays used by continuous
!!>>> time quantum Monte Carlo quantum impurity solver
  module ctqmc_mmat
     use constants, only : dp

     implicit none

! helper matrix for evaluating M & G matrices
     real(dp), public, save, allocatable    :: lspace(:,:)

! helper matrix for evaluating M & G matrices
     real(dp), public, save, allocatable    :: rspace(:,:)

! M matrix, $ \mathscr{M} $
     real(dp), public, save, allocatable    :: mmat(:,:,:)

! helper matrix for evaluating G matrix
     complex(dp), public, save, allocatable :: lsaves(:,:)

! helper matrix for evaluating G matrix
     complex(dp), public, save, allocatable :: rsaves(:,:)

! G matrix, $ \mathscr{G} $
     complex(dp), public, save, allocatable :: gmat(:,:,:)

  end module ctqmc_mmat

!!=========================================================================
!!>>> module ctqmc_gmat                                                 <<<
!!=========================================================================

!!>>> containing green's function matrix related arrays used by continuous
!!>>> time quantum Monte Carlo quantum impurity solver
  module ctqmc_gmat
     use constants, only : dp

     implicit none

! impurity green's function, in imaginary time axis, matrix form
     real(dp), public, save, allocatable    :: gtau(:,:,:)

! impurity green's function, in matsubara frequency axis, matrix form
     complex(dp), public, save, allocatable :: grnf(:,:,:)

  end module ctqmc_gmat

!!=========================================================================
!!>>> module ctqmc_wmat                                                 <<<
!!=========================================================================

!!>>> containing weiss's function and hybridization function matrix related
!!>>> arrays used by continuous time quantum Monte Carlo quantum impurity solver
  module ctqmc_wmat
     use constants, only : dp

     implicit none

! bath weiss's function, in imaginary time axis, matrix form
     real(dp), public, save, allocatable    :: wtau(:,:,:)

! bath weiss's function, in matsubara frequency axis, matrix form
     complex(dp), public, save, allocatable :: wssf(:,:,:)

! hybridization function, in imaginary time axis, matrix form
     real(dp), public, save, allocatable    :: htau(:,:,:)

! hybridization function, in matsubara frequency axis, matrix form
     complex(dp), public, save, allocatable :: hybf(:,:,:)

! second order derivates for hybridization function, used to interpolate htau
     real(dp), public, save, allocatable    :: hsed(:,:,:)

  end module ctqmc_wmat

!!=========================================================================
!!>>> module ctqmc_smat                                                 <<<
!!=========================================================================

!!>>> containing self-energy function matrix related arrays used by
!!>>> continuous time quantum Monte Carlo quantum impurity solver
  module ctqmc_smat
     use constants, only : dp

     implicit none

! self-energy function, in matsubara frequency axis, matrix form
     complex(dp), public, save, allocatable :: sig1(:,:,:)

! self-energy function, in matsubara frequency axis, matrix form
     complex(dp), public, save, allocatable :: sig2(:,:,:)

  end module ctqmc_smat

!!=========================================================================
!!>>> module context                                                    <<<
!!=========================================================================

!!>>> containing memory management subroutines and define global variables
  module context
     use constants
     use control

     use ctqmc_core
     use ctqmc_clur
     use ctqmc_flvr
     use ctqmc_mesh
     use ctqmc_meat
     use ctqmc_umat
     use ctqmc_mmat
     use ctqmc_gmat
     use ctqmc_wmat
     use ctqmc_smat

     implicit none

!!========================================================================
!!>>> declare global variables                                         <<<
!!========================================================================

! status flag
     integer, private :: istat

!!========================================================================
!!>>> declare accessibility for module routines                        <<<
!!========================================================================

! declaration of module procedures: allocate memory
     public :: ctqmc_allocate_memory_clur
     public :: ctqmc_allocate_memory_flvr
     public :: ctqmc_allocate_memory_mesh
     public :: ctqmc_allocate_memory_meat
     public :: ctqmc_allocate_memory_umat
     public :: ctqmc_allocate_memory_mmat
     public :: ctqmc_allocate_memory_gmat
     public :: ctqmc_allocate_memory_wmat
     public :: ctqmc_allocate_memory_smat

! declaration of module procedures: deallocate memory
     public :: ctqmc_deallocate_memory_clur
     public :: ctqmc_deallocate_memory_flvr
     public :: ctqmc_deallocate_memory_mesh
     public :: ctqmc_deallocate_memory_meat
     public :: ctqmc_deallocate_memory_umat
     public :: ctqmc_deallocate_memory_mmat
     public :: ctqmc_deallocate_memory_gmat
     public :: ctqmc_deallocate_memory_wmat
     public :: ctqmc_deallocate_memory_smat

  contains

!!=========================================================================
!!>>> allocate memory subroutines                                       <<<
!!=========================================================================

!!>>> ctqmc_allocate_memory_clur: allocate memory for clur-related variables
  subroutine ctqmc_allocate_memory_clur()
     implicit none

! loop index
     integer :: i

! allocate memory
     allocate(index_s(mkink,norbs),     stat=istat)
     allocate(index_e(mkink,norbs),     stat=istat)

     allocate(time_s(mkink,norbs),      stat=istat)
     allocate(time_e(mkink,norbs),      stat=istat)

     allocate(exp_s(nfreq,mkink,norbs), stat=istat)
     allocate(exp_e(nfreq,mkink,norbs), stat=istat)

     allocate(empty_s(norbs),           stat=istat)
     allocate(empty_e(norbs),           stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_clur', &
                            'can not allocate enough memory')
     endif

! initialize them
     index_s = 0
     index_e = 0

     time_s  = zero
     time_e  = zero

     exp_s   = czero
     exp_e   = czero

     do i=1,norbs
         call istack_create(empty_s(i), mkink)
         call istack_create(empty_e(i), mkink)
     enddo ! over i={1,norbs} loop

     return
  end subroutine ctqmc_allocate_memory_clur

!!>>> ctqmc_allocate_memory_flvr: allocate memory for 
!!>>> flvr-related variables
  subroutine ctqmc_allocate_memory_flvr()
     implicit none

! allocate memory
     allocate(index_t(mkink),      stat=istat)
     allocate(index_v(mkink),      stat=istat)

     allocate(type_v(mkink),       stat=istat)
     allocate(flvr_v(mkink),       stat=istat)

     allocate(time_v(mkink),       stat=istat)

     allocate(expt_t(ncfgs,  4  ), stat=istat)
     allocate(expt_v(ncfgs,mkink), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_flvr', &
                            'can not allocate enough memory')
     endif

! initialize them
     index_t = 0
     index_v = 0

     type_v  = 1
     flvr_v  = 1

     time_v  = zero

     expt_t  = zero
     expt_v  = zero

     call istack_create(empty_v, mkink)

     return
  end subroutine ctqmc_allocate_memory_flvr

!!>>> ctqmc_allocate_memory_mesh: allocate memory for 
!!>>> mesh-related variables
  subroutine ctqmc_allocate_memory_mesh()
     implicit none

! allocate memory
     allocate(tmesh(ntime), stat=istat)
     allocate(rmesh(mfreq), stat=istat)
     allocate(cmesh(mfreq), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_mesh', &
                            'can not allocate enough memory')
     endif ! back if ( istat /= 0 ) block

! initialize them
     tmesh = zero
     rmesh = zero
     cmesh = czero

     return
  end subroutine ctqmc_allocate_memory_mesh

!!>>> ctqmc_allocate_memory_meat: allocate memory for 
!!>>> meat-related variables
  subroutine ctqmc_allocate_memory_meat()
     implicit none

! allocate memory
     allocate(hist(mkink),        stat=istat)

     allocate(paux(  8  ),        stat=istat)
     allocate(prob(ncfgs),        stat=istat)
     allocate(nmat(norbs),        stat=istat)
     allocate(nnmat(norbs,norbs), stat=istat)
     allocate(ddmat(ncfgs,  2  ), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_meat', &
                            'can not allocate enough memory')
     endif ! back if ( istat /= 0 ) block

! initialize them
     hist  = 0

     paux  = zero
     prob  = zero
     nmat  = zero
     nnmat = zero
     ddmat = zero

     return
  end subroutine ctqmc_allocate_memory_meat


!!>>> ctqmc_allocate_memory_umat: allocate memory for 
!!>>> umat-related variables
  subroutine ctqmc_allocate_memory_umat()
     implicit none

! allocate memory
     allocate(rank(norbs),        stat=istat)

     allocate(symm(norbs),        stat=istat)
     allocate(eimp(norbs),        stat=istat)
     allocate(eigs(ncfgs),        stat=istat)
     allocate(naux(ncfgs),        stat=istat)
     allocate(saux(ncfgs),        stat=istat)

     allocate(unity(norbs,norbs), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_umat', &
                            'can not allocate enough memory')
     endif

! initialize them
     rank  = 0

     symm  = 0
     eimp  = zero
     eigs  = zero
     naux  = zero
     saux  = zero

     unity = czero

     return
  end subroutine ctqmc_allocate_memory_umat

!!>>> ctqmc_allocate_memory_mmat: allocate memory for 
!!>>> mmat-related variables
  subroutine ctqmc_allocate_memory_mmat()
     implicit none

! allocate memory
     allocate(lspace(mkink,norbs),     stat=istat)
     allocate(rspace(mkink,norbs),     stat=istat)

     allocate(mmat(mkink,mkink,norbs), stat=istat)

     allocate(lsaves(nfreq,norbs),     stat=istat)
     allocate(rsaves(nfreq,norbs),     stat=istat)

     allocate(gmat(nfreq,norbs,norbs), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_mmat', &
                            'can not allocate enough memory')
     endif

! initialize them
     lspace = zero
     rspace = zero

     mmat   = zero

     lsaves = czero
     rsaves = czero

     gmat   = czero

     return
  end subroutine ctqmc_allocate_memory_mmat

!!>>> ctqmc_allocate_memory_gmat: allocate memory for 
!!>>> gmat-related variables
  subroutine ctqmc_allocate_memory_gmat()
     implicit none

! allocate memory
     allocate(gtau(ntime,norbs,norbs), stat=istat)
     allocate(grnf(mfreq,norbs,norbs), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_gmat', &
                            'can not allocate enough memory')
     endif

! initialize them
     gtau = zero

     grnf = czero

     return
  end subroutine ctqmc_allocate_memory_gmat

!!>>> ctqmc_allocate_memory_wmat: allocate memory for 
!!>>> wmat-related variables
  subroutine ctqmc_allocate_memory_wmat()
     implicit none

! allocate memory
     allocate(wtau(ntime,norbs,norbs), stat=istat)
     allocate(htau(ntime,norbs,norbs), stat=istat)
     allocate(hsed(ntime,norbs,norbs), stat=istat)

     allocate(wssf(mfreq,norbs,norbs), stat=istat)
     allocate(hybf(mfreq,norbs,norbs), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_wmat', &
                            'can not allocate enough memory')
     endif

! initialize them
     wtau = zero
     htau = zero
     hsed = zero

     wssf = czero
     hybf = czero

     return
  end subroutine ctqmc_allocate_memory_wmat

!!>>> ctqmc_allocate_memory_smat: allocate memory for 
!!>>> smat-related variables
  subroutine ctqmc_allocate_memory_smat()
     implicit none

! allocate memory
     allocate(sig1(mfreq,norbs,norbs), stat=istat)
     allocate(sig2(mfreq,norbs,norbs), stat=istat)

! check the status
     if ( istat /= 0 ) then
         call s_print_error('ctqmc_allocate_memory_smat', &
                            'can not allocate enough memory')
     endif

! initialize them
     sig1 = czero
     sig2 = czero

     return
  end subroutine ctqmc_allocate_memory_smat

!!=========================================================================
!!>>> deallocate memory subroutines                                     <<<
!!=========================================================================

!!>>> ctqmc_deallocate_memory_clur: deallocate memory for 
!!>>> clur-related variables
  subroutine ctqmc_deallocate_memory_clur()
     implicit none

! loop index
     integer :: i

     do i=1,norbs
         call istack_destroy(empty_s(i))
         call istack_destroy(empty_e(i))
     enddo ! over i={1,norbs} loop

     if ( allocated(index_s) ) deallocate(index_s)
     if ( allocated(index_e) ) deallocate(index_e)

     if ( allocated(time_s)  ) deallocate(time_s )
     if ( allocated(time_e)  ) deallocate(time_e )

     if ( allocated(exp_s)   ) deallocate(exp_s  )
     if ( allocated(exp_e)   ) deallocate(exp_e  )

     if ( allocated(empty_s) ) deallocate(empty_s)
     if ( allocated(empty_e) ) deallocate(empty_e)

     return
  end subroutine ctqmc_deallocate_memory_clur

!!>>> ctqmc_deallocate_memory_flvr: deallocate memory for 
!!>>> flvr-related variables
  subroutine ctqmc_deallocate_memory_flvr()
     implicit none

     call istack_destroy(empty_v)

     if ( allocated(index_t) ) deallocate(index_t)
     if ( allocated(index_v) ) deallocate(index_v)

     if ( allocated(type_v)  ) deallocate(type_v )
     if ( allocated(flvr_v)  ) deallocate(flvr_v )

     if ( allocated(time_v)  ) deallocate(time_v )

     if ( allocated(expt_t)  ) deallocate(expt_t )
     if ( allocated(expt_v)  ) deallocate(expt_v )

     return
  end subroutine ctqmc_deallocate_memory_flvr

!!>>> ctqmc_deallocate_memory_mesh: deallocate memory for 
!!>>> mesh-related variables
  subroutine ctqmc_deallocate_memory_mesh()
     implicit none

     if ( allocated(tmesh) )   deallocate(tmesh)
     if ( allocated(rmesh) )   deallocate(rmesh)
     if ( allocated(cmesh) )   deallocate(cmesh)

     return
  end subroutine ctqmc_deallocate_memory_mesh

!!>>> ctqmc_deallocate_memory_meat: deallocate memory for 
!!>>> meat-related variables
  subroutine ctqmc_deallocate_memory_meat()
     implicit none

     if ( allocated(hist)  )   deallocate(hist )

     if ( allocated(paux)  )   deallocate(paux )
     if ( allocated(prob)  )   deallocate(prob )
     if ( allocated(nmat)  )   deallocate(nmat )
     if ( allocated(nnmat) )   deallocate(nnmat)
     if ( allocated(ddmat) )   deallocate(ddmat)

     return
  end subroutine ctqmc_deallocate_memory_meat


!!>>> ctqmc_deallocate_memory_umat: deallocate memory for 
!!>>> umat-related variables
  subroutine ctqmc_deallocate_memory_umat()
     implicit none

     if ( allocated(rank)  )   deallocate(rank )

     if ( allocated(symm)  )   deallocate(symm )

     if ( allocated(eimp)  )   deallocate(eimp )
     if ( allocated(eigs)  )   deallocate(eigs )
     if ( allocated(naux)  )   deallocate(naux )
     if ( allocated(saux)  )   deallocate(saux )

     if ( allocated(unity) )   deallocate(unity)

     return
  end subroutine ctqmc_deallocate_memory_umat


!!>>> ctqmc_deallocate_memory_mmat: deallocate memory for 
!!>>> mmat-related variables
  subroutine ctqmc_deallocate_memory_mmat()
     implicit none

     if ( allocated(lspace) )  deallocate(lspace)
     if ( allocated(rspace) )  deallocate(rspace)

     if ( allocated(mmat)   )  deallocate(mmat  )

     if ( allocated(lsaves) )  deallocate(lsaves)
     if ( allocated(rsaves) )  deallocate(rsaves)

     if ( allocated(gmat)   )  deallocate(gmat  )

     return
  end subroutine ctqmc_deallocate_memory_mmat

!!>>> ctqmc_deallocate_memory_gmat: deallocate memory for 
!!>>> gmat-related variables
  subroutine ctqmc_deallocate_memory_gmat()
     implicit none

     if ( allocated(gtau) )    deallocate(gtau)

     if ( allocated(grnf) )    deallocate(grnf)

     return
  end subroutine ctqmc_deallocate_memory_gmat

!!>>> ctqmc_deallocate_memory_wmat: deallocate memory for 
!!>>> wmat-related variables
  subroutine ctqmc_deallocate_memory_wmat()
     implicit none

     if ( allocated(wtau) )    deallocate(wtau)
     if ( allocated(htau) )    deallocate(htau)
     if ( allocated(hsed) )    deallocate(hsed)

     if ( allocated(wssf) )    deallocate(wssf)
     if ( allocated(hybf) )    deallocate(hybf)

     return
  end subroutine ctqmc_deallocate_memory_wmat

!!>>> ctqmc_deallocate_memory_smat: deallocate memory for 
!!>>> smat-related variables
  subroutine ctqmc_deallocate_memory_smat()
     implicit none

     if ( allocated(sig1) )    deallocate(sig1)
     if ( allocated(sig2) )    deallocate(sig2)

     return
  end subroutine ctqmc_deallocate_memory_smat

  end module context
