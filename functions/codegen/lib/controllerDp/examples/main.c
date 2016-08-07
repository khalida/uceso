/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 3.0
 * C/C++ source code generated on  : 26-Jul-2016 18:11:24
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/
/* Include Files */
#include "rt_nonfinite.h"
#include "controllerDp.h"
#include "main.h"
#include "controllerDp_terminate.h"
#include "controllerDp_initialize.h"

/* Function Declarations */
static void argInit_1x17_real_T(double result[17]);
static void argInit_1x3_char_T(char result[3]);
static void argInit_1x48_real_T(double result[48]);
static char argInit_char_T(void);
static double argInit_real_T(void);
static void argInit_struct0_T(struct0_T *result);
static struct1_T argInit_struct1_T(void);
static struct2_T argInit_struct2_T(void);
static struct3_T argInit_struct3_T(void);
static struct4_T argInit_struct4_T(void);
static void argInit_struct5_T(struct5_T *result);
static void main_controllerDp(void);

/* Function Definitions */

/*
 * Arguments    : double result[17]
 * Return Type  : void
 */
static void argInit_1x17_real_T(double result[17])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 17; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_real_T();
  }
}

/*
 * Arguments    : char result[3]
 * Return Type  : void
 */
static void argInit_1x3_char_T(char result[3])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 3; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_char_T();
  }
}

/*
 * Arguments    : double result[48]
 * Return Type  : void
 */
static void argInit_1x48_real_T(double result[48])
{
  int idx1;

  /* Loop over the array to initialize each element. */
  for (idx1 = 0; idx1 < 48; idx1++) {
    /* Set the value of the array element.
       Change this value to the value that the application requires. */
    result[idx1] = argInit_real_T();
  }
}

/*
 * Arguments    : void
 * Return Type  : char
 */
static char argInit_char_T(void)
{
  return '?';
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : struct0_T *result
 * Return Type  : void
 */
static void argInit_struct0_T(struct0_T *result)
{
  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result->sim = argInit_struct1_T();
  result->bat = argInit_struct2_T();
  argInit_1x3_char_T(result->type);
  result->opt = argInit_struct3_T();
  result->fc = argInit_struct4_T();
}

/*
 * Arguments    : void
 * Return Type  : struct1_T
 */
static struct1_T argInit_struct1_T(void)
{
  struct1_T result;

  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result.horizon = argInit_real_T();
  result.stepsPerHour = argInit_real_T();
  result.batteryEtaD = argInit_real_T();
  result.batteryEtaC = argInit_real_T();
  result.batteryChargingFactor = argInit_real_T();
  result.minCostDiff = argInit_real_T();
  result.eps = argInit_real_T();
  return result;
}

/*
 * Arguments    : void
 * Return Type  : struct2_T
 */
static struct2_T argInit_struct2_T(void)
{
  struct2_T result;

  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result.costPerKwhUsed = argInit_real_T();
  return result;
}

/*
 * Arguments    : void
 * Return Type  : struct3_T
 */
static struct3_T argInit_struct3_T(void)
{
  struct3_T result;

  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result.statesPerKwh = argInit_real_T();
  return result;
}

/*
 * Arguments    : void
 * Return Type  : struct4_T
 */
static struct4_T argInit_struct4_T(void)
{
  struct4_T result;

  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  result.trainRatio = argInit_real_T();
  result.nNodes = argInit_real_T();
  return result;
}

/*
 * Arguments    : struct5_T *result
 * Return Type  : void
 */
static void argInit_struct5_T(struct5_T *result)
{
  /* Set the value of each structure field.
     Change this value to the value that the application requires. */
  argInit_struct0_T(&result->cfg);
  result->SoC = argInit_real_T();
  result->state = argInit_real_T();
  result->capacity = argInit_real_T();
  result->maxChargeRate = argInit_real_T();
  result->increment = argInit_real_T();
  argInit_1x17_real_T(result->statesInt);
  argInit_1x17_real_T(result->statesKwh);
  result->maxDischargeStep = argInit_real_T();
  result->minDischargeStep = argInit_real_T();
  result->eps = argInit_real_T();
  result->cumulativeDamage = argInit_real_T();
  result->cumulativeValue = argInit_real_T();
}

/*
 * Arguments    : void
 * Return Type  : void
 */
static void main_controllerDp(void)
{
  struct0_T r0;
  double dv0[48];
  double dv1[48];
  struct5_T r1;
  double bestCTG;
  double bestDischargeStep;

  /* Initialize function 'controllerDp' input arguments. */
  /* Initialize function input argument 'cfg'. */
  /* Initialize function input argument 'demForecast'. */
  /* Initialize function input argument 'pvForecast'. */
  /* Initialize function input argument 'battery'. */
  /* Call the entry-point 'controllerDp'. */
  argInit_struct0_T(&r0);
  argInit_1x48_real_T(dv0);
  argInit_1x48_real_T(dv1);
  argInit_struct5_T(&r1);
  controllerDp(&r0, dv0, dv1, &r1, argInit_real_T(), &bestDischargeStep,
               &bestCTG);
}

/*
 * Arguments    : int argc
 *                const char * const argv[]
 * Return Type  : int
 */
int main(int argc, const char * const argv[])
{
  (void)argc;
  (void)argv;

  /* Initialize the application.
     You do not need to do this more than one time. */
  controllerDp_initialize();

  /* Invoke the entry-point functions.
     You can call entry-point functions multiple times. */
  main_controllerDp();

  /* Terminate the application.
     You do not need to do this more than one time. */
  controllerDp_terminate();
  return 0;
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
