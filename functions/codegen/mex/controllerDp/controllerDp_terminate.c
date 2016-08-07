/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * controllerDp_terminate.c
 *
 * Code generation for function 'controllerDp_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "controllerDp.h"
#include "controllerDp_terminate.h"
#include "_coder_controllerDp_mex.h"
#include "controllerDp_data.h"

/* Function Definitions */
void controllerDp_atexit(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void controllerDp_terminate(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (controllerDp_terminate.c) */
