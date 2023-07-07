module fvs_step
    !Implements the FVS grower loop in a step-wise manner.
    !The included subroutines fvs_init, fvs_grow, and fvs_end are extractions
    !   from the fvs subroutine in fvs.f and implement it's component parts.
    !
    !   Several core FVS 'include' files have been rougly ported to f90 modules
    !   to support 'use' statements, streamline compilation, and to take
    !   advantage of modern Fortran functionality and language integration
    !   tools (primarily F2PY).
    !
    !   Additional core FVS routines have been modified to support the step API.
    !   The modified routines have been renamed and are called only from the
    !   step API routines.
    !
    !   Modified FVS routines:
    !       tregro.f => step_tregro.f
    !       grincr.f => step_grincr.f
    !
    !Author: Tod Haren, tod.haren@gmail.com
    !Date: 10/2013

    !TODO: Strip out the restart and cmdline logic from the step API routines

    use tree_data, only: save_tree_data,copy_tree_data,copy_mort_data,copy_cuts_data
    use globals, only: &
        ! PRGPRM
        maxcyc,maxcy1,maxtp1, &
        ! CONTRL
        icl1,icl6,icyc,irec2,itable,itrn,iy,jostnd,lflag,lstart,ncyc, &
        ! ARRAYS
        bfv,cfv,ind,prob,wk1,wk3, &
        !PLOT
        mgmid,nplt,sdiac,sdiac2, &
        !WORKCM
        iwork1, &
        !OUTCOM
        ititle,ocvcur,obfcur,omccur, &
        !FMFCOM
        jsnout

    use tree_data, only: init_tree_data

    integer :: sim_status=0

    contains

    subroutine init_blkdata()
        ! Initialize the variant parameters and arrays
        ! TODO: This should probably be elevated to a toplevel routine.
        ! TODO: Perhaps this should initialize whatever setcmdline is doing.

#ifdef _WINDLL
        !GCC$ ATTRIBUTES STDCALL,DLLEXPORT :: init_blkdata
#endif
        call blkdat()
        call esblkd()
        call cubrds()
        call keywds()
        call svblkd()
        call dbsblkd()
        ! call fmcblk() ! TODO:Broken
        ! call dfblkd() ! TODO: Add preprocessing ifdef to enable DFB and MPB sub models
        ! call mpblkd()

        ! print *, 'JOSTD: ', jostnd

    end subroutine init_blkdata

    subroutine fvs_init(keywords_file, irtncd)
        ! Initialize an FVS run.  Extracted from fvs.f to break the execution
        ! into explicit components for improved interaction with external code.
        !
        ! Modifications include preprocessor directives to optionally exclude
        ! extranious FVS routines.

!#define xFVSREPORTS
!#define xFVSEXTENSIONS
!#define xFVSSTARTSTOP
!#define xFVSDEBUG


        implicit none

#ifdef _WINDLL
        !GCC$ ATTRIBUTES STDCALL,DLLEXPORT :: fvs_init
#endif

        !Python F2PY Interface Directives
        !f2py character(len=*),intent(in) :: keywords_file
        !f2py integer,intent(out) :: irtncd

        character(len=*), intent(in) :: keywords_file
        integer, intent(out) :: irtncd

        character(len=256) :: keywords
        character(len=100) :: fmt

        INTEGER I,IA,N,K
        REAL STAGEA,STAGEB
        LOGICAL DEBUG,LCVGO
        INTEGER IBA
        INTEGER IRSTRTCD,ISTOPDONE,ISTOPRES,lenCl

        sim_status = 0

        ! Initialize parameters and arrays
        ! TODO: This should probably be elevated to a toplevel call
        call init_blkdata()

        ! Perform Cleanup tasks to perform between runs

        ! Ensure IO files are closed
        call filclose()

        ! Close the snag output file explicitly
        close(unit=jsnout)

        ! Zero the API report arrays
        !! FIXME:
        call init_tree_data()

        ! Initialize the command line argument
        ! TODO: Accept keywords as a buffer rather than a file name
        ! TODO: Check length of path
        keywords = '--keywordfile='//adjustl(keywords_file)
        call fvssetcmdline(keywords,len_trim(keywords), irtncd)

        !
        !******************     EXECUTION BEGINS     ******************
        !
      DEBUG=.FALSE.
!-----------
!  SEE IF WE NEED TO DO SOME DEBUG.
!  NEEDED FOR STOP/RESTART DEBUG OPTION TO CONTINUE.
!-----------
      CALL DBCHK (DEBUG,'MAIN',4,0)

