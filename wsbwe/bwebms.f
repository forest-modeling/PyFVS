      SUBROUTINE BWEBMS (TRFBMS,ICVOPT)
      IMPLICIT NONE
C----------
C WSBWE $Id$
C----------
C
C     COMPUTES FOLIAGE BIOMASS FOR INDIVIDUAL TREES.
C
C     PART OF THE WESTERN SPRUCE BUDWORM MODEL/PROGNOSIS LINKAGE CODE.
C
C     FOLIAGE BIOMASS RELATIONSHIPS ARE DOCUMENTED IN :
C
C     MOEUR, MELINDA. 1981. CROWN WIDTH AND FOLIAGE WEIGHT OF NORTHERN
C       ROCKY MOUNTAIN CONIFERS.  USDA FOR. SERV. RES. PAP. INT-283.
C
C     THIS ROUTINE WAS CRBMS IN THE ORGINAL VERSION OF THE COVER
C     MODELS CODED BY M. MOEUR.  CROOKSTON LIFTED HER WORK FOR USE HERE
C     IN THE BUDWORM MODELS.
c
c     minor changes by K.Sheehan to remove LBWDEB 7/96
C
C     Updated from BWBMS to BWEBMS 1998.
C     Minor changes by D.Graham to establish varients 8/10/99
C
C     CALLED FROM :
C
C       BWESIT - CREATE A BUDWORM STAND FROM A PROGNOSIS STAND.
C
C     PARAMETERS :
C
C       TRFBMS - ARRAY OF TREE FOLIAGE BIOMASSES.
C       ICVOPT - BIOMASS CALCULATION OPTION (SEE BELOW).
C       JOUT   - LOGICAL UNIT NUMBER FOR OUTPUT REPORTS.
C
C Revision History:
C  14-JUL-2010 Lance R. David (FMSC)
C     Added IMPLICIT NONE and declared variables as needed.
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C----------
C  DECLARATIONS AND DIMENSIONS FOR INTERNAL VARIABLES
C----------
C  AGE     -- TREE AGE
C  BINT11  -- ARRAY OF INTERCEPTS FOR FOLIAGE BIOMASS FUNCTION
C             FOR TREES LESS THAN 3.5 INCHES, MODEL 1
C  BCL11   -- ARRAY OF COEFFICIENTS FOR CROWN LENGTH TERM FOR TREES
C             LESS THAN 3.5 INCHES, MODEL 1
C  BINT12  -- ARRAY OF INTERCEPTS FOR TREES LESS THAN 3.5 INCHES,
C             MODEL 2
C  BCL12   -- ARRAY OF COEFFICIENTS FOR CROWN LENGTH TERM FOR
C             TREES .LT. 3.5 INCHES, MODEL 2
C  BINT2   -- ARRAY OF INTERCEPTS FOR FOLIAGE BIOMASS FUNCTION
C             FOR TREES 3.5 INCHES AND LARGER, MODELS 1 AND 2
C  CL      -- CROWN LENGTH
C  IBIOMP  -- SPECIES INDEX ARRAY THAT MAPS PROGNOSIS SPECIES TO THE
C             FOLIAGE BIOMASS EQUATIONS.
C  ICVOPT  -- EQUATION OPTION NUMBER
C  DDS     -- DELTA DIAMETER SQUARED (CHANGE IN SQUARED DIAMETER)
C  RD      -- RELATIVE DIAMETER
C  TRFBMS  -- PREDICTED FOLIAGE BIOMASS IN POUNDS
C----------

      INTEGER I, IBIOMP(MAXSP), ICVOPT, ISPI
      REAL BINT11(11), BCL11(11), BINT12(11), BCL12(11), BINT2(11),
     &     TRFBMS(MAXTRE)
      REAL AGE, ALNTPA, CL, D, DDS, H, RD

C----------
C     DATA STATEMENTS
C----------
C     THE ARRAYS BINT11, BCL11, BINT12, BCL12, AND BINT2 REPRESENT
C     VALUES FOR THE FOLLOWING 11 SPECIES:
C       1   2   3   4   5   6   7   8   9  10  11
C      WP  WL  DF  GF  WH  RC  LP  ES  AF  PP  --
C
      DATA BINT11 /-2.15894, -5.02156, -2.30430, -2.78090,
     &             -4.22701, -2.64034, -3.38394, -3.30673,
     &             -2.03919, -3.02050, -2.81317 /,
     &     BCL11 /  1.48969, 2.31835, 1.52896, 1.90272,
     &              2.22534, 1.69973, 1.96060, 2.27613,
     &              1.64942, 1.88712, 1.47513 /
      DATA BINT12 /-1.94951, -4.73762, -2.05828, -2.43200,
     &             -4.17456, -2.24876, -3.13488, -2.93508,
     &             -1.60998, -2.74410, -2.63387 /,
     &     BCL12 /  1.22023, 1.98479, 1.25837, 1.60270,
     &              2.00749, 1.37600, 1.62368, 1.96125,
     &              1.32649, 1.58171, 1.35092 /
      DATA BINT2 /2.666072, 1.756537, 2.705866, 3.115084,
     &            2.654572, 3.059351, 2.622505, 3.300852,
     &            3.060169, 2.452492, 2.622505 /

