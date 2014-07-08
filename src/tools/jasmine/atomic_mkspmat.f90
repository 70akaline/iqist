! make single particle related matrices, including:
! crystal field, spin-orbital coupling, Coulomb inteartion U
subroutine atomic_make_spmat()
    use m_spmat

    implicit none

    ! first, allocate memory for these single particle matrices
    call alloc_m_spmat()

    ! second, make crystal field and spin-orbital coupling 
    if (itask == 1) then ! model calculation
        if (icf > 0) then
            call atomic_read_cf()
        else
            cfmat = czero
        endif

        if (isoc > 0) then
            call atomic_make_soc()
        else
            socmat = czero
        endif
    else ! material calculation
        ! read the eimp (CF+SOC) matrices on natural basis
        ! this matrix should be a diagonal matrix, and we just
        ! need its diagonal elements
        call atomic_read_eimp()
        ! read the transformation matrices used to transfer eimp 
        ! from the standard real orbitals basis to natural basis 
        call atomic_read_umat()
    endif

    ! third, make Coulomb interaction U
    if (icu == 1) then
        ! Kanamori parameters type
        call atomic_make_cumat_kanamori()
    else
        ! Slater-Cordon parameters type
        call atomic_make_cumat_slater()
    endif

    return
end subroutine atomic_make_spmat 

!>>> make spin-orbital coupling 
subroutine atomic_make_soc()
    use constants
    use control
    use m_spmat

    implicit none

    if (nband == 3) then
        call atomic_make_soc_3band(socmat)
        socmat = -socmat * lambda / two
    elseif(nband == 5) then
        call atomic_make_soc_5band(socmat)
        socmat = socmat * lambda / two
    elseif(nband == 7) then
        call atomic_make_soc_7band(socmat)
        socmat = socmat * lambda / two
    else
        call atomic_print_error('atomic_make_soc', 'not implementd!')
    endif

    return 
end subroutine atomic_make_soc

!>>> make spin-orbital coupling matrix for 3 band
subroutine atomic_make_soc_3band(socmat)
    implicit none

    ! external variables
    integer, parameter :: dp = kind(0.0d0)
    complex(dp), intent(out) :: socmat(6,6)

    ! local variables
    real(dp) :: sqrt2

    sqrt2 = sqrt(2.0_dp)
   
    ! make SOC on complex orbital basis
    ! the orbital order is:
    ! |-1,up>, |-1,dn>, |0,up>, |0,dn>, |1,up>, |1,dn>      
    socmat = dcmplx(0.0_dp, 0.0_dp)

    socmat(1,1) = -1.0_dp
    socmat(4,1) = sqrt2 
    socmat(2,2) =  1.0_dp
    socmat(6,3) = sqrt2
    socmat(1,4) = sqrt2
    socmat(5,5) = 1.0_dp
    socmat(3,6) = sqrt2
    socmat(6,6) = -1.0_dp

    return
end subroutine atomic_make_soc_3band

!>>> make spin-orbital coupling matrix for 5 band
subroutine atomic_make_soc_5band(socmat)
    implicit none

    ! external variables
    integer, parameter :: dp = kind(0.0d0)
    complex(dp), intent(out) :: socmat(10,10)

    ! local variables
    ! sqrt(6)
    real(dp) :: sqrt6

    sqrt6 = sqrt(6.0_dp)
    ! make SOC on complex orbital basis
    ! the orbital order is:
    ! |-2,up>, |-2,dn>, |-1,up>, |-1,dn>, |0,up>, |0,dn>, |1,up>, |1,dn>, |2,up>, |2,dn>      

    socmat = dcmplx(0.0_dp, 0.0_dp)
    socmat(1,1) = -2.0_dp 
    socmat(4,1) =  2.0_dp
    socmat(2,2) =  2.0_dp
    socmat(3,3) = -1.0_dp
    socmat(6,3) =  sqrt6
    socmat(1,4) =  2.0_dp
    socmat(4,4) =  1.0_dp
    socmat(8,5) =  sqrt6
    socmat(3,6) =  sqrt6
    socmat(7,7) =  1.0_dp
    socmat(10,7)=  2.0_dp
    socmat(5,8) =  sqrt6  
    socmat(8,8) = -1.0_dp
    socmat(9,9) =  2.0_dp
    socmat(7,10)=  2.0_dp 
    socmat(10,10)= -2.0_dp

    return 