!     Check the current return code, if -1 the cmdLine has never been processed.

      call fvsGetRtnCode(IRTNCD)
      if (IRTNCD == -1) then
        lenCl = 0
        CALL fvsSetCmdLine(' ',lenCl,IRTNCD)
        IF (IRTNCD.NE.0) RETURN
      endif

!     FIND THE RESTART, AND BRANCH AS REQUIRED

      call fvsRestart (IRSTRTCD)
      call fvsGetRtnCode(IRTNCD)
      IF (DEBUG) WRITE(JOSTND,*) "In FVS, IRSTRTCD=",IRSTRTCD, &
                                  " IRTNCD=",IRTNCD
      if (IRTNCD.ne.0) return
      if (IRSTRTCD.lt.0) return

      if (IRSTRTCD.ge.1) then
        call fvs_grow(IRTNCD)
        return
      endif

      if (IRSTRTCD.ne.7) then
      ! if (IRSTRTCD.eq.7) goto 19
      ! if (IRSTRTCD.ge.1) goto 41
!
        ICL1=0
        LSTART = .TRUE.
        LFLAG = .TRUE.
        ICYC=0

        !INITIATE THE PROGNOSIS
        CALL INITRE
        CALL fvsGetRtnCode(IRTNCD)
        IF (IRTNCD.NE.0) RETURN

        !#ifdef FVSREPORTS
        !SEE IF WE NEED TO DO SOME DEBUG.
        CALL DBCHK (DEBUG,'MAIN',4,0)
        !#endif /* FVSREPORTS */

        !PROCESS ARRAY IY
        IF (NCYC.LE.0)  NCYC=1
        IF (NCYC.GT.MAXCYC) NCYC=MAXCYC
        DO I = 2, MAXCY1
          IF (IY(I).EQ.-1) IY(I)=10
          IY(I) = IY(I-1) + IY(I)
        ENDDO

        !ADD IN CYCLES FOR REQUESTED YEARS...BUT DO NOT EXTEND THE END
        !OR CHANGE THE BEGINNING OF THE SIMULATION.
        IF (IWORK1(1).GT.0) THEN
          DO IA=2,IWORK1(1)+1
            IF (IWORK1(IA).LE.IY(1).OR.IWORK1(IA).GE.IY(NCYC+1)) THEN
              CYCLE
            ELSE
              N=NCYC
              DO I=1,N
                IF (IWORK1(IA).GT.IY(I).AND.IWORK1(IA).LT.IY(I+1)) THEN
                  NCYC=NCYC+1
                  IF (NCYC.GT.MAXCYC) NCYC=MAXCYC
                  DO K=NCYC+1,I+2,-1
                    IY(K)=IY(K-1)
                  ENDDO
                  IY(I+1)=IWORK1(IA)
                  EXIT
                ENDIF
              ENDDO
            ENDIF
          ENDDO
        ENDIF

!#ifdef FVSEXTENSIONS
        !WRITE BUG MODEL HEADERS AND WRITE AND PROCESS OPTION LISTS
        !THE CALL TO TMOPTS MUST BE PLACED BEFORE CALL OPEXPN AS TMOPTS
        !CALLS SCHED WHICH CHANGES THE CONTENTS OF THE ARRAY IY.
        CALL MPBOPS
        CALL TMOPS
        CALL DFBSCH

        !SET UP ECON COST & REVENUE INDEXES BY SPECIES
        !CALL ECSETP PRIOR TO PROCESSING ACTIVITY SCHEDULE TO ENSURE CORRECT ECON ACTIVITY SORTING
        CALL ECSETP(IY)
!#endif /* FVSEXTENSIONS */

        !PROCESS AND LIST THE ACTIVITY SCHEDULE.
        CALL OPEXPN (JOSTND,NCYC,IY)
        CALL OPCYCL (NCYC,IY)
        IF(ITABLE(4).EQ.0)CALL OPLIST (.TRUE.,NPLT,MGMID,ITITLE)

        !SET UP INDEX POINTERS TO SPECIES SORT.
        CALL SETUP

        !CALCULATE TREES/ACRE ( = LOAD PROB )
        CALL NOTRE

!#ifdef FVSEXTENSIONS
        !WESTERN ROOT DISEASE MODEL VER. 3.0 INITIALIZATION
        CALL RDMN1 (1)

        !COMPUTE DEAD LPP/ACRE.
        CALL MPSDLP

        !COMPUTE DEAD DFB/ACRE.
        CALL DFBINV