C
C     THE ARRAY IBIOMP IS AN INDEX ARRAY WHICH MAPS THE PROGNOSIS
C     SPECIES TO THE SPECIES REPRESENTED IN THE FOLIAGE BIOMASS
C     EQUATIONS IN THIS SUBROUTINE.
C
C**** IBIOMP IS SET FOR THE FOLLOWING VARIENTS
C     NI            WP  WL  DF  GF  WH  RC  LP  ES  AF  PP  OT
      DATA IBIOMP /  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11 /
C
C     INSURE THAT THE MODEL RUNS IF THERE ARE NO TREES IN THE
C     TREE LIST.
C
      IF (ITRN.LE.0) GOTO 9000
C----------
C  ENTER TREE LOOP
C----------
C
C     COMPUTE THE LOG OF THE TREES PER ACRE.
C
      ALNTPA=ALOG(OLDTPA)
      DO 110 I = 1,ITRN
      D = DBH(I)
      ISPI = IBIOMP(ISP(I))
      H = HT(I)
      CL = (ICR(I)*H)/100.
      RD = D/ORMSQD
      DDS = (2*D*DG(I) + DG(I)**2)/FINT
C----------
C  COMPUTE TREE AGE
C----------
      AGE = FLOAT (ITRE(I) + IY(ICYC+1) - IY(1))
C----------
C  BRANCH ON MODEL OPTION
C----------
C  ICVOPT = 1  GO TO FOLIAGE WEIGHT FUNCTIONS CONTAINING AGE
C              AS AN INDEPENDENT VARIABLE
C  ICVOPT = 2  GO TO FOLIAGE WEIGHT FUNCTIONS CONTAINING DELTA
C              DIAMETER SQUARED (DDS) FOR TREES .GE. 3.5 INCHES,
C              AND HEIGHT FOR TREES .LT. 3.5 INCHES IN PLACE OF
C              AGE AS INDEPENDENT VARIABLES
C----------
      GO TO (5, 15),ICVOPT
C===============================================================
C          MODEL OPTION 1     (USES TREE AGE)
C===============================================================
C  BRANCH ON DBH
C----------
    5 IF (D .LT. 3.5) GO TO 10
C----------
C  COMPUTE FOLIAGE BIOMASS FOR TREES 3.5 INCHES AND LARGER
C----------
      TRFBMS(I) = EXP (BINT2(ISPI) + 2.086241*ALOG(D) - 1.077047*ALOG(H)
     &         + 0.690825*ALOG(CL) - 0.308847*ALOG(AGE) - 0.142069
     &         *ALNTPA + 0.399244*ALOG(RD))
C----------
C  CORRECT ESTIMATE FOR NEGATIVE BIAS.
C  BIAS ADJUSTMENT = EXP(.5*MSE) = EXP(.5*.13301)
C----------
      TRFBMS(I) = TRFBMS(I)*1.06877
      GO TO 100
C----------
C  COMPUTE FOLIAGE BIOMASS FOR TREES LESS THAN 3.5 INCHES
C----------
   10 TRFBMS(I) = EXP (BINT11(ISPI) + 0.22823*ALOG(AGE)
     &         + BCL11(ISPI)*ALOG(CL) - 0.13550*ALNTPA)
C----------
C  CORRECT ESTIMATE FOR NEGATIVE BIAS
C  BIAS ADJUSTMENT = EXP(.5*MSE) = EXP(.5*.23751)
C----------
      TRFBMS(I) = TRFBMS(I)*1.12609
      GO TO 100
C===============================================================
C          MODEL OPTION 2     (USES DDS)
C===============================================================
C  BRANCH ON DBH
C----------
   15 IF (D .LT. 3.5) GO TO 20
C----------
C  COMPUTE FOLIAGE BIOMASS FOR TREES 3.5 INCHES AND LARGER
C----------
      TRFBMS(I) = EXP (BINT2(ISPI) + 1.468547*ALOG(D) +
     &         0.308847*ALOG(DDS) - 1.077047*ALOG(H)
     &         + 0.690825*ALOG(CL) - 0.142096*ALNTPA
     &         + 0.399244*ALOG(RD))
C----------
C  NO NEGATIVE BIAS CORRECTION APPLIED, BECAUSE THERE IS
C  NO ESTIMATE OF MSE FOR THIS EQUATION.
C----------
      GO TO 100
C----------
C  COMPUTE FOLIAGE BIOMASS FOR TREES LESS THAN 3.5 INCHES
C----------
   20 TRFBMS(I) = EXP (BINT12(ISPI) + BCL12(ISPI)*ALOG(CL)
     &          - 0.12975*ALNTPA + 0.40350*ALOG(H))
C----------
C  CORRECT FOR NEGATIVE BIAS.
C  BIAS ADJUSTMENT IS EXP(.5*MSE) = EXP (.5*.24759)
C----------
      TRFBMS(I) = TRFBMS(I) * 1.13178
C
  100 CONTINUE
  110 CONTINUE
 9000 CONTINUE
      RETURN
      END