```
fvs/fvs_step.fvs_grow
grow_callback(10)              # GCB_PRE_GROW
tregro(grow_callback)
    grincr(..., grow_callback)
        DGDRIV            # Estimate diameter growth
        HTGF              # Esitmate height growth
        REGENT            # Small tree increments
        <FIXDG, FIXHTG>   # Apply FIXDG and FIXHTG options
      **grow_callback(25) # GCB_POST_DG_HTG - callback after DG & HTG estimates
        MORTS             # Etimates mortality (held in WK2)
      **grow_callback(26) # GCB_POST_MORT - callback after MORT estimates
        TRIPLE            # Apply the tripling routine, apply tripling weights to TPA (PROB) and MORT (WK2)
    
  **grow_callback(20)     # GCB_INCR
    copy_snag_data()      # FVS_DATA_API
    gradd()               #
        <scale dg>        # Scale diameter growth to the cycle interval
        update()          # Apply increments
            <Ht. Incr>    # Add height increment
            <Mortality>   # Deduct mortality
            <Volume>      # Compute tree volume ?? Why before diameter increment
            <Diam Incr>   # Add diameter increment, DBH + DG/BRATIO
        rdpsrt            # Resort tree records by diameter
        dense             # post-mortality and BAI density
        <age incr>        # Increment tree age
**grow_callback(30)       # GCB_POST_GROW
```