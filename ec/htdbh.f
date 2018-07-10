      SUBROUTINE HTDBH (IFORXX,ISPC,D,H,MODE)
      IMPLICIT NONE
C----------
C EC $Id$
C----------
C  THIS SUBROUTINE CONTAINS THE DEFAULT HEIGHT-DIAMETER RELATIONSHIPS
C  FROM THE INVENTORY DATA.  IT IS CALLED FROM CRATET TO DUB MISSING
C  HEIGHTS, AND FROM REGENT TO ESTIMATE DIAMETERS (PROVIDED IN BOTH
C  CASES THAT LHTDRG IS SET TO .TRUE.).
C----------
C  COMMONS
C
      INCLUDE 'PRGPRM.F77'
C
      INCLUDE 'PLOT.F77'
C
C
C  COMMONS
C----------
C  DEFINITION OF VARIABLES:
C         D = DIAMETER AT BREAST HEIGHT
C         H = TOTAL TREE HEIGHT (STUMP TO TIP)
C      IFOR = FOREST CODE
C             1 IS MOUNT HOOD (606)
C             2 IS OKANOGAN (608)
C             3 AND IGL = 1 IS WENATCHEE (617)
C                   IGL = 2 IS GIFFORD PINCHOT (603)
C                   IGL = 3 IS MT BAKER/SNOQUALMIE (613)
C             4 IS OKANOGAN TONASKET RD (699)
C      MODE = MODE OF OPERATING THIS SUBROUTINE
C             0 IF DIAMETER IS PROVIDED AND HEIGHT IS DESIRED
C             1 IF HEIGHT IS PROVIDED AND DIAMETER IS DESIRED
C----------
C
      INTEGER IFORXX,ISPC,MODE,I
      REAL D,H,HAT3,P2,P3,P4
      REAL GIFFPC(MAXSP,3)
      REAL MTHOOD(MAXSP,3),OKANOG(MAXSP,3),WENATC(MAXSP,3)
      INTEGER IDANUW
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C  THIS IS DIFFERENT FROM SURROGATE ASSIGNMENTS FOR THE GROWTH FUNCTIONS;
C  THESE EQUATIONS WERE APPROVED FOR DUBBING MISSING HEIGHTS IN R6 DATA
C  PRIOR TO RUNNING FVS FOR THE 1997 RPA ASSESSMENT ANALYSIS. EQUATIONS 
C  ARE BASED ON DATA FROM R6 3.4 MILE GRID DATA AND ARE FOREST SPECIFIC.
C
C----------
C  GIFFORD PINCHOT --- EAST SIDE
C
C  EQUATIONS FIT, AND APPROVED, FOR GIFFORD PINCHOT (EASTSIDE):
C   3=DF,  4=SF,  5=RC,  6=GF,  7=LP,  8=ES,  9=AF, 11=WH, 12=MH, 15=NF
C   26=AS USES EQN FIT TO COMBINED GIFFORD PINCHOT (EAST) AND WINEMA 
C
C  EQNS FIT FOR ANOTHER R6 FOREST AND APPROVED FOR GIFFORD PINCHOT (EASTSIDE):
C     1=WP USES ROGUE RIVER WP
C     2=WL USES OCHOCO WL
C    10=PP USES MT HOOD (EASTSIDE) PP
C    13=PY USES ROGUE RIVER PY
C    14=WB USES FREMONT WB
C    20=BM USES SISKIYOU BM
C    22=RA USES SISKIYOU RA
C    27=CW USES CW REGIONAL STANDARD
C    30=WI USES MT HOOD (EASTSIDE) WI; ALSO WI REGIONAL STANDARD
C    31=OS USES OS REGIONAL STANDARD
C    32=OH USES OH REGIONAL STANDARD
C
C  OTHER SURROGATE ASSIGNMENTS:
C    16=WF USES GIFFORD PINCHOT (EASTSIDE) GF
C    17=LL USES OKANOGAN LL (LARGER SAMPLE THAN WENATCHEE)
C    18=YC USES WENATCHEE YC (LARGER SAMPLE THAN OKANOGAN & CLOSER)
C    19=WJ USES FREMONT WJ (APPROVED FOR OKANOGAN)
C    21=VN USES GIFFORD PINCHOT (WESTSIDE) BM
C    23=PB USES COLVILLE PB (MUCH LARGER SAMPLE THAN OKANOGAN; SIMILAR CURVES)
C    24=GC USES WILLAMETTE GC
C    25=DG USES WILLAMETTE DG
C    28=WO USES ROGUE RIVER WO
C    29=PL USES SIUSLAW CH (APPROVED FOR OKANOGAN & WENATCHEE)
C----------
      DATA (GIFFPC(I,1),I=1,32)/
     & 1143.6254,  255.4638,  519.1872,  171.2219,  616.3503,
     &  727.8110,  102.6146,  211.7962,  113.5390,  324.4467,
     &  504.1935,  631.7598,  127.1698,   73.9147,  178.7700,
     &  727.8110,  119.7985,  126.1074,   60.6009,  220.9772,
     &  179.0706,   94.5048,   88.4509,10707.3906,  444.5618,
     & 1709.7229,  178.6441,      55.0,   73.3348,  149.5861,
     &   34.8330,   34.8330/
