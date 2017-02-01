! parse input files, readin data
  subroutine df_config()
     use df_control

     implicit none

! only for debug
     nffrq = 16
     nbfrq = 7

     return
  end subroutine df_config

  subroutine df_setup_array()
     use df_context ! ALL

     implicit none

! allocate memory for df_context module
     call df_allocate_memory_dmft()
     call df_allocate_memory_dual()
     call df_allocate_memory_latt()
     call df_allocate_memory_vert()
     
     return
  end subroutine df_setup_array

  subroutine df_mesh_init()
     implicit none

     return
  end subroutine df_mesh_init

  subroutine df_dmft_init()
     use constants, only : dp, mytmp

     use df_control
     use df_context

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
  end subroutine df_dmft_init

  subroutine df_dual_init()
     implicit none

     return
  end subroutine df_dual_init

  subroutine df_latt_init()
     implicit none

     return
  end subroutine df_latt_init

  subroutine df_vert_init()
     implicit none

     return
  end subroutine df_vert_init

  subroutine df_final_array()
     use df_context ! ALL

     implicit none

! deallocate memory for df_context module
     call df_deallocate_memory_dmft()
     call df_deallocate_memory_dual()
     call df_deallocate_memory_latt()
     call df_deallocate_memory_vert()

     return
  end subroutine df_final_array
