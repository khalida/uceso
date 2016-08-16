/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_controllerDp_api.c
 *
 * Code generation for function '_coder_controllerDp_api'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "controllerDp.h"
#include "_coder_controllerDp_api.h"
#include "controllerDp_data.h"

/* Function Declarations */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, struct0_T *y);
static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, struct1_T *y);
static const mxArray *c_emlrt_marshallOut(const real_T u);
static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static boolean_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId);
static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *cfg, const
  char_T *identifier, struct0_T *y);
static struct2_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId);
static void g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[5]);
static struct3_T h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId);
static void i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[3]);
static struct4_T j_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId);
static void k_emlrt_marshallIn(const emlrtStack *sp, const mxArray *demForecast,
  const char_T *identifier, real_T **y_data, int32_T y_size[2]);
static void l_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, real_T **y_data, int32_T y_size[2]);
static void m_emlrt_marshallIn(const emlrtStack *sp, const mxArray *battery,
  const char_T *identifier, struct5_T *y);
static void n_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, struct5_T *y);
static void o_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static void p_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, real_T y_data[], int32_T y_size[2]);
static real_T q_emlrt_marshallIn(const emlrtStack *sp, const mxArray *hourNow,
  const char_T *identifier);
static real_T r_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);
static boolean_T s_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId);
static void t_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[5]);
static void u_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[3]);
static void v_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, real_T **ret_data, int32_T ret_size[2]);
static void w_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);
static void x_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, real_T ret_data[], int32_T ret_size[2]);

/* Function Definitions */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, struct0_T *y)
{
  emlrtMsgIdentifier thisId;
  static const int32_T dims = 0;
  static const char * fieldNames[5] = { "sim", "bat", "fc", "type", "opt" };

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b(sp, parentId, u, 5, fieldNames, 0U, &dims);
  thisId.fIdentifier = "sim";
  c_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "sim")),
                     &thisId, &y->sim);
  thisId.fIdentifier = "bat";
  y->bat = f_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "bat")),
    &thisId);
  thisId.fIdentifier = "fc";
  y->fc = h_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "fc")),
    &thisId);
  thisId.fIdentifier = "type";
  i_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "type")),
                     &thisId, y->type);
  thisId.fIdentifier = "opt";
  y->opt = j_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "opt")),
    &thisId);
  emlrtDestroyArray(&u);
}

static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, struct1_T *y)
{
  emlrtMsgIdentifier thisId;
  static const int32_T dims = 0;
  static const char * fieldNames[13] = { "horizon", "stepsPerHour",
    "batteryEtaC", "batteryEtaD", "minCostDiff", "importPriceHigh",
    "importPriceLow", "exportPrice", "firstHighPeriod", "lastHighPeriod",
    "batteryChargingFactor", "eps", "updateBattValue" };

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b(sp, parentId, u, 13, fieldNames, 0U, &dims);
  thisId.fIdentifier = "horizon";
  y->horizon = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0,
    "horizon")), &thisId);
  thisId.fIdentifier = "stepsPerHour";
  y->stepsPerHour = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "stepsPerHour")), &thisId);
  thisId.fIdentifier = "batteryEtaC";
  y->batteryEtaC = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "batteryEtaC")), &thisId);
  thisId.fIdentifier = "batteryEtaD";
  y->batteryEtaD = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "batteryEtaD")), &thisId);
  thisId.fIdentifier = "minCostDiff";
  y->minCostDiff = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "minCostDiff")), &thisId);
  thisId.fIdentifier = "importPriceHigh";
  y->importPriceHigh = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "importPriceHigh")), &thisId);
  thisId.fIdentifier = "importPriceLow";
  y->importPriceLow = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "importPriceLow")), &thisId);
  thisId.fIdentifier = "exportPrice";
  y->exportPrice = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "exportPrice")), &thisId);
  thisId.fIdentifier = "firstHighPeriod";
  y->firstHighPeriod = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "firstHighPeriod")), &thisId);
  thisId.fIdentifier = "lastHighPeriod";
  y->lastHighPeriod = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "lastHighPeriod")), &thisId);
  thisId.fIdentifier = "batteryChargingFactor";
  y->batteryChargingFactor = d_emlrt_marshallIn(sp, emlrtAlias
    (emlrtGetFieldR2013a(sp, u, 0, "batteryChargingFactor")), &thisId);
  thisId.fIdentifier = "eps";
  y->eps = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "eps")),
    &thisId);
  thisId.fIdentifier = "updateBattValue";
  y->updateBattValue = e_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "updateBattValue")), &thisId);
  emlrtDestroyArray(&u);
}

