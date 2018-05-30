!============================================================================
!    Copyright (c) 2016, Los Alamos National Security, LLC
!    All rights reserved.
!============================================================================

MODULE ModScbCompute
  ! Contains subroutines for computing various SCB parameters
  

  implicit none

  contains
!==============================================================================
  SUBROUTINE metrics
    !!!! Module Variables
    use ModRamParams,    ONLY: boundary
    use ModScbMain,      ONLY: iConvE, iInducedE
    use ModScbParams,    ONLY: isotropy
    use ModScbGrids,     ONLY: nzeta, npsi, nthe, nzetap, npsim, dt, dr, dpPrime
    use ModScbVariables, ONLY: x, y, z, xx, yy, alfa, bX, bY, bZ, f, fzet, dela, &
                               jacobian, EXInd, EYInd, EZInd, bsq, GradAlphaSq, &
                               GradPsiGradAlpha, dPPardPsi, dPPardAlpha, dPdPsi, &
                               dPdAlpha, bf, bj, dBsqdTheta, EXConv, EYConv, EZConv, &
                               rhoVal, r0Start, nZetaMidnight, nThetaEquator, &
                               jParDirect, iteration, DstBiotInsideGEO, DstBiot, &
                               paraj, phij, thetaVal, zetaVal, pjconst, &
                               xzero, xzero3, dBetadT, dPhiIonodBeta, sigma, &
                               dPPerdAlpha, dBsqdAlpha, dBsqdPsi, dPPerdPsi, &
                               dPhiIonodAlpha, dAlphadT, ppar, dPPerdTheta, &
                               curvaturePsi, curvatureGradPsi, radialCurvature, &
                               GradRhoSq, GradThetaSq, GradZetaSq, &
                               GradRhoGradTheta, GradRhoGradZeta, GradThetaGradZeta, &
                               derivXTheta, derivXRho, derivXZeta, &
                               derivYTheta, derivYRho, derivYZeta, &
                               derivZTheta, derivZRho, derivZZeta, &
                               gradRhoX, gradRhoY, gradRhoZ, &
                               gradZetaX, gradZetaY, gradZetaZ, &
                               gradThetaX, gradThetaY, gradThetaZ, &
                               jGradRho, jGradZeta, jGradTheta

    !!!! Module Subroutine/Functions
    use ModRamGSL, ONLY: GSL_Derivs
    !!!! NR Modules
    use nrtype, ONLY: DP, SP, twopi_d, pi_d, pio2_d

    implicit none

    INTEGER :: GSLerr
    INTEGER :: i, j, k, nzd1, nzd2, nzd3, nzd4, nthe0, nthe1, id, ierr, idealerr, ncdfId
    REAL(DP) :: yyp, bju, bjd, normDivJCrossB, normCurlJCrossB, volume, region1FAC, & 
                region2FAC, totalCROSS, dstComputed, EAlpha, EBeta, gradPhiIonoGradAlpha, &
                gradPhiIonoGradBeta, dipoleFactor, dipoleFactor4RE, factorIncrease, thangle, &
                thangleOnEarth, rr1, rr2, rr, zangle
    REAL(DP) :: rrlatx(201),rrlaty(201), wlabels(4)
    REAL(DP), DIMENSION(nthe,nzeta) :: metricDif, metricDif2
    REAL(DP), DIMENSION(npsi,nzeta+1) :: rrx, rry, parajDirect
    REAL(DP), DIMENSION(nthe,npsi,nzeta) :: alphaTerm, psiTerm, derivNU1, derivNU2
    REAL(DP), DIMENSION(nthe,npsi,nzeta) :: derivBsqRho, derivBsqZeta
    REAL(DP), DIMENSION(nthe,npsi,nzeta) :: jGradRhoFactor, jGradZetaFactor, jGradThetaFactor, &
                                            phiToroid, derivPhiRho, derivPhiZeta, &
                                            derivPhiTheta, dPpardZeta, dPpardRho, dPpardTheta, &
                                            generateFAC, generateFACPAlpha, generateFACPPsi

     !  Compute metrics after the solution has converged
     !  xx is the radius in cylindrical coordinate system
     !  yy is the toroidal angle
     DO  j = 1,npsi
        DO  i = 1,nthe
           DO  k = 2,nzeta
              xx(i,j,k) = SQRT(x(i,j,k)**2 + y(i,j,k)**2)
              yy(i,j,k) = x(i,j,k) / xx(i,j,k)
              yyp = yy(i,j,k)
              yy(i,j,k) = ACOS(yyp)
           END DO
           !  avoid k = 2 for y near zero so that phi can be negative, but small
           IF(y(i,j,2) < 0.0) yy(i,j,2)=-yy(i,j,2)
           DO  k=3,nzeta
              IF(y(i,j,k) < 0.0) yy(i,j,k)=twopi_d-yy(i,j,k)
           END DO
           DO  k=2,nzeta
              dela(k) = alfa(i,j,k) - yy(i,j,k)
           END DO
           dela(1) = dela(nzeta)
           dela(nzetap) = dela(2)
           xx(i,j,1) = xx(i,j,nzeta)
           xx(i,j,nzetap) = xx(i,j,2)
           yy(i,j,1) = alfa(i,j,1) - dela(1)
           yy(i,j,nzetap) = alfa(i,j,nzetap) - dela(nzetap)
        END DO
     END DO

     InducedE: IF (iInducedE /= 0) THEN
        DO k = 2, nzeta
           DO j = 1, npsi
              DO i = nThetaEquator, nThetaEquator ! Only equatorial plane for now
                 EAlpha = -dAlphadT(i,j,k) * gradRhoGradZeta(i,j,k)*f(j)*fzet(k) + &
                           dBetadT(i,j,k)*gradRhoSq(i,j,k) * f(j)**2
                 EBeta = -dAlphadT(i,j,k)*gradZetaSq(i,j,k) * fzet(k)**2 + &
                          dBetadT(i,j,k) * gradRhoGradZeta(i,j,k) ! Verify this
                 EXInd(i,j,k) = derivXRho(i,j,k)*EAlpha/f(j) + derivXZeta(i,j,k)*EBeta/fzet(k)
                 EYInd(i,j,k) = derivYRho(i,j,k)*EAlpha/f(j) + derivYZeta(i,j,k)*EBeta/fzet(k)
                 EZInd(i,j,k) = derivZRho(i,j,k)*EAlpha/f(j) + derivZZeta(i,j,k)*EBeta/fzet(k)
              END DO
           END DO
        END DO
        ! Periodicity
        EXInd(:,:,1) = EXInd(:,:,nzeta)
        EYInd(:,:,1) = EYInd(:,:,nzeta)
        EZInd(:,:,1) = EZInd(:,:,nzeta)
        EXInd(:,:,nzetap) = EXInd(:,:,2)
        EYInd(:,:,nzetap) = EYInd(:,:,2)
        EZInd(:,:,nzetap) = EZInd(:,:,2)
     END IF InducedE

     ConvectionE:     IF (iConvE == 1) THEN
        DO k = 2, nzeta
           DO j = 1, npsi
              DO i = 1, nthe
                 gradPhiIonoGradAlpha = dPhiIonodAlpha(j,k) * gradRhoSq(i,j,k) * f(j)**2 + &
                      dPhiIonodBeta(j,k) * gradRhoGradZeta(i,j,k) * f(j)*fzet(k)
                 gradPhiIonoGradBeta = dPhiIonodAlpha(j,k) * gradRhoGradZeta(i,j,k) * f(j)*fzet(k) + &
                      dPhiIonodBeta(j,k)*gradZetaSq(i,j,k) * fzet(k)**2
                 EXConv(i,j,k) = - (derivXRho(i,j,k)*gradPhiIonoGradAlpha/f(j) &
                                 + derivXZeta(i,j,k)*gradPhiIonoGradBeta/fzet(k))
                 EYConv(i,j,k) = - (derivYRho(i,j,k)*gradPhiIonoGradAlpha/f(j) &
                                 + derivYZeta(i,j,k)*gradPhiIonoGradBeta/fzet(k))
                 EZConv(i,j,k) = - (derivZRho(i,j,k)*gradPhiIonoGradAlpha/f(j) &
                                 + derivZZeta(i,j,k)*gradPhiIonoGradBeta/fzet(k))
              END DO
           END DO
        END DO
        ! Periodicity
        EXConv(:,:,1) = EXConv(:,:,nzeta)
        EYConv(:,:,1) = EYConv(:,:,nzeta)
        EZConv(:,:,1) = EZConv(:,:,nzeta)
        EXConv(:,:,nzetap) = EXConv(:,:,2)
        EYConv(:,:,nzetap) = EYConv(:,:,2)
        EZConv(:,:,nzetap) = EZConv(:,:,2)
     END IF ConvectionE

     CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, bsq(1:nthe, 1:npsi, 1:nzeta), &
                     dBsqdTheta, derivBsqRho, derivBsqZeta, GSLerr)

     IF (isotropy /= 1) THEN

        CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, ppar(1:nthe,1:npsi,1:nzeta), &
                        dPpardTheta, dPpardRho, dPpardZeta, GSLerr)
        DO k = 1, nzeta
           dPpardAlpha(:,:,k) = 1./fzet(k) * dPpardZeta(:,:,k)
        END DO
        DO j = 1, npsi
           dPpardPsi(:,j,:) = 1./f(j) * dPpardRho(:,j,:)
        END DO
     END IF

     ! Field-aligned current density; = 0 at equator

     ! 1). Computation using integration along the field line
     ! B \cdot grad(sigma*bj/B) = grad(B^2)xB \cdot grad(P)/ (sigma*B^4)

     DO   k = 1,nzeta
        DO  j = 1,npsi
           !     psiTerm = B x grad (psi) dot grad (B^2)
           psiTerm(:,j,k) = bsq(1:nthe,j,k) * derivBsqZeta(:,j,k) + dBsqdTheta(:,j,k) &
                * (gradRhoSq(:,j,k) * gradThetaGradZeta(:,j,k) - &
                gradRhoGradTheta(:,j,k) * gradRhoGradZeta(:,j,k)) * (f(j)*fzet(k))**2
           psiTerm(:,j,k) = psiTerm(:,j,k) / fzet(k) ! OK 

           IF (isotropy == 1) THEN ! Only for the isotropic case
              ! Now geodesic curvature 
              curvaturePsi(1:nthe,j,k) = (2._dp * dpdAlpha(1:nthe,j,k) + derivBsqZeta(1:nthe,j,k) * &
                   1._dp/fzet(k)) / bsq(1:nthe,j,k) + dBsqdTheta(1:nthe,j,k) * 1._dp / bsq(1:nthe,j,k)**2 * &
                   (gradRhoSq(1:nthe,j,k) * gradThetaGradZeta(1:nthe,j,k) - &
                   gradRhoGradTheta(1:nthe,j,k) * gradRhoGradZeta(1:nthe,j,k)) * (f(j)**2) * fzet(k)

              curvatureGradPsi(1:nthe,j,k) = 1./bsq(1:nthe,j,k) * (dpdPsi(1:nthe,j,k) + 0.5 * &
                   derivBsqRho(1:nthe,j,k) * 1./f(j) + gradRhoGradZeta(1:nthe,j,k)/gradRhoSq(1:nthe,j,k) * &
                   fzet(k)/f(j) * (dpdAlpha(1:nthe,j,k) + 0.5 * derivBsqZeta(1:nthe,j,k) * 1./fzet(k)) + &
                   0.5 * gradRhoGradTheta(1:nthe,j,k)/gradRhoSq(1:nthe,j,k) * 1./f(j) * &
                   dBsqdTheta(1:nthe,j,k))
              radialCurvature(1:nthe,j,k) = curvatureGradPsi(1:nthe,j,k) * f(j) * SQRT(gradRhoSq(1:nthe,j,k))

           END IF

           gradPsiGradAlpha(1:nthe,j,k) = f(j) * fzet(k) * gradRhoGradZeta(1:nthe,j,k)
           gradAlphaSq(1:nthe,j,k) = fzet(k)**2 * gradZetaSq(1:nthe,j,k)

           !     alphaTerm = B x grad (alfa) dot grad (B^2)
           alphaTerm(:,j,k) = - bsq(1:nthe,j,k) * derivBsqRho(:,j,k) + dBsqdTheta(:,j,k) &
                * (gradRhoGradZeta(:,j,k) * gradThetaGradZeta(:,j,k) - &
                gradRhoGradTheta(:,j,k) * gradZetaSq(:,j,k)) * (f(j)*fzet(k))**2
           alphaTerm(:,j,k) = alphaTerm(:,j,k) / f(j) ! OK
        END DO
     END DO

     nthe1 = nThetaEquator + 1

     FAC_Isotropy_Choice:  IF (isotropy == 1) THEN  ! Isotropic case
        DO  j       = 2, npsim
           DO  k    = 1, nzeta
              bju = 0._dp
              bjd = 0._dp
              iLoop:  DO  i = nthe1, nthe
                 ! Now the factors 1/(f*fzet) have been added correctly
                 generateFACPAlpha(i,j,k) = 1._dp/(f(j)*fzet(k)) * jacobian(i,j,k) / bsq(i,j,k) **2 * &
                      (dPdAlpha(i,j,k)  * alphaTerm(i,j,k) - 2._dp*dPdAlpha(i,j,k)*dPdPsi(i,j,k)*bsq(i,j,k))
                 generateFACPPsi(i,j,k) = 1._dp/(f(j)*fzet(k)) * jacobian(i,j,k) / bsq(i,j,k) **2 * &
                      (dpdPsi(i,j,k) * psiTerm(i,j,k) + 2._dp*dPdAlpha(i,j,k)*dPdPsi(i,j,k)*bsq(i,j,k))
                 generateFAC(i,j,k) = generateFACPAlpha(i,j,k) + generateFACPPsi(i,j,k)

                 bju = bju + generateFAC(i,j,k) * dt
                 bj(i,j,k) = bju * bf(i,j,k)

                 id = nthe - i + 1
                 generateFACPAlpha(id,j,k) = 1._dp/(f(j)*fzet(k)) * jacobian(id,j,k)/bsq(id,j,k)**2 &
                                           * dpdAlpha(id,j,k) * alphaTerm(id,j,k)
                 generateFACPPsi(id,j,k) = 1._dp/(f(j)*fzet(k)) * jacobian(id,j,k)/bsq(id,j,k)**2 &
                                         * dpdPsi(id,j,k) * psiTerm(id,j,k)
                 generateFAC(id,j,k) = generateFACPAlpha(id,j,k) + generateFACPPsi(id,j,k)

                 bjd = bjd + generateFAC(id,j,k) * dt
                 bj(id,j,k) = bjd * bf(id,j,k)
              END DO iLoop
           END DO
        END DO
     ELSE ! Anisotropic pressure case
        DO  j       = 2, npsim
           DO  k    = 1, nzeta ! nZetaMidnight
              bju = 0._dp
              bjd = 0._dp
              !        bj(nthe0,j,k)=bju*bf(nthe0,j,k)/sigma(nthe0,j,k)
              DO  i = nthe1, nthe
                 bju = bju + 1._dp/(2.*f(j)*fzet(k)) * dt * jacobian(i,j,k) / &
                      (sigma(i,j,k) * bsq(i,j,k) **2) * &
                      ((dPperdPsi(i,j,k) + dPpardPsi(i,j,k))* psiTerm(i,j,k) + &
                      (dPperdAlpha(i,j,k) + dPpardAlpha(i,j,k)) * alphaTerm(i,j,k))
                 bj(i,j,k) = bju * bf(i,j,k) / sigma(i,j,k)

                 id = nthe - i + 1
                 bjd = bjd + 1._dp/(2.*f(j)*fzet(k)) * dt * jacobian(i,j,k) / &
                      (sigma(i,j,k) * bsq(i,j,k) **2) * &
                      ((dPperdPsi(i,j,k) + dPpardPsi(i,j,k)) * psiTerm(i,j,k) + &
                      (dPperdAlpha(i,j,k) + dPpardAlpha(i,j,k)) * alphaTerm(i,j,k))
                 bj(id,j,k) = bjd * bf(id,j,k) / sigma(i,j,k)
              END DO
           END DO
        END DO
     END IF FAC_Isotropy_Choice

     ! Now compute TOTAL field-aligned current in the Regions 1 and 2 at i =
     ! nthe - 1
     region1FAC = 0._dp
     region2FAC = 0._dp
     DO j = 2, npsi-1
        DO k = 2, nZetaMidnight
           ! Area element is dS = jacobian * drho * dzeta * |grad theta|
           IF (bj(2,j,k) < 0) THEN   ! Region 1
              region1FAC = region1FAC + bj(2,j,k)/bf(2,j,k) * f(j) * fzet(k) &
                         * dr * dpPrime
           ELSE                      ! Region 2
              region2FAC = region2FAC + bj(2,j,k)/bf(2,j,k) * f(j) * fzet(k) &
                         * dr * dpPrime
           END IF
        END DO
     END DO


     ! Now time for 2nd calculation of field-aligned current, and also for
     ! calculation of toroidal current
     jGradRhoFactor = gradRhoGradZeta * gradThetaGradZeta - gradZetaSq * gradRhoGradTheta
     jGradZetaFactor = gradRhoGradTheta * gradRhoGradZeta - gradThetaGradZeta * gradRhoSq
     jGradThetaFactor = gradRhoSq * gradZetaSq - gradRhoGradZeta **2

     DO j = 1, npsi
        DO k = 1, nzeta
           jParDirect(:,j,k) = 1._dp/bf(1:nthe,j,k)*jacobian(:,j,k)*f(j)*fzet(k) &
                             * (jGradRho(:,j,k) * jGradRhoFactor(:,j,k) &
                             + jGradZeta(:,j,k) * jGradZetaFactor(:,j,k) &
                             + jGradTheta(:,j,k) * jGradThetaFactor(:,j,k))
        END DO
     END DO

     ! Now the southern current has the wrong sign, since B is outward in
     ! the southward hemisphere, and we just computed |JdotB|/B

     DO i = 1, nThetaEquator-1
        jParDirect(i,:,:) = -jParDirect(i,:,:)
     END DO


     ! Calculating toroidal current when equilibrium has been reached

     phiToroid(1:nthe, 1:npsi, 1:nzeta) = yy(1:nthe, 1:npsi, 1:nzeta)

     CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, phiToroid, &
                     derivPhiTheta, derivPhiRho, derivPhiZeta, GSLerr)

     phij(1:nthe,1:npsi,1:nzeta) = xx(1:nthe,1:npsi,1:nzeta) &
                                 * (jGradRho * derivPhiRho &
                                 + jGradZeta * derivPhiZeta &
                                 + jGradTheta * derivPhiTheta)

     ! Now compute TOTAL cross-tail current in the midnight meridional plane,
     ! and the "DST" (deflection due
     ! do jphi at the center of the Earth)

     totalCROSS = 0._dp
     dstBiot = 0._dp
     dstBiotInsideGeo = 0._dp

     DO i = 2, nthe-1
        DO j = 2, npsi
           totalCROSS = totalCROSS + jacobian(i,j,nZetaMidnight) * dr * dt * &
                ABS(SQRT(gradZetaSq(i,j,nZetaMidnight))) * phij(i,j,nZetaMidnight)
           DO k = 2, nzeta
              dstBiot = dstBiot + 1.E-7_dp * jacobian(i,j,k)*phij(i,j,k)*pjconst*1.E3_dp / &
                   (x(i,j,k)**2+y(i,j,k)**2+z(i,j,k)**2) * dr * dt * dpPrime * 6.4E6_dp * &
                   SQRT(x(i,j,k)**2+y(i,j,k)**2)/SQRT(x(i,j,k)**2+y(i,j,k)**2+z(i,j,k)**2)
              IF (xx(i,j,k) < 6.6_dp) dstBiotInsideGeo = dstBiotInsideGeo + 1.E-7_dp * &
                   jacobian(i,j,k)*phij(i,j,k)*pjconst*1E3 / &
                   (x(i,j,k)**2+y(i,j,k)**2+z(i,j,k)**2) * dr * dt * dpPrime * 6.4E6_DP * &
                   SQRT(x(i,j,k)**2+y(i,j,k)**2)/SQRT(x(i,j,k)**2+y(i,j,k)**2+z(i,j,k)**2)
           END DO
        END DO
     END DO

     ! Multiply by 1.3 to take into account currents induced inside Earth
     dstBiot = 1.3 * dstBiot
     dstBiotInsideGeo = 1.3 * dstBiotInsideGeo
     dstComputed = 0.0

     DO i = 2, nthe
        DO j = 2, npsi-1
           totalCROSS = totalCROSS + jacobian(i,j,nZetaMidnight) * dr * dt * &
                ABS(SQRT(gradZetaSq(i,j,nZetaMidnight))) * phij(i,j,nZetaMidnight)
           DO k = 2, nzeta
              dstComputed = dstComputed + 1.E-7_dp * jacobian(i,j,k)*phij(i,j,k)*pjconst*1E3 / &
                   (x(i,j,k)**2+y(i,j,k)**2+z(i,j,k)**2) * dr * dt * dpPrime * 6.4E6_DP * &
                   SQRT(x(i,j,k)**2+y(i,j,k)**2)/SQRT(x(i,j,k)**2+y(i,j,k)**2+z(i,j,k)**2)
           END DO
        END DO
     END DO

     alphaLoop :  DO k = 2, nzeta + 1
        psiLoop :   DO j = 1, npsi
           i = nthe
           rr2 = xx(i,j,k)**2 + z(i,j,k)**2
           rr1 = SQRT(rr2)
           zangle = yy(i,j,k)
           !!  thangle is the polar angle
           thangle = ASIN(z(i,j,k) / rr1)
           IF ((ABS(thangle) > 1000.) .OR. (ABS(zangle) > 1000.)) THEN
              PRINT*, j, k, rr1, z(i,j,k), thangle, zangle
              STOP
           END IF

           thangleOnEarth = ACOS(SQRT((COS(thangle))**2/r0Start))

           !!  radius that corresponds to polar angle is normalized to 1 for
           !every 10 degree in 
           ! latitude zangle is toroidal angle; zangle = 0 is local noon
           IF (INT(r0Start) /= 1) rr = (90._dp - thangleOnEarth * 360._dp / twopi_d) / 10.0_dp
           IF (INT(r0Start) == 1) rr = (90._dp - thangle * 360._dp / twopi_d) / 10.0_dp
           rrx(j,k) = rr * COS(zangle + pio2_d)
           rry(j,k) = rr * SIN(zangle + pio2_d)

           ! Dipole field at the Earth's surface
           dipoleFactor = SQRT(1. + 3. * (SIN(thangleOnEarth))**2)
           dipoleFactor4RE = SQRT(1. + 3. * (SIN(thangle))**2)
           factorIncrease = dipoleFactor * r0Start**3 / dipoleFactor4RE

           IF (INT(r0Start) /= 1) THEN
              paraj(j,k) = bj(1,j,k) * factorIncrease
              parajDirect(j,k) = jParDirect(1,j,k) * factorIncrease
           ELSE
              paraj(j,k) = bj(1,j,k)
              parajDirect(j,k) = jParDirect(1,j,k)
           END IF
        END DO psiLoop
     END DO alphaLoop

     ! Express physical quantities (use normalization constants)
     pjconst = 1.E6  * 0.31E-4 / (xzero3 * 4. * pi_d * 1.e-7 * 6.4E6)

     bj = bj * pjconst
     jParDirect = jParDirect * pjconst
     phij = phij * pjconst

     region1FAC = region1FAC * pjconst * 6.371**2    ! in MA; 6.371**2 is R_E**2
     region2FAC = region2FAC * pjconst * 6.371**2    ! in MA
     totalCROSS = totalCROSS * pjconst * 6.371**2    ! in MA

     IF (boundary/='SWMF' .AND. iteration/=1) THEN
        PRINT*, ' '
        WRITE(*, '(A, 2X, G9.2)') &
             'Total azimuthal J - midnight meridian (MA): ', REAL(totalCROSS,sp)
        PRINT*, 'Total region 1 current in MA: ', REAL(region1FAC,sp)
        PRINT*, 'Total region 2 current in MA: ', REAL(region2FAC,sp)
        PRINT*, ' '
     END IF

