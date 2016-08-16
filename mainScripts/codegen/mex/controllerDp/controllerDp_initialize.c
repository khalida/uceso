/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * controllerDp_initialize.c
 *
 * Code generation for function 'controllerDp_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "controllerDp.h"
#include "controllerDp_initialize.h"
#include "_coder_controllerDp_mex.h"
#include "controllerDp_data.h"

/* Function Definitions */
void controllerDp_initialize(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (controllerDp_initialize.c) */
