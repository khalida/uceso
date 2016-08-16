/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * controllerDp.c
 *
 * Code generation for function 'controllerDp'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "controllerDp.h"
#include "controllerDp_emxutil.h"
#include "controllerDp_data.h"

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 30, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRSInfo b_emlrtRSI = { 116, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRSInfo c_emlrtRSI = { 124, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRSInfo d_emlrtRSI = { 4, "getGridPrices",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\getGridPrices.m"
};

static emlrtMCInfo emlrtMCI = { 20, 5, "error",
  "C:\\Program Files\\MATLAB\\R2015b\\toolbox\\eml\\lib\\matlab\\lang\\error.m"
};

static emlrtRTEInfo emlrtRTEI = { 1, 41, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRTEInfo b_emlrtRTEI = { 17, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRTEInfo c_emlrtRTEI = { 18, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRTEInfo d_emlrtRTEI = { 27, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRTEInfo e_emlrtRTEI = { 28, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtBCInfo emlrtBCI = { -1, -1, 129, 30, "CTG", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo b_emlrtBCI = { -1, -1, 128, 42, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo c_emlrtBCI = { -1, -1, 110, 38, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo d_emlrtBCI = { -1, -1, 110, 22, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo emlrtDCI = { 110, 22, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtRTEInfo f_emlrtRTEI = { 100, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtBCInfo e_emlrtBCI = { -1, -1, 75, 17, "exportPrices", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo f_emlrtBCI = { -1, -1, 74, 23, "importPrices", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtRTEInfo g_emlrtRTEI = { 51, 9, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRTEInfo h_emlrtRTEI = { 36, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtRTEInfo i_emlrtRTEI = { 29, 1, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m"
};

static emlrtDCInfo b_emlrtDCI = { 18, 23, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtDCInfo c_emlrtDCI = { 18, 23, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  4 };

static emlrtDCInfo d_emlrtDCI = { 17, 22, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtDCInfo e_emlrtDCI = { 17, 22, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  4 };

static emlrtBCInfo g_emlrtBCI = { -1, -1, 121, 24, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo h_emlrtBCI = { -1, -1, 121, 50, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo f_emlrtDCI = { 121, 50, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo i_emlrtBCI = { -1, -1, 121, 50, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo j_emlrtBCI = { -1, -1, 122, 5, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo k_emlrtBCI = { -1, -1, 121, 1, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo l_emlrtBCI = { -1, -1, 123, 4, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo m_emlrtBCI = { -1, -1, 123, 30, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo n_emlrtBCI = { -1, -1, 128, 27, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo g_emlrtDCI = { 128, 27, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo o_emlrtBCI = { -1, -1, 129, 15, "CTG", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo h_emlrtDCI = { 129, 15, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo p_emlrtBCI = { -1, -1, 104, 20, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo q_emlrtBCI = { -1, -1, 104, 42, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo i_emlrtDCI = { 104, 42, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo r_emlrtBCI = { -1, -1, 104, 42, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo s_emlrtBCI = { -1, -1, 104, 58, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo t_emlrtBCI = { -1, -1, 104, 5, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo u_emlrtBCI = { -1, -1, 106, 13, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo j_emlrtDCI = { 106, 13, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo v_emlrtBCI = { -1, -1, 106, 13, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo w_emlrtBCI = { -1, -1, 106, 29, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo x_emlrtBCI = { -1, -1, 110, 22, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo y_emlrtBCI = { -1, -1, 107, 22, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo k_emlrtDCI = { 107, 22, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo ab_emlrtBCI = { -1, -1, 107, 22, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo bb_emlrtBCI = { -1, -1, 107, 38, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo cb_emlrtBCI = { -1, -1, 113, 21, "demForecast",
  "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo db_emlrtBCI = { -1, -1, 113, 45, "pvForecast", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo eb_emlrtBCI = { -1, -1, 113, 5, "gridImport", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo fb_emlrtBCI = { -1, -1, 115, 8, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo gb_emlrtBCI = { -1, -1, 115, 28, "q_t_state", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo hb_emlrtBCI = { -1, -1, 89, 14, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo ib_emlrtBCI = { -1, -1, 89, 17, "ST_b", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo jb_emlrtBCI = { -1, -1, 90, 13, "CTG", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo kb_emlrtBCI = { -1, -1, 90, 16, "CTG", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo lb_emlrtBCI = { -1, -1, 61, 19, "demForecast", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo mb_emlrtBCI = { -1, -1, 61, 43, "pvForecast", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo nb_emlrtBCI = { -1, -1, 78, 37, "CTG", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtDCInfo l_emlrtDCI = { 78, 37, "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  1 };

static emlrtBCInfo ob_emlrtBCI = { -1, -1, 78, 46, "CTG", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo pb_emlrtBCI = { -1, -1, 30, 6, "importPrices", "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtBCInfo qb_emlrtBCI = { -1, -1, 30, 23, "exportPrices",
  "controllerDp",
  "C:\\LocalData\\Documents\\Documents\\PhD\\21_Projects\\2016_04_07_uceso\\functions\\controllerDp.m",
  0 };

static emlrtRSInfo e_emlrtRSI = { 20, "error",
  "C:\\Program Files\\MATLAB\\R2015b\\toolbox\\eml\\lib\\matlab\\lang\\error.m"
};

/* Function Declarations */
static void error(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location);

/* Function Definitions */
static void error(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLABR2012b(sp, 0, NULL, 1, &pArray, "error", true, location);
}

void controllerDp(const emlrtStack *sp, const struct0_T *cfg, const real_T
                  demForecast_data[], const int32_T demForecast_size[2], const
                  real_T pvForecast_data[], const int32_T pvForecast_size[2],
                  const struct5_T *battery, real_T hourNow, real_T
                  *bestDischargeStep, real_T *bestCTG)
{
  emxArray_real_T *CTG;
  int32_T varargin_2;
  real_T nStages;
  int32_T i0;
  real_T d0;
  int32_T loop_ub;
  emxArray_real_T *ST_b;
  emxArray_real_T *importPrices;
  real_T b_min_int;
  real_T b_max_int;
  emxArray_real_T *exportPrices;
  int32_T t;
  real_T x;
  static const char_T varargin_1[27] = { 'H', 'o', 'u', 'r', ' ', 'i', 'n', 'd',
    'e', 'x', ' ', 'i', 's', ' ', 'o', 'u', 't', ' ', 'o', 'f', ' ', 'b', 'o',
    'u', 'n', 'd', 's' };

  char_T u[27];
  const mxArray *y;
  static const int32_T iv0[2] = { 1, 27 };

  const mxArray *m0;
  real_T b_t;
  int32_T q;
  real_T bestB;
  real_T this_b_min_int;
  real_T this_b_max_int;
  int32_T thisB;
  real_T b_thisB;
  real_T b_hat;
  int32_T i1;
  int32_T i2;
  int32_T i3;
  real_T g_t;
  real_T thisCTG;
  boolean_T guard2 = false;
  static const char_T b_varargin_1[27] = { 'B', 'a', 't', 't', 'e', 'r', 'y',
    ' ', 's', 't', 'a', 't', 'e', ' ', 'o', 'u', 't', ' ', 'o', 'f', ' ', 'b',
    'o', 'u', 'n', 'd', 's' };

  char_T b_u[27];
  const mxArray *b_y;
  static const int32_T iv1[2] = { 1, 27 };

  boolean_T guard1 = false;
  char_T c_u[27];
  const mxArray *c_y;
  static const int32_T iv2[2] = { 1, 27 };

  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T(sp, &CTG, 2, &b_emlrtRTEI, true);

  /*  controllerDp: Solve dynamic program for the curent horizon, to */
  /*  minimise costs */
  /*  Positive b is DISCHARGING the battery! */
  /*  persistent doneHorizonPlot; */
  /* % Initialise Values */
  varargin_2 = battery->statesInt.size[1];
  nStages = cfg->sim.horizon;

  /*  Initialise array of costs to go (NB: cost from last stage is zero in */
  /*  all possible states) */
  i0 = CTG->size[0] * CTG->size[1];
  CTG->size[0] = battery->statesInt.size[1];
  d0 = cfg->sim.horizon + 1.0;
  if (!(d0 > 0.0)) {
    emlrtNonNegativeCheckR2012b(d0, &e_emlrtDCI, sp);
  }

  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &d_emlrtDCI, sp);
  }

  CTG->size[1] = (int32_T)d0;
  emxEnsureCapacity(sp, (emxArray__common *)CTG, i0, (int32_T)sizeof(real_T),
                    &emlrtRTEI);
  d0 = cfg->sim.horizon + 1.0;
  if (!(d0 > 0.0)) {
    emlrtNonNegativeCheckR2012b(d0, &e_emlrtDCI, sp);
  }

  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &d_emlrtDCI, sp);
  }

  loop_ub = battery->statesInt.size[1] * (int32_T)d0;
  for (i0 = 0; i0 < loop_ub; i0++) {
    CTG->data[i0] = 0.0;
  }

  emxInit_real_T(sp, &ST_b, 2, &c_emlrtRTEI, true);
  i0 = ST_b->size[0] * ST_b->size[1];
  ST_b->size[0] = battery->statesInt.size[1];
  d0 = cfg->sim.horizon;
  if (!(d0 > 0.0)) {
    emlrtNonNegativeCheckR2012b(d0, &c_emlrtDCI, sp);
  }

  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &b_emlrtDCI, sp);
  }

  ST_b->size[1] = (int32_T)d0;
  emxEnsureCapacity(sp, (emxArray__common *)ST_b, i0, (int32_T)sizeof(real_T),
                    &emlrtRTEI);
  d0 = cfg->sim.horizon;
  if (!(d0 > 0.0)) {
    emlrtNonNegativeCheckR2012b(d0, &c_emlrtDCI, sp);
  }

  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &b_emlrtDCI, sp);
  }

  loop_ub = battery->statesInt.size[1] * (int32_T)d0;
  for (i0 = 0; i0 < loop_ub; i0++) {
    ST_b->data[i0] = 0.0;
  }

  emxInit_real_T1(sp, &importPrices, 1, &d_emlrtRTEI, true);

  /*  Limits on battery rate-of-charge: */
  /*  kWh/interval */
  /*  kWh/interval */
  b_min_int = muDoubleScalarFloor(-battery->maxChargeRate /
    cfg->sim.stepsPerHour / battery->increment);

  /*  No. charge increments */
  b_max_int = muDoubleScalarCeil(battery->maxChargeRate / cfg->sim.stepsPerHour /
    battery->increment);

  /*  No. charge increments */
  /*  Get the grid prices: */
  i0 = importPrices->size[0];
  importPrices->size[0] = (int32_T)cfg->sim.horizon;
  emxEnsureCapacity(sp, (emxArray__common *)importPrices, i0, (int32_T)sizeof
                    (real_T), &emlrtRTEI);
  loop_ub = (int32_T)cfg->sim.horizon;
  for (i0 = 0; i0 < loop_ub; i0++) {
    importPrices->data[i0] = 0.0;
  }

  emxInit_real_T1(sp, &exportPrices, 1, &e_emlrtRTEI, true);
  i0 = exportPrices->size[0];
  exportPrices->size[0] = (int32_T)cfg->sim.horizon;
  emxEnsureCapacity(sp, (emxArray__common *)exportPrices, i0, (int32_T)sizeof
                    (real_T), &emlrtRTEI);
  loop_ub = (int32_T)cfg->sim.horizon;
  for (i0 = 0; i0 < loop_ub; i0++) {
    exportPrices->data[i0] = 0.0;
  }

  emlrtForLoopVectorCheckR2012b(1.0, 1.0, cfg->sim.horizon, mxDOUBLE_CLASS,
    (int32_T)cfg->sim.horizon, &i_emlrtRTEI, sp);
  t = 0;
  while (t <= (int32_T)nStages - 1) {
    x = (hourNow + (1.0 + (real_T)t)) - 1.0;
    if (cfg->sim.horizon == 0.0) {
    } else if (cfg->sim.horizon == muDoubleScalarFloor(cfg->sim.horizon)) {
      x -= muDoubleScalarFloor(x / cfg->sim.horizon) * cfg->sim.horizon;
    } else {
      x /= cfg->sim.horizon;
      if (muDoubleScalarAbs(x - muDoubleScalarRound(x)) <=
          2.2204460492503131E-16 * muDoubleScalarAbs(x)) {
        x = 0.0;
      } else {
        x = (x - muDoubleScalarFloor(x)) * cfg->sim.horizon;
      }
    }

    st.site = &emlrtRSI;
    if ((x > cfg->fc.seasonalPeriod - 1.0) || (x < 0.0)) {
      b_st.site = &d_emlrtRSI;
      for (i0 = 0; i0 < 27; i0++) {
        u[i0] = varargin_1[i0];
      }

      y = NULL;
      m0 = emlrtCreateCharArray(2, iv0);
      emlrtInitCharArrayR2013a(&b_st, 27, m0, &u[0]);
      emlrtAssign(&y, m0);
      c_st.site = &e_emlrtRSI;
      error(&c_st, y, &emlrtMCI);
    }

    /*  getGridPrices: Look-up function to return the grid-prices: */
    /*  $/kWh */
    d0 = cfg->sim.importPriceLow;

    /*  $/kWh */
    /*  set imports to peak tarriff if required 7AM = 10PM */
    if ((x >= cfg->sim.firstHighPeriod) && (x <= cfg->sim.lastHighPeriod)) {
      d0 = cfg->sim.importPriceHigh;
    }

    i0 = importPrices->size[0];
    if (!((t + 1 >= 1) && (t + 1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(t + 1, 1, i0, &pb_emlrtBCI, sp);
    }

    importPrices->data[t] = d0;
    i0 = exportPrices->size[0];
    if (!((t + 1 >= 1) && (t + 1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(t + 1, 1, i0, &qb_emlrtBCI, sp);
    }

    exportPrices->data[t] = cfg->sim.exportPrice;
    t++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  /*  Work back through previous stages and find minimum cost to go */
  /*  store the chosen charge decision in ST_b */
  emlrtForLoopVectorCheckR2012b(cfg->sim.horizon, -1.0, 1.0, mxDOUBLE_CLASS,
    (int32_T)-(1.0 + (-1.0 - cfg->sim.horizon)), &h_emlrtRTEI, sp);
  t = 0;
  while (t <= (int32_T)-(1.0 + (-1.0 - nStages)) - 1) {
    b_t = nStages + -(real_T)t;

    /*  For all possible starting states */
    q = 0;
    while (q <= battery->statesInt.size[1] - 1) {
      /*  Initialise bestCTG to large value  */
      /*  and best discharge to infeasible value */
      *bestCTG = rtInf;
      bestB = rtInf;

      /*  Further constrain minimum and maximum b (charging energy) */
      this_b_min_int = muDoubleScalarMax(b_min_int, (q - varargin_2) + 1);
      this_b_max_int = muDoubleScalarMin(b_max_int, (1.0 + (real_T)q) - 1.0);

      /*  For each feasible discharging decision check the resulting CTG */
      i0 = (int32_T)(this_b_max_int + (1.0 - this_b_min_int));
      emlrtForLoopVectorCheckR2012b(this_b_min_int, 1.0, this_b_max_int,
        mxDOUBLE_CLASS, i0, &g_emlrtRTEI, sp);
      thisB = 0;
      while (thisB <= i0 - 1) {
        b_thisB = this_b_min_int + (real_T)thisB;

        /*  Find net power from battery (account for losses) */
        if (b_thisB > 0.0) {
          b_hat = b_thisB * battery->increment * cfg->sim.batteryEtaD;
        } else {
          b_hat = b_thisB * battery->increment / cfg->sim.batteryEtaC;
        }

        /*  Find energy from grid during interval */
        i1 = demForecast_size[0] * demForecast_size[1];
        i2 = (int32_T)b_t;
        if (!((i2 >= 1) && (i2 <= i1))) {
          emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &lb_emlrtBCI, sp);
        }

        i1 = pvForecast_size[0] * pvForecast_size[1];
        i3 = (int32_T)b_t;
        if (!((i3 >= 1) && (i3 <= i1))) {
          emlrtDynamicBoundsCheckR2012b(i3, 1, i1, &mb_emlrtBCI, sp);
        }

        g_t = (demForecast_data[i2 - 1] - b_hat) - pvForecast_data[i3 - 1];

        /*  Find battery damage cost */
        /* fracDegradation = calcFracDegradation(cfg, battery, q, ... */
        /*     thisB); */
        /* damageCost = fracDegradation*battery.Value(); */
        /*  Battery degradation cost (fixed per kWh-through-put): */
        /*  Total state transition cost for this decision from here */
        i1 = importPrices->size[0];
        i2 = (int32_T)b_t;
        if (!((i2 >= 1) && (i2 <= i1))) {
          emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &f_emlrtBCI, sp);
        }

        i1 = exportPrices->size[0];
        i2 = (int32_T)b_t;
        if (!((i2 >= 1) && (i2 <= i1))) {
          emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &e_emlrtBCI, sp);
        }

        /*  Total cost-to-got for this decision from here to end */
        i1 = CTG->size[0];
        d0 = (1.0 + (real_T)q) - b_thisB;
        if (d0 != (int32_T)d0) {
          emlrtIntegerCheckR2012b(d0, &l_emlrtDCI, sp);
        }

        i2 = (int32_T)d0;
        if (!((i2 >= 1) && (i2 <= i1))) {
          emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &nb_emlrtBCI, sp);
        }

        i1 = CTG->size[1];
        i3 = (int32_T)b_t + 1;
        if (!((i3 >= 1) && (i3 <= i1))) {
          emlrtDynamicBoundsCheckR2012b(i3, 1, i1, &ob_emlrtBCI, sp);
        }

        thisCTG = ((importPrices->data[(int32_T)b_t - 1] * muDoubleScalarMax(0.0,
          g_t) - exportPrices->data[(int32_T)b_t - 1] * muDoubleScalarMax(0.0,
          -g_t)) + muDoubleScalarAbs(b_thisB) * battery->increment * 0.5 *
                   cfg->bat.costPerKwhUsed) + CTG->data[(i2 + CTG->size[0] * (i3
          - 1)) - 1];

        /*  Store decision if it's the best found so far */
        if (thisCTG < *bestCTG - cfg->sim.minCostDiff) {
          bestB = b_thisB;
          *bestCTG = thisCTG;
        }

        thisB++;
        if (*emlrtBreakCheckR2012bFlagVar != 0) {
          emlrtBreakCheckR2012b(sp);
        }
      }

      /*  Store the best discharging decision found */
      i0 = ST_b->size[0];
      if (!((q + 1 >= 1) && (q + 1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(q + 1, 1, i0, &hb_emlrtBCI, sp);
      }

      i0 = ST_b->size[1];
      i1 = (int32_T)b_t;
      if (!((i1 >= 1) && (i1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &ib_emlrtBCI, sp);
      }

      ST_b->data[q + ST_b->size[0] * (i1 - 1)] = bestB;
      i0 = CTG->size[0];
      if (!((q + 1 >= 1) && (q + 1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(q + 1, 1, i0, &jb_emlrtBCI, sp);
      }

      i0 = CTG->size[1];
      i1 = (int32_T)b_t;
      if (!((i1 >= 1) && (i1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &kb_emlrtBCI, sp);
      }

      CTG->data[q + CTG->size[0] * (i1 - 1)] = *bestCTG;
      q++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b(sp);
      }
    }

    t++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  /*  Create time-series of charge decisions, and SoC */
  i0 = importPrices->size[0];
  importPrices->size[0] = (int32_T)(cfg->sim.horizon + 1.0);
  emxEnsureCapacity(sp, (emxArray__common *)importPrices, i0, (int32_T)sizeof
                    (real_T), &emlrtRTEI);
  loop_ub = (int32_T)(cfg->sim.horizon + 1.0);
  for (i0 = 0; i0 < loop_ub; i0++) {
    importPrices->data[i0] = 0.0;
  }

  i0 = exportPrices->size[0];
  exportPrices->size[0] = (int32_T)cfg->sim.horizon;
  emxEnsureCapacity(sp, (emxArray__common *)exportPrices, i0, (int32_T)sizeof
                    (real_T), &emlrtRTEI);
  loop_ub = (int32_T)cfg->sim.horizon;
  for (i0 = 0; i0 < loop_ub; i0++) {
    exportPrices->data[i0] = 0.0;
  }

  importPrices->data[0] = battery->state;
  emlrtForLoopVectorCheckR2012b(2.0, 1.0, cfg->sim.horizon, mxDOUBLE_CLASS,
    (int32_T)(cfg->sim.horizon + -1.0), &f_emlrtRTEI, sp);
  t = 0;
  while (t <= (int32_T)(nStages + -1.0) - 1) {
    /*  DEBUGGING: */
    /*  disp('t-1: ');disp(t-1); */
    /*  disp('q_t_state(t-1): ');disp(q_t_state(t-1)); */
    i0 = importPrices->size[0];
    i1 = (int32_T)((2.0 + (real_T)t) - 1.0);
    if (!((i1 >= 1) && (i1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &p_emlrtBCI, sp);
    }

    i0 = ST_b->size[0];
    i2 = importPrices->size[0];
    i3 = (int32_T)((2.0 + (real_T)t) - 1.0);
    if (!((i3 >= 1) && (i3 <= i2))) {
      emlrtDynamicBoundsCheckR2012b(i3, 1, i2, &r_emlrtBCI, sp);
    }

    d0 = importPrices->data[i3 - 1];
    if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
      emlrtIntegerCheckR2012b(d0, &i_emlrtDCI, sp);
    }

    i2 = (int32_T)d0;
    if (!((i2 >= 1) && (i2 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &q_emlrtBCI, sp);
    }

    i0 = ST_b->size[1];
    i3 = (int32_T)((2.0 + (real_T)t) - 1.0);
    if (!((i3 >= 1) && (i3 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i3, 1, i0, &s_emlrtBCI, sp);
    }

    i0 = importPrices->size[0];
    loop_ub = (int32_T)(2.0 + (real_T)t);
    if (!((loop_ub >= 1) && (loop_ub <= i0))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i0, &t_emlrtBCI, sp);
    }

    importPrices->data[loop_ub - 1] = importPrices->data[i1 - 1] - ST_b->data
      [(i2 + ST_b->size[0] * (i3 - 1)) - 1];
    i0 = ST_b->size[0];
    i1 = importPrices->size[0];
    i2 = (int32_T)((2.0 + (real_T)t) - 1.0);
    if (!((i2 >= 1) && (i2 <= i1))) {
      emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &v_emlrtBCI, sp);
    }

    d0 = importPrices->data[i2 - 1];
    if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
      emlrtIntegerCheckR2012b(d0, &j_emlrtDCI, sp);
    }

    i1 = (int32_T)d0;
    if (!((i1 >= 1) && (i1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &u_emlrtBCI, sp);
    }

    i0 = ST_b->size[1];
    i2 = (int32_T)((2.0 + (real_T)t) - 1.0);
    if (!((i2 >= 1) && (i2 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &w_emlrtBCI, sp);
    }

    if (ST_b->data[(i1 + ST_b->size[0] * (i2 - 1)) - 1] > 0.0) {
      i0 = ST_b->size[0];
      i1 = importPrices->size[0];
      i2 = (int32_T)((2.0 + (real_T)t) - 1.0);
      if (!((i2 >= 1) && (i2 <= i1))) {
        emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &ab_emlrtBCI, sp);
      }

      d0 = importPrices->data[i2 - 1];
      if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
        emlrtIntegerCheckR2012b(d0, &k_emlrtDCI, sp);
      }

      i1 = (int32_T)d0;
      if (!((i1 >= 1) && (i1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &y_emlrtBCI, sp);
      }

      i0 = ST_b->size[1];
      i2 = (int32_T)((2.0 + (real_T)t) - 1.0);
      if (!((i2 >= 1) && (i2 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &bb_emlrtBCI, sp);
      }

      b_hat = ST_b->data[(i1 + ST_b->size[0] * (i2 - 1)) - 1] *
        battery->increment * cfg->sim.batteryEtaD;
    } else {
      i0 = ST_b->size[0];
      i1 = importPrices->size[0];
      i2 = (int32_T)((2.0 + (real_T)t) - 1.0);
      if (!((i2 >= 1) && (i2 <= i1))) {
        emlrtDynamicBoundsCheckR2012b(i2, 1, i1, &x_emlrtBCI, sp);
      }

      d0 = importPrices->data[i2 - 1];
      if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
        emlrtIntegerCheckR2012b(d0, &emlrtDCI, sp);
      }

      i1 = (int32_T)d0;
      if (!((i1 >= 1) && (i1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &d_emlrtBCI, sp);
      }

      i0 = ST_b->size[1];
      i1 = (int32_T)((2.0 + (real_T)t) - 1.0);
      if (!((i1 >= 1) && (i1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &c_emlrtBCI, sp);
      }

      b_hat = ST_b->data[((int32_T)importPrices->data[(int32_T)((2.0 + (real_T)t)
        - 1.0) - 1] + ST_b->size[0] * ((int32_T)((2.0 + (real_T)t) - 1.0) - 1))
        - 1] * battery->increment / cfg->sim.batteryEtaC;
    }

    i0 = demForecast_size[0] * demForecast_size[1];
    i1 = (int32_T)(2.0 + (real_T)t);
    if (!((i1 >= 1) && (i1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &cb_emlrtBCI, sp);
    }

    i0 = pvForecast_size[0] * pvForecast_size[1];
    i2 = (int32_T)(2.0 + (real_T)t);
    if (!((i2 >= 1) && (i2 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &db_emlrtBCI, sp);
    }

    i0 = exportPrices->size[0];
    i3 = (int32_T)(2.0 + (real_T)t);
    if (!((i3 >= 1) && (i3 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i3, 1, i0, &eb_emlrtBCI, sp);
    }

    exportPrices->data[i3 - 1] = (demForecast_data[i1 - 1] - b_hat) -
      pvForecast_data[i2 - 1];
    i0 = importPrices->size[0];
    i1 = (int32_T)(2.0 + (real_T)t);
    if (!((i1 >= 1) && (i1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &fb_emlrtBCI, sp);
    }

    guard2 = false;
    if (importPrices->data[i1 - 1] < 1.0) {
      guard2 = true;
    } else {
      i0 = importPrices->size[0];
      i1 = (int32_T)(2.0 + (real_T)t);
      if (!((i1 >= 1) && (i1 <= i0))) {
        emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &gb_emlrtBCI, sp);
      }

      if (importPrices->data[i1 - 1] > varargin_2) {
        guard2 = true;
      }
    }

    if (guard2) {
      st.site = &b_emlrtRSI;
      for (i0 = 0; i0 < 27; i0++) {
        b_u[i0] = b_varargin_1[i0];
      }

      b_y = NULL;
      m0 = emlrtCreateCharArray(2, iv1);
      emlrtInitCharArrayR2013a(&st, 27, m0, &b_u[0]);
      emlrtAssign(&b_y, m0);
      b_st.site = &e_emlrtRSI;
      error(&b_st, b_y, &emlrtMCI);
    }

    t++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  emxFree_real_T(&exportPrices);

  /*  Check ending SoC of battery */
  i0 = importPrices->size[0];
  i1 = (int32_T)cfg->sim.horizon;
  if (!((i1 >= 1) && (i1 <= i0))) {
    emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &g_emlrtBCI, sp);
  }

  i0 = ST_b->size[0];
  i2 = importPrices->size[0];
  i3 = (int32_T)cfg->sim.horizon;
  if (!((i3 >= 1) && (i3 <= i2))) {
    emlrtDynamicBoundsCheckR2012b(i3, 1, i2, &i_emlrtBCI, sp);
  }

  d0 = importPrices->data[i3 - 1];
  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &f_emlrtDCI, sp);
  }

  i2 = (int32_T)d0;
  if (!((i2 >= 1) && (i2 <= i0))) {
    emlrtDynamicBoundsCheckR2012b(i2, 1, i0, &h_emlrtBCI, sp);
  }

  i0 = ST_b->size[1];
  i3 = (int32_T)cfg->sim.horizon;
  if (!((i3 >= 1) && (i3 <= i0))) {
    emlrtDynamicBoundsCheckR2012b(i3, 1, i0, &j_emlrtBCI, sp);
  }

  i0 = importPrices->size[0];
  loop_ub = (int32_T)(cfg->sim.horizon + 1.0);
  if (!((loop_ub >= 1) && (loop_ub <= i0))) {
    emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i0, &k_emlrtBCI, sp);
  }

  importPrices->data[loop_ub - 1] = importPrices->data[i1 - 1] - ST_b->data[(i2
    + ST_b->size[0] * (i3 - 1)) - 1];
  i0 = importPrices->size[0];
  i1 = (int32_T)cfg->sim.horizon;
  if (!((i1 >= 1) && (i1 <= i0))) {
    emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &l_emlrtBCI, sp);
  }

  guard1 = false;
  if (importPrices->data[i1 - 1] < 1.0) {
    guard1 = true;
  } else {
    i0 = importPrices->size[0];
    i1 = (int32_T)cfg->sim.horizon;
    if (!((i1 >= 1) && (i1 <= i0))) {
      emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &m_emlrtBCI, sp);
    }

    if (importPrices->data[i1 - 1] > battery->statesInt.size[1]) {
      guard1 = true;
    }
  }

  if (guard1) {
    st.site = &c_emlrtRSI;
    for (i0 = 0; i0 < 27; i0++) {
      c_u[i0] = b_varargin_1[i0];
    }

    c_y = NULL;
    m0 = emlrtCreateCharArray(2, iv2);
    emlrtInitCharArrayR2013a(&st, 27, m0, &c_u[0]);
    emlrtAssign(&c_y, m0);
    b_st.site = &e_emlrtRSI;
    error(&b_st, c_y, &emlrtMCI);
  }

  emxFree_real_T(&importPrices);

  /*  Compute the best integer state change of battery */
  i0 = ST_b->size[1];
  if (!(1 <= i0)) {
    emlrtDynamicBoundsCheckR2012b(1, 1, i0, &b_emlrtBCI, sp);
  }

  i0 = ST_b->size[0];
  d0 = battery->state;
  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &g_emlrtDCI, sp);
  }

  i1 = (int32_T)d0;
  if (!((i1 >= 1) && (i1 <= i0))) {
    emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &n_emlrtBCI, sp);
  }

  *bestDischargeStep = ST_b->data[i1 - 1];
  i0 = CTG->size[1];
  if (!(1 <= i0)) {
    emlrtDynamicBoundsCheckR2012b(1, 1, i0, &emlrtBCI, sp);
  }

  i0 = CTG->size[0];
  d0 = battery->state;
  if (d0 != (int32_T)muDoubleScalarFloor(d0)) {
    emlrtIntegerCheckR2012b(d0, &h_emlrtDCI, sp);
  }

  i1 = (int32_T)d0;
  if (!((i1 >= 1) && (i1 <= i0))) {
    emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &o_emlrtBCI, sp);
  }

  *bestCTG = CTG->data[i1 - 1];

  /*  % DEBUG: Produce plot of optimal horizon decisions for 1st interval: */
  /*  if isempty(doneHorizonPlot) */
  /*      plotHorizon(cfg, demForecast, pvForecast, q_t_state, hourNow, ... */
  /*          gridImport); */
  /*       */
  /*      doneHorizonPlot = true; */
  /*  end */
  emxFree_real_T(&ST_b);
  emxFree_real_T(&CTG);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (controllerDp.c) */
