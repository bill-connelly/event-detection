#include "mex.h"

/* Helper Functions */


double mean_array(double *a, mwSize start, mwSize end) {
   double sum = 0;
   int i;
   for (i = start; i <= end; i++) { 
	 sum = sum + a[i];
   }
   return sum/(end-start);
}

double min_array(double *a, mwSize start, mwSize end) {
   double min = a[start];
   int i;
   for (i = start; i <= end; i++) {
       if (a[i] < min) {
           min = a[i];
       }
   }
   return min;
}

/* the computational guts */

void fzero_c(double *outVector, double *inVector, int *inWindow, int *inWindow2, mwSize vectorRows) {
        int start;
        int end;
        int n;
        int winLength;
        int lookBack;
        winLength = (int) *inWindow;
        lookBack = (int) *inWindow2;
        for (n = 0; n <= vectorRows; n++) {
            start = n-winLength;
            if (start < 0) {
                start = 0;
            }
            end = n + winLength;
            if (end > vectorRows) {
                end = vectorRows;
            }
            outVector[n] = mean_array(inVector, start, end);
        }
        
        for (n = 0; n <= vectorRows; n++) {
            start = n - lookBack;
            if (start < 0) {
                start = 0;
            }
            outVector[n] = min_array(inVector, start, n);
        }
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *inVector;              /* Nx1 input matrix. Longer*/
    int *inWindow;                  /* Scalar for running ave window*/
    int *inWindow2;                 /* Scalar for min finding */
    double *outVector;               /* Nx1 output matrix */
    mwSize vectorRows;              /* size of matrix = N */

    /* get dimensions of the input matrix */
    vectorRows = mxGetM(prhs[0]);

    
    /* create a pointer to the real data in the input matrix  */
    inVector = mxGetPr(prhs[0]);
    inWindow = mxGetPr(prhs[1]);
    inWindow2 = mxGetPr(prhs[2]);
    
    /* create output matrix/vector/scalar */
    plhs[0] = mxCreateDoubleMatrix(vectorRows,1,mxREAL);
        
    /* get a pointer to the real data in the output matrix */
    outVector = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    fzero_c(outVector, inVector, inWindow, inWindow2, vectorRows);
}
