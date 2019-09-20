      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C CANADA-ON $Id$
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
C     CODES 902-913 ARE FROM THE LS VARIANT
C     CODES 915 & 916 ARE FOR ONTARIO
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
      INTEGER JFOR(11),KFOR(11),NUMFOR,I
      LOGICAL USEIGL, FORFOUND
      DATA JFOR/902,903,904,906,907,909,910,913,915,916,924/
      DATA NUMFOR/11/
      DATA KFOR/11*1/

      USEIGL = .TRUE.
      FORFOUND = .FALSE.


      SELECT CASE (KODFOR)

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
          IF (.NOT. FORFOUND) THEN
            CALL ERRGRO (.TRUE.,3)
            WRITE(JOSTND,11) JFOR(IFOR)
   11       FORMAT(/,'********',T12,'FOREST CODE USED IN THIS ',
     &      'PROJECTION IS',I4)
            USEIGL = .FALSE.
          ENDIF

      END SELECT
      
      C     FOREST MAPPING CORRECTION
      SELECT CASE (IFOR)
        CASE (11)
          WRITE(JOSTND,21)
   21     FORMAT(/,'********',T12,'MANISTEE NF (924) BEING MAPPED TO ',
     &    'HURON-MANISTEE (904) FOR FURTHER PROCESSING.')
          IFOR = 3        
      END SELECT
      
C     SET THE IGL VARIABLE ONLY IF DEFAULT FOREST IS USED
C     GEOGRAPHIC LOCATION CODE: 1=NORTH, 2=CENTRAL, 3=SOUTH
C     USED TO SET SOME EQUATIONS IN REGENERATION AND PERHAPS
C     HEIGHT-DIAMETER IN DIFFERENT VARIANTS.
      IF (USEIGL) IGL = KFOR(IFOR)      

      KODFOR=JFOR(IFOR)

C----------
C  SET DEFAULT TLAT, TLONG, AND ELEVATION VALUES, BY FOREST
C  = use US SUPERIOR for now
C----------
      SELECT CASE(KODFOR)
      CASE(915)
        IF(TLAT.EQ.0) TLAT=46.78
        IF(TLONG.EQ.0)TLONG=92.11
        IF(ELEV.EQ.0) ELEV=16.
      CASE(916)
        IF(TLAT.EQ.0) TLAT=46.78
        IF(TLONG.EQ.0)TLONG=92.11
        IF(ELEV.EQ.0) ELEV=16.
        
        
      END SELECT
      RETURN
      END
