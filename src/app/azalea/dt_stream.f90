

  subroutine dt_setup_param()
     use constants, only : dp

     use control

     implicit none

! only for debug
     nffrq = 16
     nbfrq = 7

     part  = 1.0_dp 
     beta  = 1.0_dp

     return
  end subroutine dt_setup_param

  subroutine dt_setup_model()
     use context

     implicit none

     call dt_mesh_init()

     call dt_dump_grnd(fmesh,dual_g)
     STOP
     call dt_dmft_init()
     call dt_latt_init()
     call dt_dual_init()
     call dt_vert_init()

     return
  end subroutine dt_setup_model

  subroutine dt_mesh_init()
     use constants, only : dp, one, two, pi

     use control
     use context

     implicit none

! local variables
     integer :: i
     integer :: j
     integer :: k

     do i=1,nkp_x
         kx(i) = (two * pi) * float(i - 1)/ float(nkp_x)
     enddo ! over i={1,nkp_x} loop

     do i=1,nkp_y
         ky(i) = (two * pi) * float(i - 1)/ float(nkp_y)
     enddo ! over i={1,nkp_y} loop

     do i=1,nkp_z
         kz(i) = (two * pi) * float(i - 1)/ float(nkp_z)
     enddo ! over i={1,nkp_z} loop

! build a 2d lattice
     k = 0
     do i=1,nkp_x
         do j=1,nkp_y
             k = k + 1
             ek(k) = -two * part * ( cos( kx(i) ) + cos( ky(j) ) )
         enddo ! over j={1,nkp_y} loop
     enddo ! over i={1,nkp_x} loop     
     call s_assert(k == nkpts)

     do i=1,nffrq
         fmesh(i) = (two * i - one - nffrq) * pi / beta
     enddo ! over i={1,nffrq} loop

     do i=1,nbfrq
         bmesh(i) = (two * i - one - nbfrq) * pi / beta
     enddo ! over i={1,nbfrq} loop

     return
  end subroutine dt_mesh_init

  subroutine dt_dmft_init()
     use constants, only : dp, mytmp

     use control
     use context

     implicit none

! local variables
     integer  :: i
     integer  :: if1, if2
     real(dp) :: r1, r2
     real(dp) :: c1, c2
     real(dp) :: d1, d2
     real(dp) :: v1, v2

! read in impurity green's function
     open(mytmp, file = 'df.dmft_g.in', form = 'formatted', status = 'unknown')
     do i=1,nffrq
         read(mytmp,*) r1, r2, c1, c2
         dmft_g(i,1) = dcmplx(c1, c2)
         dmft_g(i,2) = dcmplx(c1, c2)
     enddo ! over i={1,nffrq} loop
     close(mytmp)

! read in hybridization function
     open(mytmp, file = 'df.dmft_h.in', form = 'formatted', status = 'unknown')
     do i=1,nffrq
         read(mytmp,*) r1, r2, c1, c2
         dmft_h(i,1) = dcmplx(c1, c2)
         dmft_h(i,2) = dcmplx(c1, c2)
     enddo ! over i={1,nffrq} loop
     close(mytmp)

! read in vertex function, density channel
     open(mytmp, file = 'df.vert_d.in', form = 'formatted', status = 'unknown')
     do i=1,nbfrq
         do if1=1,nffrq
             do if2=1,nffrq
                 read(mytmp,*) r1, r2, c1, c2, d1, d2, v1, v2
                 vert_d(if2,if1,i) = dcmplx(v1, v2)
             enddo ! over if2={1,nffrq} loop
             read(mytmp,*) ! skip one line
         enddo ! over if1={1,nffrq} loop
     enddo ! over i={1,nbfrq} loop
     close(mytmp)

! read in vertex function, magentic channel
     open(mytmp, file = 'df.vert_m.in', form = 'formatted', status = 'unknown')
     do i=1,nbfrq
         do if1=1,nffrq
             do if2=1,nffrq
                 read(mytmp,*) r1, r2, c1, c2, d1, d2, v1, v2
                 vert_m(if2,if1,i) = dcmplx(v1, v2)
             enddo
             read(mytmp,*) ! skip one line
         enddo
     enddo
     close(mytmp)

     return
  end subroutine dt_dmft_init

  subroutine dt_latt_init()
     use constants, only : dp, one

     use control
     use context

     implicit none

! local variables
     integer :: i
     integer :: j
     integer :: k

     do i=1,norbs
         do j=1,nffrq
             do k=1,nkpts
                 latt_g(k,j,i) = one / ( one / dmft_g(j,i) + dmft_h(j,i) - ek(k) ) 
             enddo ! over k={1,nkpts} loop
         enddo ! over j={1,nffrq} loop
     enddo ! over i={1,norbs} loop

     return
  end subroutine dt_latt_init

  subroutine dt_dual_init()
     use constants, only : dp 

     use control
     use context

     implicit none

! local variables
     integer :: i
     integer :: j
     integer :: k

     do i=1,norbs
         do j=1,nffrq
             do k=1,nkpts
                 dual_b(k,j,i) = latt_g(k,j,i) - dmft_g(j,i) 
                 dual_g(k,j,i) = dual_b(k,j,i)
                 dual_s(k,j,i) = czero
             enddo ! over k={1,nkpts} loop
         enddo ! over j={1,nffrq} loop
     enddo ! over i={1,norbs} loop

     return
  end subroutine dt_dual_init

  subroutine dt_vert_init()
     implicit none

     return
  end subroutine dt_vert_init

  subroutine dt_alloc_array()
     use context ! ALL

     implicit none

! allocate memory for context module
     call cat_alloc_mesh()
     call cat_alloc_dmft()
     call cat_alloc_dual()
     call cat_alloc_latt()
     call cat_alloc_vert()
     
     return
  end subroutine dt_alloc_array

  subroutine dt_reset_array()
     implicit none

     return
  end subroutine dt_reset_array

  subroutine dt_final_array()
     use context ! ALL

     implicit none

! deallocate memory for context module
     call cat_free_mesh()
     call cat_free_dmft()
     call cat_free_dual()
     call cat_free_latt()
     call cat_free_vert()

     return
  end subroutine dt_final_array
