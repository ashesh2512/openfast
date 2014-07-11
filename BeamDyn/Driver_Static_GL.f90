!..................................................................................................................................
! LICENSING                                                                                                                         
! Copyright (C) 2013  National Renewable Energy Laboratory
!
!    Glue is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
!    published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
!
!    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
!    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License along with Module2.
!    If not, see <http://www.gnu.org/licenses/>.
!
!**********************************************************************************************************************************
!  
!    ADD DESCRIPTION
!	This is the driver for the static solution.  The driver calls the StaticSolutionGL and ComputeRootForce subroutines. 
!	The StaticSolutionGL subroutine returns the final values of the displacement for each node. ComputeRootForce, computes the forces
!	and moments at the root.  The driver also generates the output files "BeamDyn.out" and "QiStaticDisp.out".
!
!    References:
!
!
!**********************************************************************************************************************************
PROGRAM MAIN

   USE BeamDynLSGL
   USE BeamDyn_Types

   USE NWTC_Library

   IMPLICIT NONE

   ! global glue-code-specific variables

   INTEGER(IntKi)                     :: ErrStat          ! Error status of the operation
   CHARACTER(1024)                    :: ErrMsg           ! Error message if ErrStat /= ErrID_None

   REAL(DbKi)                         :: dt_global_dummy  ! fixed/constant global time step

   INTEGER(IntKi)                     :: n_t_final        ! total number of time steps
   INTEGER(IntKi)                     :: n_t_global       ! global-loop time counter

   INTEGER(IntKi)                     :: pc_max           ! 1:explicit loose; 2:pc loose
   INTEGER(IntKi)                     :: pc               ! counter for pc iterations

   INTEGER(IntKi)                     :: BD_interp_order     ! order of interpolation/extrapolation
   REAL(Reki), ALLOCATABLE  		  :: F_total(:)		  !Dummy variable for large load loop NJ 3/18/14
   INTEGER(IntKi),PARAMETER:: OutUnit = 10
   INTEGER(IntKi),PARAMETER:: OutQiUnit = 20

   ! BeamDyn Derived-types variables; see Registry_BeamDyn.txt for details

   TYPE(BD_InitInputType)           :: BD_InitInput
   TYPE(BD_ParameterType)           :: BD_Parameter
   TYPE(BD_ContinuousStateType)     :: BD_ContinuousState
   TYPE(BD_ContinuousStateType)     :: BD_ContinuousStateDeriv
   TYPE(BD_InitOutputType)          :: BD_InitOutput
   TYPE(BD_DiscreteStateType)       :: BD_DiscreteState
   TYPE(BD_ConstraintStateType)     :: BD_ConstraintState
   TYPE(BD_OtherStateType)          :: BD_OtherState

   TYPE(BD_InputType),Dimension(:),Allocatable  :: BD_Input
   REAL(DbKi) , DIMENSION(:), ALLOCATABLE           :: BD_InputTimes

   TYPE(BD_OutputType),Dimension(:),Allocatable  :: BD_Output
   REAL(DbKi) , DIMENSION(:), ALLOCATABLE          :: BD_OutputTimes

   ! local variables
   Integer(IntKi)                     :: i               ! counter for various loops
   Integer(IntKi)                     :: j               ! counter for various loops
   Integer(IntKi)                     :: k               ! counter for various loops
   Integer(IntKi)                     :: n               ! counter load reduction

   OPEN(unit = OutUnit, file = 'BeamDyn.out', status = 'REPLACE',ACTION = 'WRITE')
   OPEN(unit = OutQiUnit, file = 'QiStaticDisp.out', status = 'REPLACE',ACTION = 'WRITE')

   ! -------------------------------------------------------------------------
   ! Initialization of glue-code time-step variables
   ! -------------------------------------------------------------------------

   ! NONE


   ! -------------------------------------------------------------------------
   ! Initialization of Modules
   !  note that in this example, we are assuming that dt_global is not changed 
   !  in the modules, i.e., that both modules are called at the same glue-code  
   !  defined coupling interval.
   ! -------------------------------------------------------------------------