static const mxArray *c_emlrt_marshallOut(const real_T u)
{
  const mxArray *y;
  const mxArray *m3;
  y = NULL;
  m3 = emlrtCreateDoubleScalar(u);
  emlrtAssign(&y, m3);
  return y;
}

static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = r_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static boolean_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId)
{
  boolean_T y;
  y = s_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *cfg, const
  char_T *identifier, struct0_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(sp, emlrtAlias(cfg), &thisId, y);
  emlrtDestroyArray(&cfg);
}

static struct2_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId)
{
  struct2_T y;
  emlrtMsgIdentifier thisId;
  static const int32_T dims = 0;
  static const char * fieldNames[5] = { "costPerKwhUsed", "damageModel",
    "nominalCycleLife", "nominalDoD", "maxLifeHours" };

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b(sp, parentId, u, 5, fieldNames, 0U, &dims);
  thisId.fIdentifier = "costPerKwhUsed";
  y.costPerKwhUsed = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "costPerKwhUsed")), &thisId);
  thisId.fIdentifier = "damageModel";
  g_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "damageModel")),
                     &thisId, y.damageModel);
  thisId.fIdentifier = "nominalCycleLife";
  y.nominalCycleLife = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "nominalCycleLife")), &thisId);
  thisId.fIdentifier = "nominalDoD";
  y.nominalDoD = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0,
    "nominalDoD")), &thisId);
  thisId.fIdentifier = "maxLifeHours";
  y.maxLifeHours = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "maxLifeHours")), &thisId);
  emlrtDestroyArray(&u);
  return y;
}

static void g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[5])
{
  t_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static struct3_T h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId)
{
  struct3_T y;
  emlrtMsgIdentifier thisId;
  static const int32_T dims = 0;
  static const char * fieldNames[1] = { "seasonalPeriod" };

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b(sp, parentId, u, 1, fieldNames, 0U, &dims);
  thisId.fIdentifier = "seasonalPeriod";
  y.seasonalPeriod = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "seasonalPeriod")), &thisId);
  emlrtDestroyArray(&u);
  return y;
}

static void i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[3])
{
  u_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static struct4_T j_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId)
{
  struct4_T y;
  emlrtMsgIdentifier thisId;
  static const int32_T dims = 0;
  static const char * fieldNames[1] = { "statesPerKwh" };

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b(sp, parentId, u, 1, fieldNames, 0U, &dims);
  thisId.fIdentifier = "statesPerKwh";
  y.statesPerKwh = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "statesPerKwh")), &thisId);
  emlrtDestroyArray(&u);
  return y;
}

static void k_emlrt_marshallIn(const emlrtStack *sp, const mxArray *demForecast,
  const char_T *identifier, real_T **y_data, int32_T y_size[2])
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  l_emlrt_marshallIn(sp, emlrtAlias(demForecast), &thisId, y_data, y_size);
  emlrtDestroyArray(&demForecast);
}

static void l_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, real_T **y_data, int32_T y_size[2])
{
  v_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y_data, y_size);
  emlrtDestroyArray(&u);
}

static void m_emlrt_marshallIn(const emlrtStack *sp, const mxArray *battery,
  const char_T *identifier, struct5_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  n_emlrt_marshallIn(sp, emlrtAlias(battery), &thisId, y);
  emlrtDestroyArray(&battery);
}

static void n_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, struct5_T *y)
{
  emlrtMsgIdentifier thisId;
  static const int32_T dims = 0;
  static const char * fieldNames[14] = { "cfg", "SoC", "state", "capacity",
    "maxChargeRate", "maxChargeEnergy", "increment", "statesInt", "statesKwh",
    "maxDischargeStep", "minDischargeStep", "eps", "cumulativeDamage",
    "cumulativeValue" };

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckStructR2012b(sp, parentId, u, 14, fieldNames, 0U, &dims);
  thisId.fIdentifier = "cfg";
  b_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "cfg")),
                     &thisId, &y->cfg);
  thisId.fIdentifier = "SoC";
  y->SoC = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "SoC")),
    &thisId);
  thisId.fIdentifier = "state";
  y->state = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0,
    "state")), &thisId);
  thisId.fIdentifier = "capacity";
  y->capacity = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0,
    "capacity")), &thisId);
  thisId.fIdentifier = "maxChargeRate";
  y->maxChargeRate = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u,
    0, "maxChargeRate")), &thisId);
  thisId.fIdentifier = "maxChargeEnergy";
  o_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0,
    "maxChargeEnergy")), &thisId);
  thisId.fIdentifier = "increment";
  y->increment = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0,
    "increment")), &thisId);
  thisId.fIdentifier = "statesInt";
  p_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "statesInt")),
                     &thisId, y->statesInt.data, y->statesInt.size);
  thisId.fIdentifier = "statesKwh";
  p_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "statesKwh")),
                     &thisId, y->statesKwh.data, y->statesKwh.size);
  thisId.fIdentifier = "maxDischargeStep";
  y->maxDischargeStep = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "maxDischargeStep")), &thisId);
  thisId.fIdentifier = "minDischargeStep";
  y->minDischargeStep = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "minDischargeStep")), &thisId);
  thisId.fIdentifier = "eps";
  y->eps = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp, u, 0, "eps")),
    &thisId);
  thisId.fIdentifier = "cumulativeDamage";
  y->cumulativeDamage = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "cumulativeDamage")), &thisId);
  thisId.fIdentifier = "cumulativeValue";
  y->cumulativeValue = d_emlrt_marshallIn(sp, emlrtAlias(emlrtGetFieldR2013a(sp,
    u, 0, "cumulativeValue")), &thisId);
  emlrtDestroyArray(&u);
}

