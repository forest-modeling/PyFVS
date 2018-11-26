      SUBROUTINE REVISE (VAR,REV)
      IMPLICIT NONE
C----------
C VBASE $Id$
C----------
C  **REVISE--BASE  DATE OF LAST REVISION:  06/01/18
C  (DON'T CHANGE THIS DATE UNLESS THE SUBROUTINE LOGIC CHANGES.)
C----------
C  THIS ROUTINE PROVIDES THE LATEST REVISION DATE FOR EACH VARIANT
C  WHICH GETS PRINTED IN THE MAIN HEADER ON THE OUTPUT.
C  CALLED FROM GROHED, FILOPN, SUMHED, SUMOUT, ECVOLS, PRTRLS,
C  AND DGDRIV.
C----------
      CHARACTER VAR*2,REV*10
C
      SELECT CASE (VAR)
C----------
C SOUTHEAST ALASKA / COASTAL BRITISH COLUMBIA
C----------
        CASE('AK')
        REV = '20181126'
C----------
C BLUE MOUNTAINS
C----------
        CASE('BM')
        REV = '20181126'
C----------
C INLAND CALIFORNIA / SOUTHERN CASCADES
C----------
        CASE('CA')
        REV = '20181126'
C----------
C CENTRAL IDAHO
C----------
        CASE('CI')
        REV = '20181126'
C----------
C CENTRAL ROCKIES
C----------
        CASE('CR')
        REV = '20181126'
C----------
C CENTRAL STATES
C----------
        CASE('CS')
        REV = '20181126'
C----------
C EAST CASCADES
C----------
        CASE('EC')
        REV = '20181126'
C----------
C EASTERN MONTANA
C----------
        CASE('EM')
        REV = '20181126'
C----------
C INLAND EMPIRE (AKA NI23)
C----------
        CASE('IE')
        REV = '20181126'
C----------
C KOOTENAI / KANIKSU / TALLY LAKE
C----------
        CASE('KT')
        REV = '20181126'
C----------
C LAKE STATES
C----------
        CASE('LS')
        REV = '20181126'
C----------
C KLAMATH MOUNTAINS
C----------
        CASE('NC')
        REV = '20181126'
C----------
C NORTHEAST STATES
C----------
        CASE('NE')
        REV = '20181126'
C----------
C SOUTHWEST OREGON ORGANON
C----------
        CASE('OC')
        REV = '20181126'
C----------
C NORTHWEST OREGON ORGANON
C----------
        CASE('OP')
        REV = '20181126'
C----------
C PACIFIC NORTHWEST
C----------
        CASE('PN')
        REV = '20181126'
C----------
C SOUTHERN
C----------
        CASE('SN')
        REV = '20181126'
C----------
C SOUTH CENTRAL OREGON / NORTHEAST CALIFORNIA
C----------
        CASE('SO')
        REV = '20181126'
C----------
C TETONS
C----------
        CASE('TT')
        REV = '20181126'
C----------
C UTAH
C----------
        CASE('UT')
        REV = '20181126'
C----------
C WEST CASCADES
C----------
        CASE('WC')
        REV = '20181126'
C----------
C WESTERN SIERRA NEVADA
C----------
        CASE('WS')
        REV = '20181126'
C----------
C ANY OTHER VARIANT
C----------
        CASE DEFAULT
        REV = '20181126'
C
      END SELECT
C
      RETURN
      END