!#endif /* FVSEXTENSIONS */

        ICYC = 1

        !SET THE OPTION POINTERS FOR THE INITIALIZATION PHASE TO
        !THE CYCLE-1 OPTIONS.
        CALL OPCSET(ICYC)

        !PROCESS STOPPOINT 7
        CALL fvsStopPoint (7,ISTOPRES)
        IF (ISTOPRES.NE.0) RETURN
        CALL fvsGetRtnCode(IRTNCD)
        IF (IRTNCD.NE.0) RETURN
        !BRANCH HERE IF RESTARTING FROM STOPCODE 7
        !19 CONTINUE
      endif

      !CALIBRATE GROWTH FUNCTIONS AND FILL GAPS
      !SDICLS IS CALLED HERE SO CROWNS WILL DUB CORRECTLY IN VARIANTS
      !USING THE WEIBULL DISTRIBUTION
      CALL SDICLS(0,0.,999.,1,SDIAC,SDIAC2,STAGEA,STAGEB,0)
      CALL CRATET

      !SET CALIBRATION AND FLAG BEST TREE RECORDS FOR ESTAB. MODEL.
      CALL ESFLTR

      ICYC = 0

      !COMPUTE INITIAL CROWN WIDTH VALUES.
      CALL CWIDTH

      !COMPUTE INITIAL VOLUME STATISTICS
      CALL VOLS

      !COMPUTE INITIAL PERCENTILE POINTS IN THE DISTRIBUTION OF
      !DIAMETERS FOR ALL VOLUME STANDARDS.  FIRST CONVERT VOLUMES TO A
      !PER ACRE REPRESENTATION (SKIP IF THERE ARE NO TREE RECORDS).
      IF (ITRN.GT.0) THEN
        DO I=1,ITRN
          CFV(I)=CFV(I)*PROB(I)
          BFV(I)=BFV(I)*PROB(I)
          WK1(I)=WK1(I)*PROB(I)
        ENDDO
      ENDIF
      CALL PCTILE(ITRN,IND,CFV,WK3,OCVCUR(7))
      CALL DIST(ITRN,OCVCUR,WK3)
      CALL PCTILE(ITRN,IND,BFV,WK3,OBFCUR(7))
      CALL DIST(ITRN,OBFCUR,WK3)
      CALL PCTILE(ITRN,IND,WK1,WK3,OMCCUR(7))
      CALL DIST(ITRN,OMCCUR,WK3)

      !IF THERE ARE TREE RECORDS, THEN: CONVERT CFV TO A PER TREE
      !REPRESENTATION.
      IF (ITRN.GT.0) THEN
        DO I=1,ITRN
          CFV(I)=CFV(I)/PROB(I)
          BFV(I)=BFV(I)/PROB(I)
          WK1(I)=WK1(I)/PROB(I)
        ENDDO
      ENDIF

      !ASSIGN THE EXAMPLE TREES TO THE OUTPUT ARRAYS.
      CALL EXTREE

!#ifdef FVSREPORTS
      !FIND OUT IF THE COVER MODEL WILL BE CALLED.
!        CALL CVGO (LCVGO)

      !CALL **CVBROW** TO COMPUTE SHRUB DENSITY AND WILDLIFE
      !BROWSE STATISTICS (MAKE THIS CALL REGARDLESS OF LCVGO).
      if(DEBUG) then
          fmt = "(' CALLING CVBROW, CYCLE=',I2)"
          write(JOSTND,fmt) ICYC
      endif
      CALL CVBROW (.FALSE.)

      !CALL **CVCNOP** TO COMPUTE CANOPY COVER STATISTICS.
      if (DEBUG) then
          fmt = "(' CALLING CVCNOP, CYCLE =',I2)"
          write (JOSTND,fmt) ICYC
      endif
      call CVCNOP(.false.)

      !CALL **STATS** TO COMPUTE STATISTICAL DESCRIPTION OF INPUT DATA.
      if (DEBUG) then
          fmt = "(' CALLING STATS, CYCLE = ',I2)"
          write(JOSTND,fmt) ICYC
      endif
      CALL STATS

      !WRITE OUTPUT HEADING FOR STAND COMP TABLE IF NOT TO BE SUPPRESSED
      !USING DELOTAB KEYWORD.
      IF (ITABLE(1) .EQ. 0) CALL GHEADS (NPLT,MGMID,JOSTND,0,ITITLE)
!#endif /* FVSREPORTS */

      !WRITE INITIAL STAND STATISTICS.  MAKE SURE THAT ICL6 IS POSITIVE
      ICL6=1
      CALL DISPLY

!#ifdef FVSSTARTSTOP
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN
!#endif /* FVSSTARTSTOP */