!   BDyn_InitInput%verif    = 1  ! 1 - unit force per unit lenght specified through input mesh in InputSolve

!   BDyn_InitInput%num_elem = 1  ! number of elements spanning length

!   BDyn_InitInput%order    = 12  ! order of spectral elements

   !Simple_Cant_Beam: allocate Input and Output arrays; used for interpolation and extrapolation
   Allocate(BD_Input(1))
   Allocate(BD_InputTimes(1))

   Allocate(BD_Output(1))
   Allocate(BD_OutputTimes(1))

   BD_InitInput%InputFile = 'BeamDyn_Curved.inp'
   BD_InitInput%RootName  = TRIM(BD_Initinput%InputFile)

   CALL BeamDyn_Init( BD_InitInput        &
                   , BD_Input(1)         &
                   , BD_Parameter        &
                   , BD_ContinuousState  &
                   , BD_DiscreteState    &
                   , BD_ConstraintState  &
                   , BD_OtherState       &
                   , BD_Output(1)        &
                   , dt_global_dummy       &
                   , BD_InitOutput       &
                   , ErrStat               &
                   , ErrMsg )

    ALLOCATE( F_total(BD_Parameter%dof_total),      STAT=ErrStat ) !Allocate dummy variable NJ 3/18/14
    F_total = 0.0D0
!------------------------------------------------
! start - playground
!------------------------------------------------