!     distanceAlongLine(:,:,:) = 0._dp

!     DO k = 1, nzeta
!        DO j = 1, npsi
!           DO i = 2, nThetaEquator
!              distanceAlongLine(i,j,k) = distanceAlongLine(i-1,j,k) + &
!                   jacobian(nThetaEquator-i+2,j,k) / (f(j)*fzet(k)) * dt
!           END DO
!        END DO
!     END DO

     RETURN

  END SUBROUTINE metrics

!==============================================================================
  SUBROUTINE computeBandJacob
    !!!! Module Variables
    USE ModRamParams,    ONLY: verbose
    USE ModScbGrids,     ONLY: nthe, npsi, nzeta
    use ModScbVariables, ONLY: x, y, z, bf, bsq, Bx, By, Bz, jacobian, SORFail, &
                               f, fzet, rhoVal,thetaVal, zetaVal, bfInitial, &
                               GradRhoSq, GradThetaSq, GradZetaSq, &
                               GradRhoGradTheta, GradRhoGradZeta, GradThetaGradZeta, &
                               derivXTheta, derivXRho, derivXZeta, &
                               derivYTheta, derivYRho, derivYZeta, &
                               derivZTheta, derivZRho, derivZZeta, &
                               gradRhoX, gradRhoY, gradRhoZ, &
                               gradZetaX, gradZetaY, gradZetaZ, &
                               gradThetaX, gradThetaY, gradThetaZ
    !!!! Module Subroutines/Functions
    USE ModRamGSL, ONLY: GSL_Derivs
    !!!! NR Modules
    use nrtype, ONLY: DP


    implicit none

    INTEGER :: i, j, k, GSLerr

    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, x(1:nthe, 1:npsi, 1:nzeta), &
                    derivXTheta, derivXRho, derivXZeta, GSLerr)
    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, y(1:nthe, 1:npsi, 1:nzeta), &
                    derivYTheta, derivYRho, derivYZeta, GSLerr)
    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, z(1:nthe, 1:npsi, 1:nzeta), &
                    derivZTheta, derivZRho, derivZZeta, GSLerr)

    jacobian = derivXRho   * (derivYZeta  * derivZTheta - derivYTheta * derivZZeta)  &
             + derivXZeta  * (derivYTheta * derivZRho   - derivYRho   * derivZTheta) &
             + derivXTheta * (derivYRho   * derivZZeta  - derivYZeta  * derivZRho)

    gradRhoX = (derivYZeta * derivZTheta - derivYTheta * derivZZeta) / jacobian
    gradRhoY = (derivZZeta * derivXTheta - derivZTheta * derivXZeta) / jacobian
    gradRhoZ = (derivXZeta * derivYTheta - derivXTheta * derivYZeta) / jacobian

    gradZetaX = (derivYTheta * derivZRho - derivYRho * derivZTheta) / jacobian
    gradZetaY = (derivZTheta * derivXRho - derivZRho * derivXTheta) / jacobian
    gradZetaZ = (derivXTheta * derivYRho - derivXRho * derivYTheta) / jacobian

    gradThetaX = (derivYRho * derivZZeta - derivYZeta * derivZRho) / jacobian
    gradThetaY = (derivZRho * derivXZeta - derivZZeta * derivXRho) / jacobian
    gradThetaZ = (derivXRho * derivYZeta - derivXZeta * derivYRho) / jacobian

    gradRhoSq = gradRhoX**2 + gradRhoY**2 + gradRhoZ**2
    gradRhoGradZeta = gradRhoX * gradZetaX + gradRhoY * gradZetaY + gradRhoZ * gradZetaZ
    gradRhoGradTheta = gradRhoX * gradThetaX + gradRhoY * gradThetaY + gradRhoZ * gradThetaZ

    gradThetaSq = gradThetaX**2 + gradThetaY**2 + gradThetaZ**2
    gradThetaGradZeta = gradThetaX * gradZetaX + gradThetaY * gradZetaY + gradThetaZ * gradZetaZ

    gradZetaSq = gradZetaX**2 + gradZetaY**2 + gradZetaZ**2

    ! Compute magnetic field
    DO k = 1,nzeta
       DO j = 1,npsi
          DO i = 1,nthe
             Bx(i,j,k) = (f(j)*fzet(k)*derivXTheta(i,j,k)/jacobian(i,j,k))
             By(i,j,k) = (f(j)*fzet(k)*derivYTheta(i,j,k)/jacobian(i,j,k))
             Bz(i,j,k) = (f(j)*fzet(k)*derivZTheta(i,j,k)/jacobian(i,j,k))
             bsq(i,j,k) = (gradRhoSq(i,j,k)*gradZetaSq(i,j,k)-gradRhoGradZeta(i,j,k)**2) &
                          * (f(j) * fzet(k)) **2
             bfInitial(i,j,k) = SQRT(bsq(i,j,k))
             bf(i,j,k) = bfInitial(i,j,k)
             if (bf(i,j,k).ne.bf(i,j,k)) then
                SORFail = .true.
             endif
             IF (ABS(bsq(i,j,k)) < 1e-30_dp) THEN
                SORFail = .true.
             END IF
          END DO
       END DO
    END DO

    RETURN

  END SUBROUTINE computeBandJacob

