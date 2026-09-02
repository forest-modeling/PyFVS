@echo off
:: Refresh the *.sum.save files from the official FVS release.

set fvs_bin=c:\tools\FVS\FVSbin_20260701

set variants=pn wc so ca op oc ec bm nc ws ie ci ak

for %%v in (%variants%) do call :run_bareground %%v

for %%v in (%variants%) do call :run_t01 %%v

goto end

:run_bareground
echo FVS Variant: %1
set v=%1
set fn=%1_bareground
call %fvs_bin%\fvs%v%.exe --keywordfile=%fn%.key
move %fn%.sum %fn%.sum.save

:run_t01
echo FVS Variant: %1
set v=%1
set fn=%1t01
call %fvs_bin%\fvs%v%.exe --keywordfile=%fn%.key
move %fn%.sum %fn%.sum.save

goto :eof

:end