C
      DATA (GIFFPC(I,2),I=1,32)/
     &    6.1913,    5.5577,    5.3181,    9.9497,    5.7620,
     &    5.4648,   10.1435,    6.7015,    9.0045,    8.0484,
     &    6.3635,    5.8492,    4.8977,    3.9630,    9.1133,
     &    5.4648,    4.7067,    6.2499,    4.1543,    4.2639,
     &    3.6238,    4.0657,    2.2935,    8.4670,    3.9205,
     &    5.8887,    4.5852,       5.5,    2.6548,    2.4231,
     &    2.6030,    2.6030/
C
      DATA (GIFFPC(I,3),I=1,32)/
     &   -0.3096,   -0.6054,   -0.3943,   -0.9727,   -0.3633,
     &   -0.3435,   -1.2877,   -0.6739,   -0.9907,   -0.5892,
     &   -0.4658,   -0.3384,   -0.4668,   -0.8277,   -0.9131,
     &   -0.3435,   -0.6751,   -0.8091,   -0.6277,   -0.4386,
     &   -0.5730,   -0.9592,   -0.7602,   -0.1863,   -0.2397,
     &   -0.2286,   -0.6746,     -0.95,   -1.2460,   -0.1800,
     &   -0.5352,   -0.5352/
C----------
C  OKANOGAN
C
C  EQUATIONS FIT, AND APPROVED, FOR OKANOGAN:
C   1=WP,  2=WL,  3=DF,  4=SF,  5=RC,  7=LP,  8=ES,  9=AF, 10=PP, 11=WH
C  12=MH, 14=WB, 17=LL, 18=YC, 23=PB, 26=AS
C
C  EQNS FIT FOR ANOTHER R6 FOREST AND APPROVED FOR OKANOGAN:
C     6=GF USES GIFFORD PINCHOT (EASTSIDE) GF
C    13=PY USES ROGUE RIVER PY
C    19=WJ USES FREMONT WJ
C    27=CW USES CW REGIONAL STANDARD
C    29=PL USES SIUSLAW CH
C    30=WI USES ROGUE RIVER W0
C    31=OS USES OS REGIONAL STANDARD
C    32=OH USES OH REGIONAL STANDARD
C
C  OTHER SURROGATE ASSIGNMENTS:
C    15=NF USES GIFFORD PINCHOT (EASTSIDE) NF
C    16=WF USES WENATCHEE GF
C    20=BM USES SISKIYOU BM
C    21=VN USES GIFFORD PINCHOT (WESTSIDE) BM
C    22=RA USES SISKIYOU RA
C    24=GC USES WILLAMETTE GC
C    25=DG USES WILLAMETTE DG
C    28=WO USES ROGUE RIVER WO
C----------
      DATA (OKANOG(I,1),I=1,32)/
     &12437.6601,  248.1393,  305.4997,  303.7380, 1246.8831,
     &  727.8110,  130.5332,  342.9319,  188.7833, 1047.4768,
     &  369.9034,  493.6376,  127.1698,   89.1852,  178.7700,
     &  436.2309,  119.7985,  694.2233,   60.6009,  220.9772,
     &  179.0706,   94.5048,   83.2440,10707.3906,  444.5618,
     &  184.1658,  178.6441,      55.0,   73.3348,      55.0,
     &   34.8330,   34.8330/