end subroutine atomic_make_soc_5band

!>>> make spin-orbital coupling matrix for 7 band
subroutine atomic_make_soc_7band(socmat)
    implicit none

    ! external variables
    complex(dp), intent(out) :: socmat(14,14)    

    ! local variables
    integer, parameter :: dp = kind(0.0d0)
    real(dp) :: sqrt6
    real(dp) :: sqrt10
    real(dp) :: sqrt12

    
    sqrt6  = sqrt(6.0_dp)
    sqrt10 = sqrt(10.0_dp)
    sqrt12 = sqrt(12.0_dp)

    socmat = dcmplx(0.0_dp, 0.0_dp)

    socmat(1,1) = -3.0_dp
    socmat(4,1) = sqrt6
    socmat(2,2) = 3.0_dp
    socmat(3,3) = -2.0_dp
    socmat(6,3) = sqrt10 
    socmat(1,4) = sqrt6
    socmat(4,4) = 2.0_dp
    socmat(5,5) = -1.0_dp
    socmat(8,5) = sqrt12
    socmat(3,6) = sqrt10 
    socmat(6,6) = 1.0_dp
    socmat(10,7) = sqrt12
    socmat(5,8) = sqrt12
    socmat(9,9) = 1.0_dp
    socmat(12,9) = sqrt10
    socmat(7,10) = sqrt12
    socmat(10,10) = -1.0_dp
    socmat(11,11) =  2.0_dp
    socmat(14,11) =  sqrt6
    socmat(9,12) = sqrt10
    socmat(12,12) =  -2.0_dp
    socmat(13,13) =  3.0_dp
    socmat(11,14) =  sqrt6
    socmat(14,14) =  -3.0_dp

    return
end subroutine atomic_make_soc_7band

!>>> make Coulomb interaction U, this subroutine is taken from 
!>>> duliang's atomic software
subroutine atomic_make_cumat_kanamori()
    use constants
    use control
    use m_spmat

    implicit none

    ! local varibales
    ! loop index over orbits
    integer :: alpha, betta
    integer :: delta, gamma
    ! band index and spin index
    integer :: aband, bband 
    integer :: dband, gband 
    integer :: aspin, bspin 
    integer :: dspin, gspin 
    ! auxiliary variables
    real(dp) :: dtmp

    ! initialize cumat to zero
    cumat = czero

    ! loop for creation operators
    alphaloop: do alpha=1,norbs-1
    bettaloop: do betta=alpha+1,norbs

       ! loop for annihilation operators
       gammaloop: do gamma=1,norbs-1
       deltaloop: do delta=gamma+1,norbs
           aband = (alpha+1)/2; aspin = mod(alpha,2)
           bband = (betta+1)/2; bspin = mod(betta,2)
           gband = (gamma+1)/2; gspin = mod(gamma,2)
           dband = (delta+1)/2; dspin = mod(delta,2)

           ! here we use "res" due to overlap between "Uv and Jz"
           dtmp = zero

           ! intraorbital Coulomb interaction
           if ((alpha.eq.gamma) .and. (betta.eq.delta)) then
               if ((aband.eq.bband) .and. (aspin.ne.bspin)) then
                   dtmp = dtmp + Uc
               endif
           endif

           ! interorbital Coulomb interaction
           if ((alpha.eq.gamma) .and. (betta.eq.delta)) then
               if (aband .ne. bband) then
                   dtmp = dtmp + Uv
               endif
           endif

           ! Hund's exchange interaction 
           if ((alpha.eq.gamma) .and. (betta.eq.delta)) then
               if ((aband.ne.bband) .and. (aspin.eq.bspin)) then
                   dtmp = dtmp - Jz
               endif
           endif
          
           ! spin flip term
           if ((aband.eq.gband) .and. (bband.eq.dband)) then
               if ((aspin.ne.gspin) .and. (bspin.ne.dspin) .and. (aspin.ne.bspin)) then
                   dtmp = dtmp - Js
               endif
           endif
         
           ! pair hopping term
           if ((aband.eq.bband) .and. (dband.eq.gband) .and. (aband.ne.dband)) then
               if ((aspin.ne.bspin) .and. (dspin.ne.gspin) .and. (aspin.eq.gspin)) then
                   dtmp = dtmp + Jp
               endif
           endif
                
           cumat(alpha, betta, delta, gamma) = dtmp

       enddo deltaloop ! over delta={gamma+1,norbs} loop
       enddo gammaloop ! over gamma={1,norbs-1} loop
    enddo bettaloop ! over betta={alpha+1,norbs} loop
    enddo alphaloop ! over alpha={1,norbs-1} loop

    return
