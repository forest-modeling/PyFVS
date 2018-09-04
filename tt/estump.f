      SUBROUTINE ESTUMP (JSSP,DBH,PREM,JPLOT,ISHAG)
      IMPLICIT NONE
C----------
C TT $Id$
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESHOOT.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
COMMONS
C----------
C     STORE INFORMATION FOR STUMP SPROUT SUBROUTINE.
C----------
      INTEGER*4 MDBH,IPLT,MSP
      INTEGER ISHAG,JPLOT,JSSP,I,ISSP,IDBH
      REAL PREM,DBH,DBHEND
C----------
C SPECIES ORDER FOR TETONS VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=PM,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=UJ, 12=RM, 13=BI, 14=MM, 15=NC, 16=MC, 17=OS, 18=OH
C
C VARIANT EXPANSION:
C BS USES ES EQUATIONS FROM TT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C PP USES PP EQUATIONS FROM CI
C UJ AND RM USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C MM USES MM EQUATIONS FROM IE
C NC AND OH USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM TT
C----------
      DATA MDBH/10000000/,MSP/10000/
C
      DO 10 I=1,NSPSPE
      IF(JSSP.EQ.ISPSPE(I)) GO TO 11
   10 CONTINUE
      GO TO 900
   11 CONTINUE
      ISSP=I
C
C     DETERMINE DIAMETER CLASS OF THE TREE BEING CUT.
C
      DO 100 I=1,NDBHCL-1
      DBHEND=(DBHMID(I)+DBHMID(I+1))/2.0
      IF(DBH.GT.DBHEND) GO TO 100
      IDBH=I
      GO TO 110
  100 CONTINUE
      IDBH=NDBHCL
  110 CONTINUE
      IPLT=JPLOT
      IF(IPLT.GT.9999) IPLT=9999
      ITRNRM=ITRNRM+1
C----------
C ISHOOT() IS A NUMBER COMPOSED OF DDDSSSPPPP, WHERE DDD = DBH CLASS,
C SSS = SPECIES, AND PPPP = PLOT.  DECODED IN **ESUCKR**.
C PRBREM() CONTAINS AMOUNT OF PROB REMOVED IN CUTTING TREE RECORD.
C----------
      DSTUMP(ITRNRM) = DBH
      ISHOOT(ITRNRM) = IDBH*MDBH + ISSP*MSP + IPLT
      PRBREM(ITRNRM) = PREM
      JSHAGE(ITRNRM) = ISHAG
      IF(JSSP.EQ.6)THEN
        ASTPAR = ASTPAR + PREM
        ASBAR = ASBAR + 0.0054542*PREM*DBH**2.
      ENDIF
  900 CONTINUE
      RETURN
      END