!#ifdef FVSREPORTS
      !IF TREE LIST OUTPUT IS REQUESTED...CALL TREE LIST PRINTER.
      CALL MISPRT
!#endif /*FVSREPORTS*/

      CALL PRTRLS_WRAP (1)

!#ifdef FVSREPORTS
      !CREATE THE INITIAL STAND VISULIZATION.
      CALL SVSTART

      !LOAD OLD VOLUME VARIABLES WITH CYCLE 0 VOLUMES
      CALL FVSSTD (1)

!#endif /*FVSREPORTS*/

      !DONE WITH DEAD TREES THAT WERE PRESENT IN THE INVENTORY. PURGE
      !THEM FROM THE LIST (VIA RESET POINTER)
      IREC2=MAXTP1

!#ifdef FVSEXTENSIONS
      !WESTERN ROOT DISEASE MODEL VER. 3.0 MODEL INITIALIZATION
      CALL RDMN1 (2)
      CALL RDPR

      !BLISTER RUST MODEL INITIALIZATION
      CALL BRSETP
      CALL BRPR
!#endif /*FVSEXTENSTIONS*/

      LFLAG = .FALSE.
      LSTART = .FALSE.

      !INITIALIZE TYPE 1 EVENT MONTITOR VARIABLES
      CALL EVTSTV(-1)

      !This is 40, the entrance to the grower loop in fvs.f

      ! Flag the simulation as initialized
      sim_status = 1
      return
    end subroutine fvs_init

    subroutine fvs_grow(irtncd)
        !Execute a FVS grow cycle.  Adapted from fvs.f
        use tree_data, only: save_tree_data,copy_tree_data,copy_mort_data,copy_cuts_data
        implicit none

#ifdef _WINDLL
        !GCC$ ATTRIBUTES STDCALL,DLLEXPORT :: fvs_grow
#endif

        !Python F2PY Interface Directives
        !f2py integer,intent(out) :: irtncd

        integer, intent(out) :: irtncd

        INTEGER I,IA,N,K,NTODO,ITODO,IACTK,IDAT,NP
        REAL STAGEA,STAGEB
        LOGICAL DEBUG,LCVGO
        INTEGER IBA
        CHARACTER*150 SYSCMD
        INTEGER MYACT(1)
        REAL PRM(1)
        DATA MYACT/100/
        INTEGER IRSTRTCD,ISTOPDONE,lenCl

        character(len=100) :: fmt

        ! Ensure the simulation is initialized or running
        if (sim_status < 1) then
            irtncd = -1
            return
        end if

        DEBUG=.FALSE.

        !fvs.f decrements the cycle during calibration
        !  and then increments it prior to entering the grower loop
        ICYC = ICYC + 1

!#ifdef FVSDEBUG
        !SIMULATE HARVEST (THINNINGS), GROWTH, MORTALITY, AND
        !ESTABLISHMENT.
        if (DEBUG) then
            fmt = "(/,' CALLING TREGRO, CYCLE = ',I4)"
            write(JOSTND,fmt) ICYC
        endif
!#endif /* FVSDEBUG */

        CALL TREGRO
        !! FIXME:
        !! call step_tregro()

!#ifdef FVSSTARTSTOP
        CALL fvsGetRtnCode(IRTNCD)
        IF (IRTNCD.NE.0) RETURN
        CALL getAmStopping (ISTOPDONE)
        IF (ISTOPDONE.NE.0) RETURN
!#endif /* FVSSTARTSTOP */

        !ASSIGN THE EXAMPLE TREES TO THE OUTPUT ARRAYS.
        CALL EXTREE

!#ifdef FVSREPORTS
!#ifdef FVSDEBUG
        !WRITE STAND STATISTICS
        if (DEBUG) then
            fmt = "(/,' CALLING DISPLY, CYCLE = ',I4)"
            write (JOSTND,fmt) ICYC
        endif
!#endif /*FVSDEBUG*/

!#endif /* FVSREPORTS */
        !!NOTE: The summary array is populated in DISPLY
        CALL DISPLY

!#ifdef FVSSTARTSTOP
        CALL fvsGetRtnCode(IRTNCD)
        IF (IRTNCD.NE.0) RETURN
!#endif /* FVSSTARTSTOP */

        !CALL RESAGE TO RESET STAND AGE.
        CALL RESAGE

!#ifdef FVSEXTENSIONS
        !DWARF MISTLETOE MODEL OUTPUT
        CALL MISPRT

        !WESTERN ROOT DISEASE MODEL VER. 3.0 OUTPUT
        CALL RDPR

        !BLISTER RUST MODEL OUTPUT
        CALL BRPR
