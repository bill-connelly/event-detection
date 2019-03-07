#include "mex.h"
#include <math.h>

/* Helper Functions */


double mean_array(double *a, mwSize start, mwSize end) {
   double sum = 0;
   int i;
   for (i = start; i <= end; i++) {
	 sum = sum + a[i];
     //mexPrintf("%f\n", a[i]); 
   }
   //mexPrintf("%s\n", " ");  
   return sum/((end-start)+1);
}

/* the computational guts */

void running_av_filter_c(double *outVector, double *inVector, double *inWindow, mwSize vectorRows) {
        int start;
        int end;
        int n;
        int winLength;
        winLength = (int) floor( *inWindow / 2);
        for (n = 0; n < vectorRows; n++) {
            start = n - winLength;
            if (start < 0) {
                start = 0;
            }
            end = n + winLength;
            if (end >= vectorRows) {
                end = vectorRows-1;
            }
            outVector[n] = mean_array(inVector, start, end);
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
    running_av_filter_c(outVector, inVector, inWindow, vectorRows);
}