C
      DATA (OKANOG(I,2),I=1,32)/
     &    8.1207,    4.8505,    4.7889,    5.8516,    6.9633,
     &    5.4648,    3.6797,    5.4757,    5.8908,    6.0765,
     &    6.7038,    6.0162,    4.8977,    4.7008,    9.1133,
     &    5.5680,    4.7067,    5.9131,    4.1543,    4.2639,
     &    3.6238,    4.0657,    3.5984,    8.4670,    3.9205,
     &    3.4801,    4.5852,       5.5,    2.6548,       5.5,
     &    2.6030,    2.6030/
C
      DATA (OKANOG(I,3),I=1,32)/
     &   -0.1757,   -0.5833,   -0.4347,   -0.5474,   -0.3113,
     &   -0.3435,   -0.6573,   -0.4805,   -0.6732,   -0.2927,
     &   -0.5424,   -0.3765,   -0.4668,   -0.7043,   -0.9131,
     &   -0.4296,   -0.6751,   -0.3484,   -0.6277,   -0.4386,
     &   -0.5730,   -0.9592,   -0.9561,   -0.1863,   -0.2397,
     &   -0.5127,   -0.6746,     -0.95,   -1.2460,     -0.95,
     &   -0.5352,   -0.5352/
C----------
C  WENATCHEE
C
C  EQUATIONS FIT, AND APPROVED, FOR WENATCHEE:
C   1=WP,  2=WL,  3=DF,  4=SF,  5=RC,  6=GF,  7=LP,  8=ES,  9=AF, 10=PP
C  11=WH, 12=MH, 13=PY, 14=WB, 17=LL, 18=YC, 26=AS
C
C  EQNS FIT FOR ANOTHER R6 FOREST AND APPROVED FOR WENATCHEE:
C    15=NF USES GIFFORD PINCHOT (EASTSIDE) NF
C    16=WF USES WENATCHEE GF
C    20=BM USES SISKIYOU BM            
C    27=CW USES CW REGIONAL STANDARD
C    29=PL USES SIUSLAW CH
C    30=WI USES ROGUE RIVER W0
C
C  OTHER SURROGATE ASSIGNMENTS:
C    19=WJ USES FREMONT WJ (APPROVED FOR OKANOGAN)
C    21=VN USES GIFFORD PINCHOT (WESTSIDE) BM
C    22=RA USES SISKIYOU RA
C    23=PB USES COLVILLE PB (MUCH LARGER SAMPLE THAN OKANOGAN; SIMILAR CURVES)
C    24=GC USES WILLAMETTE GC
C    25=DG USES WILLAMETTE DG
C    28=WO USES ROGUE RIVER WO
C    31=OS USES OS REGIONAL STANDARD
C    32=OH USES OH REGIONAL STANDARD
C----------
      DATA (WENATC(I,1),I=1,32)/
     &  254.5262,  170.8511,  318.2462,  356.1556,  307.7977,
     &  436.2309,  100.6367,  233.8124,  166.0115, 1167.0325,
     &  662.9170,  206.3060,   19.6943,   98.3035,  178.7700,
     &  436.2309, 1442.5197,  126.1074,   60.6009,  220.9772,
     &  179.0706,   94.5048,   88.4509,10707.3906,  444.5618,
     & 1507.7287,  178.6441,      55.0,   73.3348,      55.0,
     &   34.8330,   34.8330/
