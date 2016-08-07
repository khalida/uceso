/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * controllerDp.h
 *
 * Code generation for function 'controllerDp'
 *
 */

#ifndef __CONTROLLERDP_H__
#define __CONTROLLERDP_H__

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mwmathutil.h"
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blas.h"
#include "rtwtypes.h"
#include "controllerDp_types.h"

/* Function Declarations */
extern void controllerDp(const emlrtStack *sp, const struct0_T *cfg, const
  real_T demForecast[48], const real_T pvForecast[48], const struct5_T *battery,
  real_T hourNow, real_T *bestDischargeStep, real_T *bestCTG);

#endif

/* End of code generation (controllerDp.h) */
