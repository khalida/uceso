/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: controllerDp.h
 *
 * MATLAB Coder version            : 3.0
 * C/C++ source code generated on  : 26-Jul-2016 18:11:24
 */

#ifndef __CONTROLLERDP_H__
#define __CONTROLLERDP_H__

/* Include Files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "rtwtypes.h"
#include "controllerDp_types.h"

/* Function Declarations */
extern void controllerDp(const struct0_T *cfg, const double demForecast[48],
  const double pvForecast[48], const struct5_T *battery, double hourNow, double *
  bestDischargeStep, double *bestCTG);

#endif

/*
 * File trailer for controllerDp.h
 *
 * [EOF]
 */
