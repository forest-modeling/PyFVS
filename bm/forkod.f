      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C  **FORKOD--BM   DATE OF LAST REVISION:  02/20/08
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
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
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
C  ------------------------
C  NATIONAL FORESTS:
C  604 = MALHEUR
C  607 = OCHOCO
C  614 = UMATILLA
C  616 = WALLOWA-WHITMAN
C  619 = WHITMAN                         (MAPPED TO WALLOWA-WHITMAN)
C  ------------------------
C  RESERVATION PSUEDO CODES:
C  8117 = UMATILLA RESERVATION           (MAPPED TO UMATILLA  614)
C  ------------------------
      INTEGER JFOR(7),KFOR(7),NUMFOR,I
      LOGICAL USEIGL, FORFOUND
      DATA JFOR/604,607,614,616,619, 0, 0 /, NUMFOR /5/
      DATA KFOR/1,1,1,1,1,1,1 /

      USEIGL = .TRUE.
      FORFOUND = .FALSE.
      
 
      SELECT CASE (KODFOR)

C       CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE
        CASE (8117)
          WRITE(JOSTND,60)
   60     FORMAT(/,'********',T12,'UMATILLA RESERVATION (8117)',
     &    ' BEING MAPPED TO UMATILLA NF (614) FOR FURTHER PROCESSING!')
          IFOR = 3
C       END CROSSWALK FOR RESERVATION PSUEDO CODES & LOCATION CODE


        CASE DEFAULT

C         CONFIRMS THAT KODFOR IS AN ACCEPTED FVS LOCATION CODE
C         FOR THIS VARIANT FOUND IN DATA ARRAY JFOR
          DO 10 I=1,NUMFOR
            IF (KODFOR .EQ. JFOR(I)) THEN
              IFOR = I
              FORFOUND = .TRUE.
              EXIT
            ENDIF
   10     CONTINUE

C         LOCATION CODE ERROR TRAP
          IF ( .NOT. FORFOUND ) THEN  
          	CALL ERRGRO (.TRUE.,3)         
            WRITE(JOSTND,11) JFOR(IFOR)
   11       FORMAT(/,'********',T12,'FOREST CODE USED IN THIS ',
     &      'PROJECTION IS',I4)
          ENDIF

      END SELECT


C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (5)
          WRITE(JOSTND,21)
   21     FORMAT(/,'********',T12,'WHITMAN NF (619) BEING MAPPED TO ',
     &    'WALLOWA-WHITMAN (616) FOR FURTHER PROCESSING.')
          IFOR = 4
      END SELECT

C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED.
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)

      KODFOR=JFOR(IFOR)
      RETURN
      END
