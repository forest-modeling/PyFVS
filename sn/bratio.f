      FUNCTION BRATIO(IS,D,H)
      IMPLICIT NONE
C----------
C SN $Id$
C----------
C  FUNCTION TO COMPUTE BARK RATIOS.  THIS ROUTINE IS VARIANT SPECIFIC
C  AND EACH VARIANT USES ONE OR MORE OF THE ARGUMENTS PASSED TO IT.
C  COFFICIENTS ARE FROM CLARK(RPSE, 1991:TABLE9, PAGE54) FOR THE LINEAR
C  EQUATION DIB= A + B*DBH
C
C  SPECIES LIST FOR SOUTHERN VARIANT.
C  1=FR,2=JU,3=PI,4=PU,5=SP,6=SA,7=SR,8=LL,9=TM,10=PP,11=PD,12=WP,
C  13=LP,14=VP,15=BY,16=PC,17=HM,18=FM,19=BE,20=RM,21=SV,22=SM,
C  23=BU,24=BB,25=SB,26=AH,27=HI,28=CA,29=HB,30=RD,31=DW,32=PS,
C  33=AB,34=AS,35=WA,36=BA,37=GA,38=HL,39=LB,40=HA,41=HY,42=BN,
C  43=WN,44=SU,45=YP,46=MG,47=CT,48=MS,49=MV,50=ML,51=AP,52=MB,
C  53=WT,54=BG,55=TS,56=HH,57=SD,58=RA,59=SY,60=CW,61=BT,62=BC,
C  63=WO,64=SO,65=SK,66=CB,67=TO,68=LK,69=OV,70=BJ,71=SN,72=CK
C  73=WK,74=CO,75=RO,76=QS,77=PO,78=BO,79=LO,80=BK,81=WI,82=SS,
C  83=BW,84=EL,85=WE,86=AE,87=RL,88=OS,89=OH,90=OT
C
C      VARIABLES
C      BARKC(I,J) - I1= COEFF A, I2= COEF B,
C                   ONE RECORD (J) FOR EACH SPECIES (IS)
C      D          - DBH
C      DIB        - DIAM. INSIDE BARK
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C----------
C
C
COMMONS
      INTEGER IS,J,I
      REAL H,D,BRATIO,DIB,BARKC(2,90)
      REAL RDANUW
C
      DATA ((BARKC(I,J),I= 1,2),J= 1,15)/
     &  0.05119,0.89372,
     & -0.27012,0.97546,
     & -0.17289,0.91572,
     & -0.39956,0.95183,
     & -0.44121,0.93045,
     & -0.55073,0.91887,
     & -0.13301,0.93755,
     & -0.45903,0.92746,
     &  0.05119,0.89372,
     & -0.58808,0.91852,
     & -0.51271,0.90245,
     & -0.31608,0.92054,
     & -0.48140,0.91413,
     & -0.31137,0.95011,
     & -0.27012,0.97546/
      DATA ((BARKC(I,J),I= 1,2),J= 16,30)/
     & -0.94204,0.96735,
     & -0.04931,0.92272,
     & -0.09800,0.94646,
     & -0.09800,0.94646,
     & -0.09800,0.94646,
     & -0.09800,0.94646,
     & -0.09800,0.94646,
     & -0.35332,0.95955,
     &  0.21790,0.92290,
     &  0.21790,0.92290,
     & -0.13040,0.97071,
     & -0.60912,0.94347,
     & -0.33014,0.94215,
     & -0.18338,0.95768,
     & -0.33014,0.94215/
      DATA ((BARKC(I,J),I= 1,2),J= 31,45)/
     & -0.33014,0.94215,
     & -0.42001,0.94264,
     & -0.13040,0.97071,
     & -0.34316,0.93964,
     & -0.48735,0.93847,
     & -0.25063,0.94349,
     & -0.34316,0.93964,
     & -0.42001,0.94264,
     & -0.33014,0.94215,
     & -0.33014,0.94215,
     & -0.33014,0.94215,
     & -0.42001,0.94264,
     & -0.42001,0.94264,
     & -0.39271,0.95997,
     & -0.22976,0.92408/
      DATA ((BARKC(I,J),I= 1,2),J= 46,60)/
     & -0.21140,0.94461,
     & -0.21140,0.94461,
     & -0.21140,0.94461,
     & -0.17978,0.92381,
     & -0.21140,0.94461,
     & -0.33014,0.94215,
     & -0.33014,0.94215,
     & -0.38140,0.97327,
     &  0.19899,0.88941,
     & -0.15231,0.93442,
     & -0.42001,0.94264,
     & -0.25063,0.94349,
     & -0.33014,0.94215,
     & -0.09192,0.96411,
     & -0.25063,0.94349/
      DATA ((BARKC(I,J),I= 1,2),J= 61,75)/
     & -0.25063,0.94349,
     & -0.12958,0.94152,
     & -0.24096,0.93789,
     & -0.40860,0.94613,
     & -0.42141,0.93008,
     & -0.21801,0.93540,
     & -0.61021,0.95803,
     & -0.04612,0.93127,
     & -0.37973,0.94380,
     & -0.61021,0.95803,
     & -0.49699,0.94832,
     & -0.34225,0.93494,
     & -0.30330,0.95826,
     & -0.43197,0.92120,
     & -0.52266,0.95215/
      DATA ((BARKC(I,J),I= 1,2),J= 76,90)/
     & -0.61021,0.95803,
     & -0.26493,0.91899,
     & -0.70754,0.94821,
     & -0.70754,0.94821,
     & -0.37166,0.89193,
     & -0.25063,0.94349,
     & -0.25063,0.94349,
     & -0.35979,0.95322,
     & -0.42027,0.96305,
     & -0.42027,0.96305,
     & -0.42027,0.96305,
     & -0.42027,0.96305,
     & -0.38344,0.91915,
     & -0.33014,0.94215,
     & -0.25063,0.94349/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      RDANUW = H
C
C----------
C MODEL TYPE FROM CLARK
C----------
      IF (D .GT. 0) THEN 
        IF(IFOR .EQ. 20)THEN
          IF(IS .EQ. 5)THEN
            DIB= 0.1713 + 0.87459*D
          ELSEIF(IS .EQ. 6)THEN
            DIB= -0.26207 + 0.87347 * D
          ELSEIF(IS .EQ. 8)THEN
            DIB= -0.43439 + 0.91382 * D
          ELSEIF(IS .EQ. 11)THEN
            DIB= -0.62033 + 0.91645 * D
          ELSEIF(IS .EQ. 13)THEN
            DIB= -0.4671 + 0.90198 * D
          ELSE
            DIB=BARKC(1,IS) + BARKC(2,IS)*D
          ENDIF
        ELSE
          DIB=BARKC(1,IS) + BARKC(2,IS)*D
        ENDIF
        BRATIO=DIB/D
      ELSE
        BRATIO = 0.99
      ENDIF
C
      IF(BRATIO .GT. 0.99) BRATIO= 0.99
      IF(BRATIO .LT. 0.80) BRATIO= 0.80
C
      RETURN
      END
C