C
      DATA (WENATC(I,2),I=1,32)/
     &    4.7234,    5.8759,    5.1952,    6.0615,    5.9217,
     &    5.5680,    7.0781,    6.9380,    6.1799,    6.2295,
     &    5.7985,    6.7321,   25.0881,    4.7213,    9.1133,
     &    5.5680,    6.1880,    6.2499,    4.1543,    4.2639,
     &    3.6238,    4.0657,    2.2935,    8.4670,    3.9205,
     &    5.3428,    4.5852,       5.5,    2.6548,       5.5,
     &    2.6030,    2.6030/
C
      DATA (WENATC(I,3),I=1,32)/
     &   -0.5029,   -0.7865,   -0.4679,   -0.4783,   -0.5040,
     &   -0.4296,   -1.1163,   -0.6620,   -0.6792,   -0.2793,
     &   -0.3668,   -0.6265,   -2.3675,   -0.6613,   -0.9131,
     &   -0.4296,   -0.2037,   -0.8091,   -0.6277,   -0.4386,
     &   -0.5730,   -0.9592,   -0.7602,   -0.1863,   -0.2397,
     &   -0.1982,   -0.6746,     -0.95,   -1.2460,     -0.95,
     &   -0.5352,   -0.5352/
C----------
C  MT HOOD (EASTSIDE)
C
C  EQUATIONS FIT, AND APPROVED, FOR MT HOOD (EASTSIDE):
C   2=WL,  3=DF,  4=SF,  5=RC,  6=GF,  7=LP,  8=ES,  9=AF, 10=PP, 11=WH,
C  12=MH, 15=NF, 30=WI
C
C  EQNS FIT FOR ANOTHER R6 FOREST AND APPROVED FOR MT HOOD (EASTSIDE):
C     1=WP USES UMPQUA WP
C    13=PY USES ROGUE RIVER PY
C    14=WB USES UMPQUA PY
C    16=WF USES MT HOOD (EASTSIDE) GF
C    22=RA USES UMPQUA RA
C    27=CW USES CW REGIONAL STANDARD
C    28=WO USES ROGUE RIVER WO
C    29=PL USES SIUSLAW CH REGIONAL STANDARD
C    31=OS USES OS REGIONAL STANDARD
C    32=OH USES OH REGIONAL STANDARD
C
C  OTHER SURROGATE ASSIGNMENTS:
C    17=LL USES OKANOGAN LL (LARGER SAMPLE THAN WENATCHEE)
C    18=YC USES WENATCHEE YC (LARGER SAMPLE THAN OKANOGAN & CLOSER)
C    19=WJ USES FREMONT WJ (APPROVED FOR OKANOGAN)
C    20=BM USES SISKIYOU BM
C    21=VN USES GIFFORD PINCHOT (WESTSIDE) BM
C    23=PB USES COLVILLE PB (MUCH LARGER SAMPLE THAN OKANOGAN; SIMILAR CURVES)
C    24=GC USES WILLAMETTE GC
C    25=DG USES WILLAMETTE DG
C    26=AS USES EQN FIT TO COMBINED GIFFORD PINCHOT (EAST) AND WINEMA 
C----------
      DATA (MTHOOD(I,1),I=1,32)/
     &  433.7807,     220.0,  234.2080,  441.9959,  487.5415,
     &  376.0978,  121.1392, 2118.6711,   66.6950,  324.4467,
     &  341.9034,  224.6205,  127.1698,  139.0727,  328.1443,
     &  376.0978,  119.7985,  126.1074,   60.6009,  220.9772,
     &  179.0706,   88.1838,   88.4509,10707.3906,  444.5618,
     & 1709.7229,  178.6441,      55.0,   73.3348,  149.5861,
     &   34.8330,   34.8330/