!------------------------------------------------
! end - playground
!------------------------------------------------

   ! We fill BDyn_InputTimes with negative times, but the BDyn_Input values are identical for each of those times; this allows 
   ! us to use, e.g., quadratic interpolation that effectively acts as a zeroth-order extrapolation and first-order extrapolation 
   ! for the first and second time steps.  (The interpolation order in the ExtrapInput routines are determined as 
   ! order = SIZE(BDyn_Input)

   ! -------------------------------------------------------------------------
   ! Time-stepping loops
   ! -------------------------------------------------------------------------

   ! write headers for output columns:
       

   ! write initial condition for q1
   !CALL WrScr  ( '  '//Num2LStr(t_global)//'  '//Num2LStr( BDyn_ContinuousState%q)//'  '//Num2LStr(BDyn_ContinuousState%q))   
   
n=1

!DO j=1,1	!ADDED LOOP TO RUN THROUGH ALL LOAD STEP SCENARIOS, NJ 3/18/2014
!	CALL StaticSolutionGL(BD_Parameter%uuN0, BD_OtherState%uuNf,&
 !                     &BD_Parameter%Stif0_GL, BD_Parameter%F_ext,BD_Parameter%bc,&
 !                     &BD_Parameter%node_elem, BD_Parameter%dof_node,&
 !                     &BD_Parameter%elem_total, BD_Parameter%dof_total,BD_Parameter%node_total,&
 !                     &BD_Parameter%ngp,BD_Parameter%niter,BD_Parameter%piter)  	  
!	IF (BD_Parameter%piter .EQ. BD_Parameter%niter) THEN	!CONDITION IF NR ITERATIONS HAVE BEEN REACHED ZERO OUT uunF, NJ 3/18/2014
!		BD_OtherState%uuNf=0
!		WRITE(*,*) "Warning: Load may be too large, BeamDyn will attempt to solve with 2 steps"
	!END IF

   
    
	!IF (BD_Parameter%piter .NE. BD_Parameter%niter) EXIT !EXIT OVERALL LOOP IF NUMBER OF NR ITERATION HAS NOT BEEN REACHED, NJ 3/18/2014 

!IF SOUTION IS NOT YET CONVERGED TRY TAKING LOAD IN 2 STEPS
	F_total = BD_Parameter%F_ext	!DEFINES DUMMY VARIABLE TO CUT LOAD IN HALF, NJ 3/18/2014
	DO WHILE (n .NE. 0)  
    k=n
		DO i=1,k
          BD_Parameter%F_ext=F_total/n*i
		   CALL StaticSolutionGL(BD_Parameter%uuN0, BD_OtherState%uuNf,&
                      &BD_Parameter%Stif0_GL, BD_Parameter%F_ext,BD_Parameter%bc,&
                      &BD_Parameter%node_elem, BD_Parameter%dof_node,&
                      &BD_Parameter%elem_total, BD_Parameter%dof_total,BD_Parameter%node_total,&
                      &BD_Parameter%ngp,BD_Parameter%niter,BD_Parameter%piter) 
                END DO
        
        IF (BD_Parameter%piter .LT. BD_Parameter%niter) THEN
          n=0  
!          EXIT
        ELSE
            n=n+1
            WRITE(*,*) "Warning: Load may be too large, BeamDyn will attempt to solve with addition steps"
            WRITE(*,*) "n=",n
            BD_OtherState%uuNf=0
        ENDIF!CONDITION IF NR ITERATIONS HAVE BEEN REACHED ZERO OUT uunF, NJ 3/18/2014 
		     
        ENDDO
	

!IF SOUTION IS NOT YET CONVERGED TRY TAKING LOAD IN 3 STEPS
!	IF (BD_Parameter%piter .NE. BD_Parameter%niter) EXIT
!	DO i =1,3
!		BD_Parameter%F_ext=F_total/3*i
!		CALL StaticSolutionGL(BD_Parameter%uuN0, BD_OtherState%uuNf,&
 !                     &BD_Parameter%Stif0_GL, BD_Parameter%F_ext,BD_Parameter%bc,&
  !                    &BD_Parameter%node_elem, BD_Parameter%dof_node,&
   !                   &BD_Parameter%elem_total, BD_Parameter%dof_total,BD_Parameter%node_total,&
    !                  &BD_Parameter%ngp,BD_Parameter%niter,BD_Parameter%piter) 
	!END DO
	!IF (BD_Parameter%piter .EQ. BD_Parameter%niter) THEN !CONDITION IF NR ITERATIONS HAVE BEEN REACHED EXIT PROGRAM, NJ 3/18/2014
	!	WRITE(*,*) "Solution failed to converge after reducing load into 3 steps: end simulation"
	!	STOP
	!END IF
!END DO
   
!   CALL StaticSolutionGL(BDyn_Parameter%uuN0, BDyn_OtherState%uuNf,&
!                      &BDyn_Parameter%Stif0, BDyn_Parameter%F_ext,BDyn_Parameter%bc,&
!                      &BDyn_Parameter%node_elem, BDyn_Parameter%dof_node,&
!                      &BDyn_Parameter%elem_total, BDyn_Parameter%dof_total,BDyn_Parameter%node_total,&
!                      &BDyn_Parameter%ngp,BDyn_Parameter%niter)   

   CALL ComputeRootForce(BD_Parameter%uuN0,BD_OtherState%uuNf,&
                 &BD_Parameter%Stif0_GL,BD_Parameter%node_elem,BD_Parameter%dof_node,&
                 &BD_Parameter%ngp,BD_OtherState%RootForce)

!   CALL ComputeRootForceNodal(BD_Parameter%uuN0,BD_OtherState%uuNf,&
!                    &BD_Parameter%Stif0_N1,BD_Parameter%node_elem,BD_Parameter%dof_node,&
!                    &BD_OtherState%RootForce)

   WRITE(OutUnit,*) 'Initial Nodal Configurations (uuN0):'
   WRITE(OutUnit,*) '=========================================='
   DO i=1,BD_Parameter%elem_total
       WRITE(OutUnit,*) 'Member #: ',i
       DO j=1,BD_Parameter%node_elem
           k = (j - 1) * BD_Parameter%dof_node
           WRITE(OutUnit,3000) BD_Parameter%uuN0(k+1,i),BD_Parameter%uuN0(k+2,i),BD_Parameter%uuN0(k+3,i),&
                              &BD_Parameter%uuN0(k+4,i),BD_Parameter%uuN0(k+5,i),BD_Parameter%uuN0(k+6,i)
       ENDDO
   ENDDO
  
   WRITE(OutUnit,*) 'Nodal Displacements (uuNf):'
   WRITE(OutUnit,*) '=========================================='
   DO i=1,BD_Parameter%node_total
       j = (i - 1) * BD_Parameter%dof_node
       WRITE(OutUnit,1000) i,BD_OtherState%uuNf(j+1),BD_OtherState%uuNf(j+2),BD_OtherState%uuNf(j+3),&
                          &BD_OtherState%uuNf(j+4),BD_OtherState%uuNf(j+5),BD_OtherState%uuNf(j+6)
   ENDDO
   WRITE(OutUnit,*) 'Root Forces'
   WRITE(OutUnit,*) '=========================================='
   WRITE(OutUnit,1000) 1,BD_OtherState%RootForce(1),BD_OtherState%RootForce(2),BD_OtherState%RootForce(3),&
                          &BD_OtherState%RootForce(4),BD_OtherState%RootForce(5),BD_OtherState%RootForce(6)

   DO i=1,BD_Parameter%node_total
       j = (i-1) * BD_Parameter%dof_node
       WRITE(OutQiUnit,2000) BD_OtherState%uuNf(j+1),BD_OtherState%uuNf(j+2),&
                            &BD_OtherState%uuNf(j+3),BD_OtherState%uuNf(j+4),BD_OtherState%uuNf(j+5),&
                            &BD_OtherState%uuNf(j+6)
   ENDDO

   1000 FORMAT (' ',I5.2,6ES21.12)
   2000 FORMAT (' ',7ES21.12)
   3000 FORMAT (' ',6ES21.12)
   CLOSE (OutUnit)
   CLOSE (OutQiUnit)
!         CALL BDyn_UpdateStates( t_global, n_t_global, BDyn_Input, BDyn_InputTimes, BDyn_Parameter, &
!                                   BDyn_ContinuousState_pred, &
!                                   BDyn_DiscreteState_pred, BDyn_ConstraintState_pred, &
!                                   BDyn_OtherState, ErrStat, ErrMsg )


         !-----------------------------------------------------------------------------------------
         ! If correction iteration is to be taken, solve intput-output equations; otherwise move on
         !-----------------------------------------------------------------------------------------

!         if (pc .lt. pc_max) then
!
!            call BDyn_Mod2_InputOutputSolve( t_global + dt_global, &
!                                             BDyn_Input(1), BDyn_Parameter, BDyn_ContinuousState_pred, BDyn_DiscreteState_pred, &
!                                             BDyn_ConstraintState_pred, BDyn_OtherState, BDyn_Output(1), &
!                                             Mod2_Input(1), Mod2_Parameter, Mod2_ContinuousState_pred, Mod2_DiscreteState_pred, &
!                                             Mod2_ConstraintState_pred, Mod2_OtherState, Mod2_Output(1),  &
!                                             ErrStat, ErrMsg)

!        endif



      ! output displacment at mid-node (assuming even elements

      ! i = ((BDyn_Parameter%num_elem / 2 ) * BDyn_Parameter%order + 1) * BDyn_Parameter%dof_per_node - 1
      !write(70,*) t_global, BDyn_ContinuousState%q(i), i
  

   ! -------------------------------------------------------------------------
   ! Ending of modules
   ! -------------------------------------------------------------------------
   

   CALL BeamDyn_End( BD_Input(1), BD_Parameter, BD_ContinuousState, BD_DiscreteState, &
                    BD_ConstraintState, BD_OtherState, BD_Output(1), ErrStat, ErrMsg )

   do i = 2, BD_interp_order+1
      CALL BD_DestroyInput(BD_Input(i), ErrStat, ErrMsg )
      CALL BD_DestroyOutput(BD_Output(i), ErrStat, ErrMsg )
   enddo

   DEALLOCATE(BD_Input)
   DEALLOCATE(BD_Output)
   DEALLOCATE(BD_InputTimes)
   DEALLOCATE(BD_OutputTimes)


END PROGRAM MAIN
