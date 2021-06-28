      SUBROUTINE ESTPP (VAL,IFT,DEBUG,JOSTND,TPP)
      IMPLICIT NONE
C----------
C AK $Id$
C----------
C     PREDICTS THE NUMBER OF NATURAL REGENERATING TREES
C     TO ESTABLISH PER PLOT
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
      INCLUDE 'ESCOM2.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
COMMONS
C
C----------
C  VARIABLE DEFINITIONS:
C----------
C
C  VAL      -- RANDOM NUMBER DRAW
C  IFT      -- STAND FOREST TYPE CATEGORY WHERE:
C                1 = 122
C                2 = 125
C                3 = 270
C                4 = 271
C                5 = 281
C                6 = 301
C                7 = 304
C                8 = 305
C                9 = 703
C               10 = 901
C               11 = 902
C               12 = 904
C               13 = 911
C               14 = OTHER (NO ADVANCED REGENERATION)
C  BB AND BBIFT   -- WEIBULL SCALE PARAMETER BY FOREST TYPE
C  CC AND CCIFT   -- WEIBULL SHAPE PARAMETER BY FOREST TYPE
C  TPP      -- NUMBER OF TREES PER STOCKED PLOT
C
C----------
C  VARIABLE DECLARATIONS:
C----------
C
      REAL BB,CC,TPP,VAL,BBIFT(14),CCIFT(14)
      INTEGER IFT,JOSTND
      LOGICAL DEBUG

      DATA BBIFT / 
     & 5.617512, 13.273635, 4.291578, 9.770818, 9.452008, 8.075209,
     & 9.635466,  3.632153, 3.794353, 6.107958, 5.251271, 5.617512,
     & 2.695103,  5.617512 /

      DATA CCIFT /    
     & 1.213626, 1.405827, 1.442975, 1.496351, 1.523877, 1.274965, 
     & 1.505655, 1.414683, 1.462014, 1.399479, 1.268050, 1.213626, 
     & 1.709675, 1.213626 /

C     CALCULATE TREES PER STOCKED PLOT.
C     LP,YC,RC FOREST TYPES: USE WESTERN HEMLOCK FOREST TYPE WEIBULL
C     DISTRIBUTION.
      BB = BBIFT(IFT)
      CC = CCIFT(IFT)
      TPP = BB * (-1*ALOG(1-VAL))**(1/CC)

C     SET TO 0 IF FOREST TYPE IS OTHER (14)
      IF(IFT.EQ.14)TPP=0.
      IF(DEBUG)WRITE(JOSTND,*)' IN ESTPP', ' IFT=',IFT,' VAL=', VAL,
     &  ' TPP=',TPP
      RETURN
      END
