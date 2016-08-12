/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * controllerDp_types.h
 *
 * Code generation for function 'controllerDp'
 *
 */

#ifndef __CONTROLLERDP_TYPES_H__
#define __CONTROLLERDP_TYPES_H__

/* Include files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef struct_emxArray__common
#define struct_emxArray__common

struct emxArray__common
{
  void *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
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
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};

#endif                                 /*struct_emxArray_real_T*/

#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T

typedef struct emxArray_real_T emxArray_real_T;

#endif                                 /*typedef_emxArray_real_T*/

#ifndef struct_emxArray_real_T_1x17
#define struct_emxArray_real_T_1x17

struct emxArray_real_T_1x17
{
  real_T data[17];
  int32_T size[2];
};

#endif                                 /*struct_emxArray_real_T_1x17*/

#ifndef typedef_emxArray_real_T_1x17
#define typedef_emxArray_real_T_1x17

typedef struct emxArray_real_T_1x17 emxArray_real_T_1x17;

#endif                                 /*typedef_emxArray_real_T_1x17*/

#ifndef typedef_struct1_T
#define typedef_struct1_T

typedef struct {
  real_T horizon;
  real_T stepsPerHour;
  real_T batteryEtaC;
  real_T batteryEtaD;
  real_T minCostDiff;
  real_T importPrice;
  real_T exportPriceLow;
  real_T exportPriceHigh;
  real_T firstHighPeriod;
  real_T lastHighPeriod;
  real_T batteryChargingFactor;
  real_T eps;
  boolean_T updateBattValue;
} struct1_T;

#endif                                 /*typedef_struct1_T*/

#ifndef typedef_struct2_T
#define typedef_struct2_T

typedef struct {
  real_T costPerKwhUsed;
  char_T damageModel[5];
  real_T nominalCycleLife;
  real_T nominalDoD;
  real_T maxLifeHours;
} struct2_T;

#endif                                 /*typedef_struct2_T*/

#ifndef typedef_struct3_T
#define typedef_struct3_T

typedef struct {
  real_T seasonalPeriod;
} struct3_T;

#endif                                 /*typedef_struct3_T*/

#ifndef typedef_struct4_T
#define typedef_struct4_T

typedef struct {
  real_T statesPerKwh;
} struct4_T;

#endif                                 /*typedef_struct4_T*/

#ifndef typedef_struct0_T
#define typedef_struct0_T

typedef struct {
  struct1_T sim;
  struct2_T bat;
  struct3_T fc;
  char_T type[3];
  struct4_T opt;
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
  emxArray_real_T_1x17 statesInt;
  emxArray_real_T_1x17 statesKwh;
  real_T maxDischargeStep;
  real_T minDischargeStep;
  real_T eps;
  real_T cumulativeDamage;
  real_T cumulativeValue;
} struct5_T;

#endif                                 /*typedef_struct5_T*/
#endif

/* End of code generation (controllerDp_types.h) */
