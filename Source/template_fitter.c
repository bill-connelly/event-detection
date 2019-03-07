#include "mex.h"
#include <math.h>

#include <stdio.h>

#define TEMP_LENG 100

/* Helper Functions */

double dot_product(double *a, double *b, mwSize n, mwSize offset) {
    double result = 0;
    int i;
    for (i = 0; i < n; i++) {
        result += a[i+offset]*b[i];
    }
    return result;
}

double sum_array(double *a, mwSize n, mwSize offset) {
   double sum = 0;
   int i;
   for (i = 0; i < n; i++) {
	 sum = sum + a[i+offset];
   }
   return sum;
}

double sum_squares(double *a, double *b, mwSize n, mwSize offset) {
    double ss = 0;
    int i;
    for (i = 0; i < n; i++) {
        ss += (a[i+offset] - b[i]) * (a[i+offset] - b[i]);
    }
    return ss;   
}

/* the computational guts */

void template_fitter(double *outVal, double *inData, double *inTemplate, mwSize dataRows, mwSize tempRows) {
    double template_sum = sum_array(inTemplate, tempRows, 0);   
    
    double denominator = dot_product(inTemplate, inTemplate, tempRows, 0) - template_sum * template_sum / tempRows;
    
    double scale;
    double offset;
    int i;
    int q;
    int p;
    
    double fitted_template[TEMP_LENG];
    
    
    for (i = 0; i < dataRows-tempRows; i++ ) {

        scale = ( dot_product(inData, inTemplate, tempRows, i) - template_sum * sum_array(inData, tempRows, i) / tempRows ) / denominator;
        
        offset = (sum_array(inData,tempRows,i) - scale * template_sum) / tempRows;
        
        for (q = 0; q < tempRows; q++) {
            fitted_template[q] = inTemplate[q] * scale + offset;
        }
        outVal[i] = scale / sqrt( sum_squares(inData, fitted_template, tempRows, i) / (tempRows-1));
    }
    for (p = dataRows-tempRows+1; p<dataRows; p++) { //Just to fill up the vector with zeros.
        outVal[p] = 0;        
    }
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *inData;               /* Nx1 input matrix. Longer*/
    double *inTemplate;           /* Qx1 input matrix. Shorter*/
    double *outVal;               /* (N-Q)x1 output matrix */
    mwSize dataRows;              /* size of matrix = N */
    mwSize tempRows;              /* size of matrix = Q */

    /* get dimensions of the input matrix */
    // ncols = mxGetN(prhs[0]);
    dataRows = mxGetM(prhs[0]);
    tempRows = mxGetM(prhs[1]);

    
    /* create a pointer to the real data in the input matrix  */
    inData = mxGetPr(prhs[0]);
    inTemplate = mxGetPr(prhs[1]);
    
    /* create output matrix/vector/scalar */
    plhs[0] = mxCreateDoubleMatrix(dataRows,1,mxREAL);
        
    /* get a pointer to the real data in the output matrix */
    outVal = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    template_fitter(outVal, inData, inTemplate, dataRows, tempRows);
}