C
      DATA (MTHOOD(I,2),I=1,32)/
     &    6.3318,       5.0,    6.3013,    6.5382,    5.4444,
     &    5.1639,   12.6623,    6.6094,   13.2615,    8.0484,
     &    6.4658,    7.2549,    4.8977,    5.2062,    5.9501,
     &    5.1639,    4.7067,    6.2499,    4.1543,    4.2639,
     &    3.6238,    2.8404,    2.2935,    8.4670,    3.9205,
     &    5.8887,    4.5852,       5.5,    2.6548,    2.4231,
     &    2.6030,    2.6030/
C
      DATA (MTHOOD(I,3),I=1,32)/
     &   -0.4988,   -0.6054,   -0.6413,   -0.4787,   -0.3801,
     &   -0.4319,   -1.2981,   -0.2547,   -1.3774,   -0.5892,
     &   -0.5379,   -0.6890,   -0.4668,   -0.5409,   -0.5088,
     &   -0.4319,   -0.6751,   -0.8091,   -0.6277,   -0.4386,
     &   -0.5730,   -0.7343,   -0.7602,   -0.1863,   -0.2397,
     &   -0.2286,   -0.6746,     -0.95,   -1.2460,   -0.1800,
     &   -0.5352,   -0.5352/
C----------
C  DUMMY ARGUMENT NOT USED WARNING SUPPRESSION SECTION
C----------
      IDANUW = IFORXX
C----------
C  SET EQUATION PARAMETERS ACCORDING TO FOREST AND SPECIES.
C  
C  NOTE: MT BAKER/SNOQUALAMIE USES GIFFORD PINCHOT COEFFICIENTS BECAUSE
C        SO MANY SPECIES WERE FIT FOR THE GP EASTSIDE AND THE MBS DOESN'T
C        LIE EAST OF THE CASCADE CREST. HOWEVER, THIS COULD BE CHANGED AND
C        AN ARRAY SPECIFIC TO THE MBS COULD BE USED.
C
C  NOTE: GIFFORD PINCHOT AND MBS ARE MAPPED TO WENATCHEE (IFOR=3) IN 
C        SUBROUTINE **FORKOD**, SO ALSO USE VARIABLE IGL 
C        TO SELECT COEFFICIENTS IN ADDITION TO VARIABLE IFOR
C        (IGL=1=WENATCHEE, IGL=2=GIFFORD PINCHOT, IGL=3=MBS).
C----------
      SELECT CASE (IFOR)
      CASE(1)
        P2 = MTHOOD(ISPC,1)
        P3 = MTHOOD(ISPC,2)
        P4 = MTHOOD(ISPC,3)
      CASE(2,4)
        P2 = OKANOG(ISPC,1)
        P3 = OKANOG(ISPC,2)
        P4 = OKANOG(ISPC,3)
      CASE DEFAULT
        SELECT CASE (IGL)
        CASE(2,3)
          P2 = GIFFPC(ISPC,1)
          P3 = GIFFPC(ISPC,2)
          P4 = GIFFPC(ISPC,3)
        CASE DEFAULT
          P2 = WENATC(ISPC,1)
          P3 = WENATC(ISPC,2)
          P4 = WENATC(ISPC,3)
        END SELECT
      END SELECT
C
      IF(MODE .EQ. 0) H=0.
      IF(MODE .EQ. 1) D=0.
C----------
C  PROCESS ACCORDING TO MODE
C----------
      IF(MODE .EQ. 0) THEN
        IF(D .GE. 3.) THEN
          H = 4.5 + P2 * EXP(-1.*P3*D**P4)
        ELSE
          H = ((4.5+P2*EXP(-1.*P3*(3.**P4))-4.51)*(D-0.3)/2.7)+4.51
        ENDIF
      ELSE
        HAT3 = 4.5 + P2 * EXP(-1.*P3*3.0**P4)
        IF(H .GE. HAT3) THEN
          D = EXP( ALOG((ALOG(H-4.5)-ALOG(P2))/(-1.*P3)) * 1./P4)
        ELSE
          D = (((H-4.51)*2.7)/(4.5+P2*EXP(-1.*P3*(3.**P4))-4.51))+0.3
        ENDIF
      ENDIF
C
      RETURN
      END