!#endif /* FVSEXTENSIONS */

        !IF TREE LIST OUTPUT IS REQUESTED...CALL TREE LIST PRINTER.
        CALL PRTRLS_WRAP (1)
        ! call copy_tree_data()

!#ifdef FVSREPORTS
        !IF RUNNING FVSSTAND POST-PROCESSOR, CALL FILE PRINTER.
        CALL FVSSTD (1)

!#endif /* FVSREPORTS */

        ! !FIND AND RUN ANY SCHEDULED SYSTEM CALLS.
        ! CALL OPFIND (1,MYACT,NTODO)
        ! IF (NTODO.GT.0) THEN
        !     DO ITODO=1,NTODO
        !         CALL OPGET(ITODO,1,IDAT,IACTK,NP,PRM)
        !         IF (IACTK.EQ.MYACT(1)) THEN
        !             CALL OPGETC (ITODO,SYSCMD)
        !             CALL OPDONE (ITODO,IY(ICYC+1)-1)
        !             IF (SYSCMD.NE.' ') CALL SYSTEM(SYSCMD)
        !         ENDIF
        !     ENDDO
        ! ENDIF

        ! Flag simulation as running
        sim_status = 2
        return
    end subroutine fvs_grow

    subroutine fvs_end(irtncd)
        !Finalize an FVS run.  Extracted from fvs.f

        !!FIXME
        use tree_data, only: &
                save_tree_data,copy_tree_data &
                ,copy_cuts_data,copy_mort_data

        ! use contrl_mod
        ! use arrays_mod
        ! use plot_mod
        ! use workcm_mod
        ! use outcom_mod
        use globals
        implicit none

#ifdef _WINDLL
       !GCC$ ATTRIBUTES STDCALL,DLLEXPORT :: fvs_end
#endif

        !Python F2PY Interface Directives
        !f2py integer,intent(out) :: irtncd

        integer, intent(out) :: irtncd

        INTEGER I,IA,N,K,NTODO,ITODO,IACTK,IDAT,NP
        REAL STAGEA,STAGEB
        LOGICAL DEBUG,LCVGO
        INTEGER IBA
        CHARACTER*150 SYSCMD
        INTEGER MYACT(1)
        REAL PRM(1)
        DATA MYACT/100/
        INTEGER IRSTRTCD,ISTOPDONE,lenCl

        ! Bail if a simulation is not active
        if (sim_status < 1) then
            return
        end if

        DEBUG=.FALSE.

        !-----------------------------------------------------------------------
        !This code is the tail end of the "FVS" subroutine
        !It includes everything after the cycle number check and "GOTO 40"
        !-----------------------------------------------------------------------

        !signal that stopping for this stand can not continue.
        call fvsStopPoint (-1,ISTOPDONE)

        !PROJECTION COMPLETED.  SET ICL6 NEGATIVE, SAVE DENSITIES
        !FOR PRINTING, AND CALL DISPLY.
        ICYC=ICYC+1
        ICL6=-99
        ONTREM(7)=0.0
        OLDTPA=TPROB
        OLDBA=BA
        OLDAVH=AVH
        ORMSQD=RMSQD
        RELDM1=RELDEN
        CALL SDICLS(0,0.,999.,1,SDIBC,SDIBC2,STAGEA,STAGEB,0)
        SDIAC=SDIBC
        SDIAC2=SDIBC2

        ! ! Copy tree attributes for the final of the period
        ! !!FIXME
        ! if (save_tree_data) then
        ! !     write(*,*) 'Save tree list for cycle ',i,' TPA: ', sum(prob(:itrn)/grospc)
            call copy_tree_data()
        !     ! call copy_mort_data()
        ! endif

        CALL DISPLY
        CALL fvsGetRtnCode(IRTNCD)
        IF (IRTNCD.NE.0) RETURN

        IBA = 1
        CALL SSTAGE(IBA,ICYC,.FALSE.)

        !PRINT THE VISULIZATION FOR FINAL OUTPUT.
        CALL SVOUT(IY(ICYC),3,'End of projection')
        LFLAG=.TRUE.
        CALL ESOUT (LFLAG)
        CALL CVOUT
        CALL MPBOUT
        CALL DFBOUT
        CALL TMOUT
        CALL BWEOUT
!        CALL RDROUT ! RD output now handled by GENPRT 12/5/14 LD
        CALL BRROUT

        CALL GENPRT

        ! Ensure all files are closed
        call filclose

        ! Flag the simulation as terminated
        sim_status = -1
        return
    end subroutine fvs_end

end module fvs_step
