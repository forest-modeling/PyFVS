      SUBROUTINE DBSCASE(IFORSURE)
      IMPLICIT NONE
C
C $Id$
C
C
C     PURPOSE: TO POPULATE A DATABASE WITH THE PROGNOSIS MODEL
C              OUTPUT.
C
C     INPUT: IFORSURE - 1 NEED CONNECTION, 0 CHECK IF CONNECTION IS
C                       NEEDED.
C
C     AUTH: D. GAMMEL -- SEM -- JUNE 2002
C
C---
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'DBSCOM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
      INCLUDE 'KEYCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C---

      INTEGER(SQLINTEGER_KIND),parameter:: MaxStringLen=255

      CHARACTER*2000 SQLStmtStr
      CHARACTER*10  DATO
      CHARACTER*8   TIM
      CHARACTER*(*) CFN
      CHARACTER(len=MaxStringLen) TIMESTAMP
      INTEGER ID, IFORSURE, IFORSR, I, KODE,CID

      CHARACTER*20 TABLENAME

      CHARACTER*7 VVER

      CHARACTER*2 VAR

      CALL VARVER(VVER)
      VAR=VVER(:2)
      IF(VAR.EQ.'BP' .OR. VAR.EQ.'LP' .OR. VAR.EQ.'SF' .OR.
     & VAR.EQ.'SM' .OR. VAR.EQ.'SP')VAR='CR'

C-----
C     CHECK TO SEE IF WE ARE NEEDING TO CONTINUE
C-----
      IFORSR=IFORSURE
      IF(IFORSR.EQ.0) THEN
        IF(ISUMARY.GE.1.OR.
     -     ICOMPUTE.GE.1.OR.
     -     IATRTLIST.GE.1.OR.
     -     ITREELIST.GE.1.OR.
     -     ICUTLIST.GE.1.OR.
     -     IDM1.GE.1.OR.IDM2.GE.1.OR.IDM3.GE.1.OR.
     -     IDM5.GE.1.OR.IDM6.GE.1.OR.
     -     IPOTFIRE.GE.1.OR.
     -     IFUELS.GE.1.OR.
     -     ICMRPT.GE.1.OR.
     -     ICHRPT.GE.1.OR.
     -     ISTRCLAS.GE.1.OR.
     -     IFUELC.GE.1.OR.
     -     IBURN.GE.1.OR.
     -     IMORTF.GE.1.OR.
     -     ISSUM.GE.1.OR.
     -     ISDET.GE.1.OR.
     -     ICANPR.GE.1.OR.
     -     IDWDVOL.GE.1.OR.
     -     IDWDCOV.GE.1.OR.
     -     IBMMAIN.GE.1.OR.
     -     IBMBKP.GE.1.OR.
     -     IBMTREE.GE.1.OR.
     -     IBMVOL.GE.1) IFORSR = 1
       ENDIF
       IF(IFORSR.EQ.0) RETURN

C---------
C     IF ALREADY HAVE A CURRENT CASE NUMBER, JUST BAIL
C---------
      IF (ICASE.GT.0) RETURN
C---
C     Initialize variables
C     CREATE DATETIME AND KEYFNAME
      CALL GRDTIM(DATO,TIM)
      TIMESTAMP = DATO(7:10)//'-'//DATO(1:5)//'-'//TIM
C---------
C     MAKE SURE WE HAVE AN OPEN CONNECTION
C---------
      IF(ConnHndlOut.EQ.-1) CALL DBSOPEN(DSNOUT,EnvHndlOut,
     -                             ConnHndlOut,DBMSOUT,KODE)
C---------
C     ALLOCATE A STATEMENT HANDLE
C---------
      iRet = fvsSQLAllocHandle(SQL_HANDLE_STMT,ConnHndlOut, StmtHndlOut)
      IF (iRet.NE.SQL_SUCCESS .AND. iRet.NE. SQL_SUCCESS_WITH_INFO) THEN
        ICOMPUTE  = 0
        ISUMARY   = 0
        IATRTLIST = 0
        ITREELIST = 0
        ICUTLIST  = 0
        IDM1      = 0
        IDM2      = 0
        IDM3      = 0
        IDM5      = 0
        IDM6      = 0
        IPOTFIRE  = 0
        IFUELS    = 0
        ICMRPT    = 0
        ICHRPT    = 0
        ISTRCLAS  = 0
        IFUELC    = 0
        IBURN     = 0
        IMORTF    = 0
        ISSUM     = 0
        ISDET     = 0
        ICANPR    = 0
        IDWDVOL   = 0
        IDWDCOV   = 0
        IBMMAIN   = 0
        IBMBKP    = 0
        IBMTREE   = 0
        IBMVOL    = 0
C
        CALL  DBSDIAGS(SQL_HANDLE_DBC,ConnHndlOut,
     -                 'DBSRun:Connecting to DSN')
        GOTO 200
      ENDIF

C---------
C     MAKE SURE WE HAVE AN OPEN CONNECTION
C---------
      IF(ConnHndlOut.EQ.-1) CALL DBSOPEN(DSNOUT,EnvHndlOut,
     -                                 ConnHndlOut,DBMSOUT,KODE)
