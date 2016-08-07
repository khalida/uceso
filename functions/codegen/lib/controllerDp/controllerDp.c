/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: controllerDp.c
 *
 * MATLAB Coder version            : 3.0
 * C/C++ source code generated on  : 26-Jul-2016 18:11:24
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "controllerDp.h"
#include "controllerDp_emxutil.h"

/* Function Declarations */
static double rt_roundd_snf(double u);

/* Function Definitions */

/*
 * Arguments    : double u
 * Return Type  : double
 */
static double rt_roundd_snf(double u)
{
  double y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

/*
 * controllerDp: Solve dynamic program for the curent horizon, to
 *  minimise costs
 * Arguments    : const struct0_T *cfg
 *                const double demForecast[48]
 *                const double pvForecast[48]
 *                const struct5_T *battery
 *                double hourNow
 *                double *bestDischargeStep
 *                double *bestCTG
 * Return Type  : void
 */
void controllerDp(const struct0_T *cfg, const double demForecast[48], const
                  double pvForecast[48], const struct5_T *battery, double
                  hourNow, double *bestDischargeStep, double *bestCTG)
{
  emxArray_real_T *CTG;
  double nStages;
  int i0;
  int loop_ub;
  emxArray_real_T *ST_b;
  emxArray_real_T *importPrices;
  double b_min_int;
  double b_max_int;
  emxArray_real_T *exportPrices;
  int t;
  double x;
  double d0;
  double b_t;
  int q;
  double bestB;
  double this_b_min_int;
  double b_b_max_int;
  int thisB;
  double b_thisB;
  double b_hat;
  double g_t;
  double d1;
  double d2;
  double thisCTG;
  emxInit_real_T(&CTG, 2);

  /*  Positive b is DISCHARGING the battery! */
  /*  persistent doneHorizonPlot; */
  /* % Initialise Values */
  nStages = cfg->sim.horizon;

  /*  Initialise array of costs to go (NB: cost from last stage is zero in */
  /*  all possible states) */
  i0 = CTG->size[0] * CTG->size[1];
  CTG->size[0] = 17;
  CTG->size[1] = (int)(cfg->sim.horizon + 1.0);
  emxEnsureCapacity((emxArray__common *)CTG, i0, (int)sizeof(double));
  loop_ub = 17 * (int)(cfg->sim.horizon + 1.0);
  for (i0 = 0; i0 < loop_ub; i0++) {
    CTG->data[i0] = 0.0;
  }

  emxInit_real_T(&ST_b, 2);
  i0 = ST_b->size[0] * ST_b->size[1];
  ST_b->size[0] = 17;
  ST_b->size[1] = (int)cfg->sim.horizon;
  emxEnsureCapacity((emxArray__common *)ST_b, i0, (int)sizeof(double));
  loop_ub = 17 * (int)cfg->sim.horizon;
  for (i0 = 0; i0 < loop_ub; i0++) {
    ST_b->data[i0] = 0.0;
  }

  emxInit_real_T1(&importPrices, 1);

  /*  Limits on battery rate-of-charge: */
  /*  kWh/interval */
  /*  kWh/interval */
  b_min_int = floor(-battery->maxChargeRate / cfg->sim.stepsPerHour /
                    battery->increment);

  /*  No. charge increments */
  b_max_int = ceil(battery->maxChargeRate / cfg->sim.stepsPerHour /
                   battery->increment);

  /*  No. charge increments */
  /*  Get the grid prices: */
  i0 = importPrices->size[0];
  importPrices->size[0] = (int)cfg->sim.horizon;
  emxEnsureCapacity((emxArray__common *)importPrices, i0, (int)sizeof(double));
  loop_ub = (int)cfg->sim.horizon;
  for (i0 = 0; i0 < loop_ub; i0++) {
    importPrices->data[i0] = 0.0;
  }

  emxInit_real_T1(&exportPrices, 1);
  i0 = exportPrices->size[0];
  exportPrices->size[0] = (int)cfg->sim.horizon;
  emxEnsureCapacity((emxArray__common *)exportPrices, i0, (int)sizeof(double));
  loop_ub = (int)cfg->sim.horizon;
  for (i0 = 0; i0 < loop_ub; i0++) {
    exportPrices->data[i0] = 0.0;
  }

  for (t = 0; t < (int)nStages; t++) {
    x = (hourNow + (1.0 + (double)t)) - 1.0;
    if (cfg->sim.horizon == 0.0) {
    } else if (cfg->sim.horizon == floor(cfg->sim.horizon)) {
      x -= floor(x / cfg->sim.horizon) * cfg->sim.horizon;
    } else {
      x /= cfg->sim.horizon;
      if (fabs(x - rt_roundd_snf(x)) <= 2.2204460492503131E-16 * fabs(x)) {
        x = 0.0;
      } else {
        x = (x - floor(x)) * cfg->sim.horizon;
      }
    }

    /*  getGridPrices: Look-up function to return the grid-prices: */
    /*  $/kWh */
    d0 = 0.1;

    /*  $/kWh */
    /*  set imports to peak tarriff if required 7AM = 10PM */
    if ((x >= 14.0) && (x <= 43.0)) {
      d0 = 0.4;
    }

    importPrices->data[t] = d0;
    exportPrices->data[t] = 0.05;
  }

  /*  Work back through previous stages and find minimum cost to go */
  /*  store the chosen charge decision in ST_b */
  for (t = 0; t < (int)-(1.0 + (-1.0 - nStages)); t++) {
    b_t = nStages + -(double)t;

    /*  For all possible starting states */
    for (q = 0; q < 17; q++) {
      /*  Initialise bestCTG to large value  */
      /*  and best discharge to infeasible value */
      *bestCTG = rtInf;
      bestB = rtInf;

      /*  Further constrain minimum and maximum b (charging energy) */
      if (b_min_int >= (1.0 + (double)q) - 17.0) {
        this_b_min_int = b_min_int;
      } else {
        this_b_min_int = (1.0 + (double)q) - 17.0;
      }

      /*  For each feasible discharging decision check the resulting CTG */
      if (b_max_int <= (1.0 + (double)q) - 1.0) {
        b_b_max_int = b_max_int;
      } else {
        b_b_max_int = (1.0 + (double)q) - 1.0;
      }

      i0 = (int)(b_b_max_int + (1.0 - this_b_min_int));
      for (thisB = 0; thisB < i0; thisB++) {
        b_thisB = this_b_min_int + (double)thisB;

        /*  Find net power from battery (account for losses) */
        if (b_thisB > 0.0) {
          b_hat = b_thisB * battery->increment * cfg->sim.batteryEtaD;
        } else {
          b_hat = b_thisB * battery->increment / cfg->sim.batteryEtaC;
        }

        /*  Find energy from grid during interval */
        g_t = (demForecast[(int)b_t - 1] - b_hat) - pvForecast[(int)b_t - 1];

        /*  Find battery damage cost */
        /* fracDegradation = calcFracDegradation(cfg, battery, q, ... */
        /*     thisB); */
        /* damageCost = fracDegradation*battery.Value(); */
        /*  Battery degradation cost (fixed per kWh-through-put): */
        /*  Total state transition cost for this decision from here */
        /*  Total cost-to-got for this decision from here to end */
        if ((0.0 >= g_t) || rtIsNaN(g_t)) {
          d1 = 0.0;
        } else {
          d1 = g_t;
        }

        if ((0.0 >= -g_t) || rtIsNaN(-g_t)) {
          d2 = 0.0;
        } else {
          d2 = -g_t;
        }

        thisCTG = ((importPrices->data[(int)b_t - 1] * d1 - exportPrices->data
                    [(int)b_t - 1] * d2) + fabs(b_thisB) * battery->increment *
                   0.5 * cfg->bat.costPerKwhUsed) + CTG->data[((int)((1.0 +
          (double)q) - b_thisB) + CTG->size[0] * (int)b_t) - 1];

        /*  Store decision if it's the best found so far */
        if (thisCTG < *bestCTG - cfg->sim.minCostDiff) {
          bestB = b_thisB;
          *bestCTG = thisCTG;
        }
      }

      /*  Store the best discharging decision found */
      ST_b->data[q + ST_b->size[0] * ((int)b_t - 1)] = bestB;
      CTG->data[q + CTG->size[0] * ((int)b_t - 1)] = *bestCTG;
    }
  }

  emxFree_real_T(&exportPrices);
  emxFree_real_T(&importPrices);

  /*  Create time-series of charge decisions, and SoC */
  /*  Check ending SoC of battery */
  *bestDischargeStep = ST_b->data[(int)battery->state - 1];
  *bestCTG = CTG->data[(int)battery->state - 1];

  /*  DEBUG: Produce plot of optimal horizon decisions for 1st interval: */
  /*  if isempty(doneHorizonPlot) */
  /*      plotHorizon(demForecast, pvForecast, q_t_state, hourNow, ... */
  /*          gridImport); */
  /*       */
  /*      doneHorizonPlot = true; */
  /*  end */
  emxFree_real_T(&ST_b);
  emxFree_real_T(&CTG);
}

/*
 * File trailer for controllerDp.c
 *
 * [EOF]
 */