end subroutine atomic_make_cumat_kanamori

!>>> make Coulomb interation U, Slater Integral version
subroutine atomic_make_cumat_slater()
    use constants
    use control
    use m_spmat

    implicit none

    ! local variables
    ! Slater-Cordon parameters
    real(dp), allocatable :: slater_cordon(:)
    ! gaunt coefficients
    real(dp), allocatable :: gaunt(:,:,:)

    ! orbital momentum quantum number
    integer :: l
    ! loop index
    integer :: k
    integer :: alpha, betta
    integer :: delta, gamma
    integer :: aband, aspin
    integer :: bband, bspin
    integer :: dband, dspin
    integer :: gband, gspin
    ! real(dp) auxiliary variables
    real(dp) :: res


    ! allocate memory for slater_cordon and gaunt and then build them
    if (nband == 5) then
        l = 2
        allocate(slater_cordon(0:2*l))     
        slater_cordon = zero
        slater_cordon(0) = F0
        slater_cordon(2) = F2
        slater_cordon(4) = F4
        allocate(gaunt(-l:l, -l:l, 0:2*l)
        call atomic_gaunt_5band(gaunt) 
    elseif(nband == 7) then
        l = 3
        allocate(slater_cordon(0:2*l))     
        slater_cordon = zero
        slater_cordon(0) = F0
        slater_cordon(2) = F2
        slater_cordon(4) = F4
        slater_cordon(6) = F6
        allocate(gaunt(-l:l, -l:l, 0:2*l)
        call atomic_gaunt_7band(gaunt)
    else
        call atomic_print_error('atomic_make_cumat_slater', 'nband is wrong!')
    endif

    ! make Coulomb interaction U matrix
    do alpha=1,norbs
    do betta=1,norbs
        aband = (alpha-1)/2-l
        bband = (betta-1)/2-l
        aspin = mod(alpha, 2)
        bspin = mod(betta, 2)

        do delta=1,norbs
        do gamma=1,norbs
            dband = (delta-1)/2-l
            gband = (gamma-1)/2-l
            dspin = mod(delta, 2)
            gspin = mod(gamma, 2)

            if ((alpha .eq. betta) .or. (delta .eq. gamma)) cycle

            if ((aband + bband) .ne. (dband + gband)) cycle
            if ((aspin .ne. gspin) .or. (bspin .ne. dspin)) cycle

            ! fixme  wrong in rpp 69, 2061 (2006), ref: prb 75, 155113 (2007)
            ! exchange of dband and bband
            res = zero
            do k=0, 2*l, 2
                res = res + gaunt(aband, gband, k) * gaunt(dband, bband, k) * slater_cordon(k)
            enddo
            cumat(alpha, betta, delta, gamma) = res
        enddo ! over gamma={1,norbs} loop
        enddo ! over delta={1,norbs} loop

    enddo ! over betta={1,norbs} loop
    enddo ! over alpha={1,norbs} loop

    cumat = half * cumat

    ! deallocate memory
    if (allocated(slater_cordon)) deallocate(slater_cordon) 
    if (allocated(gaunt))         deallocate(gaunt)

    return
end subroutine atomic_make_cumat_slater