C---------
C     CHECK TO SEE IF THE FVS_Cases TABLE EXISTS IN DATBASE
C---------
      IF(TRIM(DBMSOUT).EQ."EXCEL") THEN
        TABLENAME = '[FVS_Cases$]'
      ELSEIF(TRIM(DBMSOUT).EQ."ORACLE") THEN
        TABLENAME = '"FVS_Cases"'
      ELSE
        TABLENAME = 'FVS_Cases'
      ENDIF
      SQLStmtStr= 'SELECT * FROM ' // TABLENAME

      iRet = fvsSQLExecDirect(StmtHndlOut,trim(SQLStmtStr),
     -                int(len_trim(SQLStmtStr),SQLINTEGER_KIND))
      IF(.NOT.(iRet.EQ.SQL_SUCCESS .OR.
     -    iRet.EQ.SQL_SUCCESS_WITH_INFO)) THEN
        !Close Cursor
        iRet = fvsSQLCloseCursor(StmtHndlOut)
        IF(TRIM(DBMSOUT).EQ."ACCESS") THEN
          SQLStmtStr="CREATE TABLE FVS_Cases("//
     -              "CaseID int primary key,"//
     -              "Stand_CN Text null,"//
     -              "StandID Text null,"//
     -              "MgmtID Text null,"//
     -              "KeywordFile Text null,"//
     -              "SamplingWt double null,"//
     -              "Variant Text null,"//
     -              "RunDateTime Text null)"
        ELSEIF(TRIM(DBMSOUT).EQ."EXCEL") THEN
          SQLStmtStr="CREATE TABLE FVS_Cases("//
     -              "CaseID INT,"//
     -              "Stand_CN Text null,"//
     -              "StandID Text,"//
     -              "MgmtID Text,"//
     -              "KeywordFile Text,"//
     -              "SamplingWt Number,"//
     -              "Variant Text,"//
     -              "RunDateTime Text);"
        ELSE
          SQLStmtStr="CREATE TABLE "//TABLENAME//
     -              " (CaseID int primary key,"//
     -              "Stand_CN char(40) null,"//
     -              "StandID char(26) null,"//
     -              "MgmtID char(4) null,"//
     -              "KeywordFile char(50) null,"//
     -              "SamplingWt real  null,"//
     -              "Variant char(2) null,"//
     -              "RunDateTime char(19) null)"
        ENDIF

        iRet = fvsSQLExecDirect(StmtHndlOut,trim(SQLStmtStr),
     -                int(len_trim(SQLStmtStr),SQLINTEGER_KIND))
        CALL DBSDIAGS(SQL_HANDLE_STMT,StmtHndlOut,
     -       'DBSCase:Creating Table: '//trim(SQLStmtStr))
        !Close Cursor
        iRet = fvsSQLCloseCursor(StmtHndlOut)

        ICASE = 0
      ENDIF
C---------
C     CREATE ENTRY FROM DATA FOR FVSRUN TABLE
C---------
      IF(ICASE.EQ.-1) THEN
        CALL DBSGETID(TABLENAME,'CaseID',ID)
        ICASE = ID
      ENDIF
      ICASE = ICASE + 1
C----------
C           MAKE SURE WE DO NOT EXCEED THE MAX TABLE SIZE IN EXCEL
C----------
      IF (KEYFNAME.EQ.' ') KEYFNAME='Unknown'
      IF(ICASE.GE.65535.AND.TRIM(DBMSOUT).EQ.'EXCEL') GOTO 100
      WRITE(SQLStmtStr,*)'INSERT INTO ',trim(TABLENAME),
     - ' (CaseID,Stand_CN,StandID,MgmtID,KeywordFile,SamplingWt,',
     - 'Variant,RunDateTime) VALUES(',ICASE,',',
     - CHAR(39), TRIM(DBCN),   CHAR(39),',',
     - CHAR(39), TRIM(NPLT),   CHAR(39),',',
     - CHAR(39), TRIM(MGMID),  CHAR(39),',',
     - CHAR(39),TRIM(KEYFNAME),CHAR(39),','
     -            ,SAMWT,',',
     - CHAR(39),VAR,CHAR(39),',',
     - CHAR(39),TRIM(TIMESTAMP),CHAR(39), ')'


  100 CONTINUE
      !Close Cursor
      iRet = fvsSQLCloseCursor(StmtHndlOut)

      !Execute Query
      iRet = fvsSQLExecDirect(StmtHndlOut,trim(SQLStmtStr),
     -                int(len_trim(SQLStmtStr),SQLINTEGER_KIND))
      CALL DBSDIAGS(SQL_HANDLE_STMT,StmtHndlOut,
     >              'DBSCase:Inserting Row: '//trim(SQLStmtStr))

      !Release statement handle
  200 CONTINUE
      iRet = fvsSQLFreeHandle(SQL_HANDLE_STMT, StmtHndlOut)
      RETURN

C
C     CALLED BY FILOPN: ENTRY TO SAVE THE KEYWORD FILE NAME AND TO SET
C                       THE DEFAULT DBS CONNECTIONS
C
      ENTRY DBSVKFN (CFN)
      I=LEN_TRIM(CFN)
      IF (I.GT.LEN(KEYFNAME)) THEN
         KEYFNAME=CFN(1:4)//'...'//CFN(I+8-LEN(KEYFNAME):)
      ELSE
         KEYFNAME = CFN
      ENDIF
      RETURN
C
C======================================================================
C     ENTRY FOR WWPBM, FETCHING ICASE
C    (NOTE: THE WWPBM NEEDS TO KNOW AND SAVE (INTERNALLY) ICASE, BECAUSE
C     IT IS DOING ITS DB-WRITING FROM WITHIN ITS OWN INTERNAL STAND LOOP
C
      ENTRY DBSWW2(CID)
      CID=ICASE
      RETURN
C======================================================================
      END

