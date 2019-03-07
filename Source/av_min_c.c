#include "mex.h"
#include <math.h>

/* Helper Functions */


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

void av_min_c(double *outVector, double *inVector, double *inWindow, mwSize vectorRows) {
    
    int start;
    int winLength;
    int end;
    
    winLength = (int) floor(*inWindow);

    for (end = 0; end < vectorRows; end++) {
            start = end - winLength;
            if (start < 0) {
                start = 0;
            }
            outVector[end] = min_array(inVector, start, end);
    }
}




/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *inVector;              /* Nx1 input matrix. Longer*/
    double *inWindow;                  /* Scalar for window Length*/
    double *outVector;               /* Nx1 output matrix */
    mwSize vectorRows;              /* size of matrix = N */

    /* get dimensions of the input matrix */
    vectorRows = mxGetM(prhs[0]);

    
    /* create a pointer to the real data in the input matrix  */
    inVector = mxGetPr(prhs[0]);
    inWindow = mxGetPr(prhs[1]);
    
    /* create output matrix/vector/scalar */
    plhs[0] = mxCreateDoubleMatrix(vectorRows,1,mxREAL);
        
    /* get a pointer to the real data in the output matrix */
    outVector = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    av_min_c(outVector, inVector, inWindow, vectorRows);
}
