/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: controllerDp_types.h
 *
 * MATLAB Coder version            : 3.0
 * C/C++ source code generated on  : 26-Jul-2016 18:11:24
 */

#ifndef __CONTROLLERDP_TYPES_H__
#define __CONTROLLERDP_TYPES_H__

/* Include Files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef struct_emxArray__common
#define struct_emxArray__common

struct emxArray__common
{
  void *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray__common*/

#ifndef typedef_emxArray__common
#define typedef_emxArray__common

typedef struct emxArray__common emxArray__common;

#endif                                 /*typedef_emxArray__common*/

#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T

struct emxArray_real_T
{
  double *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real_T*/

#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T

typedef struct emxArray_real_T emxArray_real_T;

#endif                                 /*typedef_emxArray_real_T*/

#ifndef typedef_struct1_T
#define typedef_struct1_T

typedef struct {
  double horizon;
  double stepsPerHour;
  double batteryEtaD;
  double batteryEtaC;
  double batteryChargingFactor;
  double minCostDiff;
  double eps;
} struct1_T;

#endif                                 /*typedef_struct1_T*/

#ifndef typedef_struct2_T
#define typedef_struct2_T

typedef struct {
  double costPerKwhUsed;
} struct2_T;

#endif                                 /*typedef_struct2_T*/

#ifndef typedef_struct3_T
#define typedef_struct3_T

typedef struct {
  double statesPerKwh;
} struct3_T;

#endif                                 /*typedef_struct3_T*/

#ifndef typedef_struct4_T
#define typedef_struct4_T

typedef struct {
  double trainRatio;
  double nNodes;
} struct4_T;

#endif                                 /*typedef_struct4_T*/

#ifndef typedef_struct0_T
#define typedef_struct0_T

typedef struct {
  struct1_T sim;
  struct2_T bat;
  char type[3];
  struct3_T opt;
  struct4_T fc;
} struct0_T;

#endif                                 /*typedef_struct0_T*/

#ifndef typedef_struct5_T
#define typedef_struct5_T

typedef struct {
  struct0_T cfg;
  double SoC;
  double state;
  double capacity;
  double maxChargeRate;
  double increment;
  double statesInt[17];
  double statesKwh[17];
  double maxDischargeStep;
  double minDischargeStep;
  double eps;
  double cumulativeDamage;
  double cumulativeValue;
} struct5_T;

#endif                                 /*typedef_struct5_T*/
#endif

/*
 * File trailer for controllerDp_types.h
 *
 * [EOF]
 */