!=================================================================================================!
  SUBROUTINE Compute_convergence
    !!!! Module Variables
    use ModRamParams,    ONLY: verbose
    use ModScbParams,    ONLY: isotropy
    USE ModScbGrids,     ONLY: nthe, npsi, nzeta, dt, dr, dpPrime
    USE ModScbVariables, ONLY: thetaVal, rhoVal, zetaVal, x, y, z, jacobian, &
                               normDiff, normGradP, ppar, pper, nThetaEquator, &
                               normJxB, f, fzet, nZetaMidnight, pnormal, &
                               dPPerdRho, dPPerdZeta, dPPerdTheta, bnormal, &
                               pjconst, dPdAlpha, dPdPsi, SORFail, bf, bsq, &
                               GradRhoSq, GradThetaSq, GradZetaSq, &
                               GradRhoGradTheta, GradRhoGradZeta, GradThetaGradZeta, &
                               derivXTheta, derivXRho, derivXZeta, &
                               derivYTheta, derivYRho, derivYZeta, &
                               derivZTheta, derivZRho, derivZZeta, &
                               gradRhoX, gradRhoY, gradRhoZ, &
                               gradZetaX, gradZetaY, gradZetaZ, &
                               gradThetaX, gradThetaY, gradThetaZ, &
                               Jx, Jy, Jz, Bx, By, Bz, GradPx, GradPy, GradPz, &
                               JxBx, JxBy, JxBz, JCrossB, GradP, &
                               jGradRho, jGradZeta, jGradTheta
    !!!! Module Subroutine/Function
    use ModRamGSL,       ONLY: GSL_Derivs
    !!!! NR Modules
    use nrtype,    ONLY: DP


    implicit none

    INTEGER :: i, j, k, id, ierr, idealerr, GSLerr
    CHARACTER(len=200) :: FileName

    REAL(DP) :: normDiffRel, volume

    REAL(DP), ALLOCATABLE :: jGradRhoPartialTheta(:,:,:), derivjGradRhoPartialTheta(:,:,:), &
                             jGradRhoPartialZeta(:,:,:), derivjGradRhoPartialZeta(:,:,:), &
                             jGradZetaPartialRho(:,:,:), derivjGradZetaPartialRho(:,:,:), &
                             jGradZetaPartialTheta(:,:,:), derivjGradZetaPartialTheta(:,:,:), &
                             jGradThetaPartialRho(:,:,:), derivjGradThetaPartialRho(:,:,:), &
                             jGradThetaPartialZeta(:,:,:), derivjGradThetaPartialZeta(:,:,:), &
                             derivDiffPTheta(:,:,:), jCrossBMinusGradPMod(:,:,:), &
                             derivNU1(:,:,:), derivNU2(:,:,:)

    !==============================================================================================
    ALLOCATE(jGradRhoPartialTheta(nthe,npsi,nzeta), derivjGradRhoPartialTheta(nthe,npsi,nzeta), &
             jGradRhoPartialZeta(nthe,npsi,nzeta), derivjGradRhoPartialZeta(nthe,npsi,nzeta), &
             jGradZetaPartialRho(nthe,npsi,nzeta), derivjGradZetaPartialRho(nthe,npsi,nzeta), &
             jGradZetaPartialTheta(nthe,npsi,nzeta), derivjGradZetaPartialTheta(nthe,npsi,nzeta), &
             jGradThetaPartialRho(nthe,npsi,nzeta), derivjGradThetaPartialRho(nthe,npsi,nzeta), &
             jGradThetaPartialZeta(nthe,npsi,nzeta), derivjGradThetaPartialZeta(nthe,npsi,nzeta), &
             derivDiffPTheta(nthe,npsi,nzeta), jCrossBMinusGradPMod(nthe,npsi,nzeta), &
             derivNU1(nthe,npsi,nzeta), derivNU2(nthe,npsi,nzeta))
    jGradRhoPartialTheta = 0.0; derivjGradRhoPartialTheta = 0.0
    jGradRhoPartialZeta = 0.0; derivjGradRhoPartialZeta = 0.0
    jGradZetaPartialRho = 0.0; derivjGradZetaPartialRho = 0.0
    jGradZetaPartialTheta = 0.0; derivjGradZetaPartialTheta = 0.0
    jGradThetaPartialRho = 0.0; derivjGradThetaPartialRho = 0.0
    jGradThetaPartialZeta = 0.0; derivjGradThetaPartialZeta = 0.0
    derivDiffPTheta = 0.0; jCrossBMinusGradPMod = 0.0
    derivNU1 = 0.0; derivNU2 = 0.0

    ! j dot gradRho
    DO j = 1, npsi
       DO k = 1, nzeta
          jGradRhoPartialTheta(:,j,k) = jacobian(:,j,k) * f(j) * fzet(k) &
                                      * (gradRhoSq(:,j,k) * gradThetaGradZeta(:,j,k) &
                                      - gradRhoGradTheta(:,j,k) * gradRhoGradZeta(:,j,k))
          jGradRhoPartialZeta(:,j,k) = jacobian(:,j,k) * f(j) * fzet(k) &
                                     * (gradRhoSq(:,j,k) * gradZetaSq(:,j,k) &
                                     - gradRhoGradZeta(:,j,k) **2)
       END DO
    END DO

    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jGradRhoPartialTheta, &
                    derivjGradRhoPartialTheta, derivNU1, derivNU2, GSLerr)
    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jGradRhoPartialZeta, &
                    derivNU1, derivNU2, derivjGradRhoPartialZeta, GSLerr)

    jGradRho = (derivjGradRhoPartialTheta + derivjGradRhoPartialZeta)/jacobian

    ! j dot gradZeta
    DO j = 1, npsi
       DO k = 1, nzeta
          jGradZetaPartialRho(:,j,k) = jacobian(:,j,k) * f(j) * fzet(k) &
                                     * (gradRhoGradZeta(:,j,k)**2 &
                                     - gradRhoSq(:,j,k) * gradZetaSq(:,j,k))
          jGradZetaPartialTheta(:,j,k) = jacobian(:,j,k) * f(j) * fzet(k) &
                                       * (gradRhoGradZeta(:,j,k) * gradThetaGradZeta(:,j,k) &
                                       - gradRhoGradTheta(:,j,k) * gradZetaSq(:,j,k))
       END DO
    END DO

    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jGradZetaPartialRho, &
                    derivNU1, derivjGradZetaPartialRho, derivNU2, GSLerr)
    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jGradZetaPartialTheta, &
                    derivjGradZetaPartialTheta, derivNU1, derivNU2, GSLerr)

    jGradZeta = (derivjGradZetaPartialRho + derivjGradZetaPartialTheta)/jacobian

    ! j dot gradTheta
    DO j = 1,npsi
       DO k = 1,nzeta
          jGradThetaPartialRho(:,j,k) = jacobian(:,j,k) * f(j) * fzet(k) &
                                      * (gradRhogradTheta(:,j,k) * gradRhogradZeta(:,j,k) &
                                      - gradThetagradZeta(:,j,k) * gradRhoSq(:,j,k))
          jGradThetaPartialZeta(:,j,k) = jacobian(:,j,k) * f(j) * fzet(k) &
                                       * (gradRhogradTheta(:,j,k) * gradZetaSq(:,j,k) &
                                       - gradRhogradZeta(:,j,k) * gradThetagradZeta(:,j,k))
       ENDDO
    ENDDO

    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jGradThetaPartialRho, &
                    derivNU1, derivjGradThetaPartialRho, derivNU2, GSLerr)
    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jGradThetaPartialZeta, &
                    derivNU1, derivNU2, derivjGradThetaPartialZeta, GSLerr)

    jGradTheta = (derivjGradThetaPartialRho + derivjGradThetaPartialZeta)/jacobian

    ! The one below is for calculating \partial Pper/\partial \theta and
    ! \partial(J(Pper-Ppar))/\partial \theta for the anisotropic case  
    CALL GSL_Derivs(thetaVal, rhoVal, zetaVal, jacobian(1:nthe,1:npsi,1:nzeta) * &
                    (pper(1:nthe,1:npsi,1:nzeta)-ppar(1:nthe,1:npsi,1:nzeta)), &
                    derivDiffPTheta, derivNU1, derivNU2, GSLerr)

    Jx = (JGradRho*derivXRho + JGradZeta*derivXZeta + JGradTheta*derivXTheta)
    Jy = (JGradRho*derivYRho + JGradZeta*derivYZeta + JGradTheta*derivYTheta)
    Jz = (JGradRho*derivZRho + JGradZeta*derivZZeta + JGradTheta*derivZTheta)
    DO k = 1, nzeta
       DO j = 1, npsi
          if (isotropy.eq.0) then
             GradPx(:,j,k) = (dPperdRho(:,j,k)*GradRhoSq(:,j,k) &
                            + dPperdZeta(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + dPperdTheta(:,j,k)*GradRhoGradTheta(:,j,k))*derivXRho(:,j,k) &
                           + (dPperdRho(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + dPperdZeta(:,j,k)*GradZetaSq(:,j,k) &
                            + dPperdTheta(:,j,k)*GradThetaGradZeta(:,j,k))*derivXZeta(:,j,k) &
                           + (dPperdRho(:,j,k)*GradRhoGradTheta(:,j,k) &
                            + dPperdZeta(:,j,k)*GradThetaGradZeta(:,j,k) &
                            + dPperdTheta(:,j,k)*GradThetaSq(:,j,k))*derivXTheta(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradRhoGradTheta(:,j,k)*derivXRho(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradThetaGradZeta(:,j,k)*derivXZeta(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradThetaSq(:,j,k)*derivXTheta(:,j,k)
             GradPy(:,j,k) = (dPperdRho(:,j,k)*GradRhoSq(:,j,k) &
                            + dPperdZeta(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + dPperdTheta(:,j,k)*GradRhoGradTheta(:,j,k))*derivYRho(:,j,k) &
                           + (dPperdRho(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + dPperdZeta(:,j,k)*GradZetaSq(:,j,k) &
                            + dPperdTheta(:,j,k)*GradThetaGradZeta(:,j,k))*derivYZeta(:,j,k) &
                           + (dPperdRho(:,j,k)*GradRhoGradTheta(:,j,k) &
                            + dPperdZeta(:,j,k)*GradThetaGradZeta(:,j,k) &
                            + dPperdTheta(:,j,k)*GradThetaSq(:,j,k))*derivYTheta(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradRhoGradTheta(:,j,k)*derivYRho(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradThetaGradZeta(:,j,k)*derivYZeta(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradThetaSq(:,j,k)*derivYTheta(:,j,k)
             GradPz(:,j,k) = (dPperdRho(:,j,k)*GradRhoSq(:,j,k) &
                            + dPperdZeta(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + dPperdTheta(:,j,k)*GradRhoGradTheta(:,j,k))*derivZRho(:,j,k) &
                           + (dPperdRho(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + dPperdZeta(:,j,k)*GradZetaSq(:,j,k) &
                            + dPperdTheta(:,j,k)*GradThetaGradZeta(:,j,k))*derivZZeta(:,j,k) &
                           + (dPperdRho(:,j,k)*GradRhoGradTheta(:,j,k) &
                            + dPperdZeta(:,j,k)*GradThetaGradZeta(:,j,k) &
                            + dPperdTheta(:,j,k)*GradThetaSq(:,j,k))*derivZTheta(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradRhoGradTheta(:,j,k)*derivZRho(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradThetaGradZeta(:,j,k)*derivZZeta(:,j,k) &
                           + derivDiffPTheta(:,j,k)*GradThetaSq(:,j,k)*derivZTheta(:,j,k)
          else
             GradPx(:,j,k) = (f(j)*dPdPsi(:,j,k)*GradRhoSq(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradRhoGradZeta(:,j,k))*derivXRho(:,j,k) &
                           + (f(j)*dPdPsi(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradZetaSq(:,j,k))*derivXZeta(:,j,k) &
                           + (f(j)*dPdPsi(:,j,k)*GradRhoGradTheta(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradThetaGradZeta(:,j,k))*derivXTheta(:,j,k)
             GradPy(:,j,k) = (f(j)*dPdPsi(:,j,k)*GradRhoSq(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradRhoGradZeta(:,j,k))*derivYRho(:,j,k) &
                           + (f(j)*dPdPsi(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradZetaSq(:,j,k))*derivYZeta(:,j,k) &
                           + (f(j)*dPdPsi(:,j,k)*GradRhoGradTheta(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradThetaGradZeta(:,j,k))*derivYTheta(:,j,k)
             GradPz(:,j,k) = (f(j)*dPdPsi(:,j,k)*GradRhoSq(:,j,k) &
                             + fzet(k)*dPdAlpha(:,j,k)*GradRhoGradZeta(:,j,k))*derivZRho(:,j,k) &
                            + (f(j)*dPdPsi(:,j,k)*GradRhoGradZeta(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradZetaSq(:,j,k))*derivZZeta(:,j,k) &
                           + (f(j)*dPdPsi(:,j,k)*GradRhoGradTheta(:,j,k) &
                            + fzet(k)*dPdAlpha(:,j,k)*GradThetaGradZeta(:,j,k))*derivZTheta(:,j,k)
          endif
       ENDDO
    ENDDO
do i = 2,nthe-1
do j = 1,npsi
do k = 1,nzeta
if (JGradRho(i,j,k).ne.JGradRho(i,j,k)) write(*,*) 'Jx', i, j, k
if (JGradZeta(i,j,k).ne.JGradZeta(i,j,k)) write(*,*) 'Jy', i, j, k
if (JGradTheta(i,j,k).ne.JGradTheta(i,j,k)) write(*,*) 'Jz', i, j, k
if (Bx(i,j,k).ne.Bx(i,j,k)) write(*,*) 'Bx', i, j, k
if (By(i,j,k).ne.By(i,j,k)) write(*,*) 'By', i, j, k
if (Bz(i,j,k).ne.Bz(i,j,k)) write(*,*) 'Bz', i, j, k
enddo
enddo
enddo

    JxBx = Jy*Bz-Jz*By
    JxBy = Jz*Bx-Jx*Bz
    JxBz = Jx*By-Jy*Bx

    jCrossB = sqrt(JxBx**2+JxBy**2+JxBz**2)
    gradP = sqrt(GradPx**2+GradPy**2+GradPz**2)

    GradPx = GradPx * pnormal*2
    GradPy = GradPy * pnormal*2
    GradPz = GradPz * pnormal*2
    Bx = Bx * bnormal
    By = By * bnormal
    Bz = Bz * bnormal
    Jx = Jx * pjconst*6.4
    Jy = Jy * pjconst*6.4
    Jz = Jz * pjconst*6.4
    jCrossB = jCrossB*bnormal*pjconst*6.4
    GradP   = GradP*pnormal
    jCrossBMinusGradPMod = jCrossB-GradP

    normDiff = 0.0_dp
    normDiffRel = 0.0_dp
    normJxB  = 0.0_dp
    normGradP = 0.0_dp
    volume   = 0.0_dp
    DO i = 2, nthe-1
       DO j = 2, npsi
          DO k = 2, nzeta
             IF (2.*pper(i,j,k) > 1.E-5*bsq(i,j,k)) THEN
                ! In regions of low plasma beta, the pressure does not change the magnetic field
                normDiff = normDiff + jacobian(i,j,k) * dr * dpPrime * dt * jCrossBMinusGradPMod(i,j,k)
                normDiffRel = normDiffRel + jacobian(i,j,k) * dr * dpPrime * dt * jCrossBMinusGradPMod(i,j,k) / jCrossB(i,j,k)
                normJxB = normJxB + jacobian(i,j,k) * dr * dpPrime * dt * jCrossB(i,j,k)
                normGradP = normGradP + jacobian(i,j,k) * dr * dpPrime * dt * gradP(i,j,k)
                volume = volume + jacobian(i,j,k) * dr * dpPrime * dt
             END IF
          END DO
       END DO
    END DO
  
    ! Normalize to total computational volume
    normDiff = normDiff/volume
    normJxB = normJxB/volume
    normGradP = normGradP/volume
  
    !  Norms of |jxB-grad P|,      |jxB|,      |gradP| 
    if (verbose) WRITE(*, *) normDiff, normJxB, normGradP
    if ((normDiff.ne.normDiff).or.(normJxB.ne.normJxB).or.(normGradP.ne.normGradP)) then
     !call con_stop('NaN encountered in ModScbIO.write_convergence subroutine')
     SORFail = .true.
    endif

    DEALLOCATE(jGradRhoPartialTheta, derivjGradRhoPartialTheta, &
               jGradRhoPartialZeta, derivjGradRhoPartialZeta, &
               jGradZetaPartialRho, derivjGradZetaPartialRho, &
               jGradZetaPartialTheta, derivjGradZetaPartialTheta, &
               jGradThetaPartialRho, derivjGradThetaPartialRho, &
               jGradThetaPartialZeta, derivjGradThetaPartialZeta, &
               derivDiffPTheta, jCrossBMinusGradPMod, &
               derivNU1, derivNU2)

    return

  END SUBROUTINE Compute_Convergence
!=================================================================================================!

END MODULE ModScbCompute
