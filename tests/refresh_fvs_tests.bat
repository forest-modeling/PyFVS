@echo off
:: Refresh the *.sum.save files generated with the official FVS release.

set fvs_bin=c:\tools\FVS\FVSbin_20260701
set test_root=C:\workspace\pyfvs\src\fvs\tests
set variants=pn wc so ca op oc ec bm nc ws ie ci ak

for %%v in (%variants%) do call :run_fvs_tests %%v %test_root%

goto end

:run_fvs_tests
echo FVS Variant: %1
set v=%1
set root=%2
set fn=%1t01
call %fvs_bin%\fvs%v%.exe --keywordfile=%root%\FVS%v%\%fn%.key
move %fn%.sum %fn%.sum.save

goto :eof

:end
