/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_controllerDp_api.h
 *
 * MATLAB Coder version            : 3.0
 * C/C++ source code generated on  : 26-Jul-2016 18:11:24
 */

#ifndef ___CODER_CONTROLLERDP_API_H__
#define ___CODER_CONTROLLERDP_API_H__

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_controllerDp_api.h"

/* Type Definitions */
#ifndef typedef_struct1_T
#define typedef_struct1_T

typedef struct {
  real_T horizon;
  real_T stepsPerHour;
  real_T batteryEtaD;
  real_T batteryEtaC;
  real_T batteryChargingFactor;
  real_T minCostDiff;
  real_T eps;
} struct1_T;

#endif                                 /*typedef_struct1_T*/

#ifndef typedef_struct2_T
#define typedef_struct2_T

typedef struct {
  real_T costPerKwhUsed;
} struct2_T;

#endif                                 /*typedef_struct2_T*/

#ifndef typedef_struct3_T
#define typedef_struct3_T

typedef struct {
  real_T statesPerKwh;
} struct3_T;

#endif                                 /*typedef_struct3_T*/

#ifndef typedef_struct4_T
#define typedef_struct4_T

typedef struct {
  real_T trainRatio;
  real_T nNodes;
} struct4_T;

#endif                                 /*typedef_struct4_T*/

#ifndef typedef_struct0_T
#define typedef_struct0_T

typedef struct {
  struct1_T sim;
  struct2_T bat;
  char_T type[3];
  struct3_T opt;
  struct4_T fc;
} struct0_T;

#endif                                 /*typedef_struct0_T*/

#ifndef typedef_struct5_T
#define typedef_struct5_T

typedef struct {
  struct0_T cfg;
  real_T SoC;
  real_T state;
  real_T capacity;
  real_T maxChargeRate;
  real_T increment;
  real_T statesInt[17];
  real_T statesKwh[17];
  real_T maxDischargeStep;
  real_T minDischargeStep;
  real_T eps;
  real_T cumulativeDamage;
  real_T cumulativeValue;
} struct5_T;

#endif                                 /*typedef_struct5_T*/

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void controllerDp(struct0_T *cfg, real_T demForecast[48], real_T
  pvForecast[48], struct5_T *battery, real_T hourNow, real_T *bestDischargeStep,
  real_T *bestCTG);
extern void controllerDp_api(const mxArray *prhs[5], const mxArray *plhs[2]);
extern void controllerDp_atexit(void);
extern void controllerDp_initialize(void);
extern void controllerDp_terminate(void);
extern void controllerDp_xil_terminate(void);

#endif

/*
 * File trailer for _coder_controllerDp_api.h
 *
 * [EOF]
 */
