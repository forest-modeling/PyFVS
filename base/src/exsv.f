      SUBROUTINE EXSV
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     STAND VISUALIZATION EXTERNAL REFERENCES
C     N.L.CROOKSTON -- RMRS MOSCOW -- MARCH 1998
C     A.H.DALLMANN -- RMRS MOSCOW -- JANUARY 2000
C
      INTEGER I1,I2,I
      LOGICAL L(*)
      REAL A(*),A1(*),A2(*)
      CHARACTER*(*) C
      INTEGER IDX(*)
C
      ENTRY SVCMP1
      RETURN
      ENTRY SVCMP2(I1,I2)
      RETURN
      ENTRY SVCMP3
      RETURN
      ENTRY SVCUTS(I,A,A1,A2)
      RETURN
      ENTRY SVMORT (I1, A, I2)
      RETURN
      ENTRY SVOUT(I1,I2,C)
      RETURN
      ENTRY SVTOBJ(I1)
      RETURN
      ENTRY SVINIT
      RETURN
      ENTRY SVKEY(C,L,A)
      RETURN
      ENTRY SVSTART
      RETURN
      ENTRY SVTDEL(IDX,I2)
      RETURN
      ENTRY SVTRIP(I1,I2)
      RETURN
      ENTRY SVESTB(I1)
      RETURN
      END




