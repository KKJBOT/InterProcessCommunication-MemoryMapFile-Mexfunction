if ERP42.r < minDist
    if ERP42.nwp >= nwp
        ERP42.nwp = nwp;
    else
        ERP42.nwp = ERP42.nwp + 1;
    end
end