static void o_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  w_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
}

static void p_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, real_T y_data[], int32_T y_size[2])
{
  x_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y_data, y_size);
  emlrtDestroyArray(&u);
}

static real_T q_emlrt_marshallIn(const emlrtStack *sp, const mxArray *hourNow,
  const char_T *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = d_emlrt_marshallIn(sp, emlrtAlias(hourNow), &thisId);
  emlrtDestroyArray(&hourNow);
  return y;
}

static real_T r_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  real_T ret;
  static const int32_T dims = 0;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 0U, &dims);
  ret = *(real_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static boolean_T s_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId)
{
  boolean_T ret;
  static const int32_T dims = 0;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "logical", false, 0U, &dims);
  ret = *mxGetLogicals(src);
  emlrtDestroyArray(&src);
  return ret;
}

static void t_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[5])
{
  static const int32_T dims[2] = { 1, 5 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "char", false, 2U, dims);
  emlrtImportCharArrayR2015b(sp, src, ret, 5);
  emlrtDestroyArray(&src);
}

static void u_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[3])
{
  static const int32_T dims[2] = { 1, 3 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "char", false, 2U, dims);
  emlrtImportCharArrayR2015b(sp, src, ret, 3);
  emlrtDestroyArray(&src);
}

static void v_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, real_T **ret_data, int32_T ret_size[2])
{
  int32_T iv3[2];
  boolean_T bv0[2] = { true, true };

  static const int32_T dims[2] = { 48, 48 };

  emlrtCheckVsBuiltInR2012b(sp, msgId, src, "double", false, 2U, dims, &bv0[0],
    iv3);
  ret_size[0] = iv3[0];
  ret_size[1] = iv3[1];
  *ret_data = (real_T *)mxGetData(src);
  emlrtDestroyArray(&src);
}

static void w_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  static const int32_T dims[2] = { 0, 0 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 2U, dims);
  emlrtDestroyArray(&src);
}

static void x_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, real_T ret_data[], int32_T ret_size[2])
{
  int32_T iv4[2];
  boolean_T bv1[2] = { false, true };

  static const int32_T dims[2] = { 1, 17 };

  emlrtCheckVsBuiltInR2012b(sp, msgId, src, "double", false, 2U, dims, &bv1[0],
    iv4);
  ret_size[0] = iv4[0];
  ret_size[1] = iv4[1];
  emlrtImportArrayR2015b(sp, src, (void *)ret_data, 8, false);
  emlrtDestroyArray(&src);
}

void controllerDp_api(const mxArray * const prhs[5], const mxArray *plhs[2])
{
  struct0_T cfg;
  int32_T demForecast_size[2];
  real_T (*demForecast_data)[2304];
  int32_T pvForecast_size[2];
  real_T (*pvForecast_data)[2304];
  struct5_T battery;
  real_T hourNow;
  real_T bestCTG;
  real_T bestDischargeStep;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "cfg", &cfg);
  k_emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "demForecast", (real_T **)
                     &demForecast_data, demForecast_size);
  k_emlrt_marshallIn(&st, emlrtAlias(prhs[2]), "pvForecast", (real_T **)
                     &pvForecast_data, pvForecast_size);
  m_emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "battery", &battery);
  hourNow = q_emlrt_marshallIn(&st, emlrtAliasP(prhs[4]), "hourNow");

  /* Invoke the target function */
  controllerDp(&st, &cfg, *demForecast_data, demForecast_size, *pvForecast_data,
               pvForecast_size, &battery, hourNow, &bestDischargeStep, &bestCTG);

  /* Marshall function outputs */
  plhs[0] = c_emlrt_marshallOut(bestDischargeStep);
  plhs[1] = c_emlrt_marshallOut(bestCTG);
}

/* End of code generation (_coder_controllerDp_api.c) */
