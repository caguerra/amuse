      function bulgedens(r,z)
      psi = pot(r,z)
      bulgedens = bulgedenspsi(psi)

      return
      end

      function bulgedenspsi(energy)

      include 'commonblocks'

      if(energy.lt.psic) then
         bulgedenspsi = 0.
         return
      endif
      if(energy.ge.psi0) then
         bulgedenspsi = denspsibulge(1)
         return
      endif

      rj = 1. + float(npsi-1)*
     +     log((psi0-energy)/(psi0-psid))/log((psi0-psic)/(psi0-psid))
      j = int(rj)
      if(j.lt.1) j = 1
      if(j.ge.npsi) j = npsi-1

      frac = rj - float(j)
      bulgedenspsi = denspsibulge(j) + 
     +     frac*(denspsibulge(j+1)-denspsibulge(j))
      return
      
      end
