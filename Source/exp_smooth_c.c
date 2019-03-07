#include "mex.h"
#include <math.h>
#include <stdlib.h>

/* Helper Functions */



/* the computational guts */


void exp_smooth_c(double *outVector, double *inVector, double *inWindow, mwSize vectorRows) {
/* This function may not look at all like the original Konnerth version
 However, if you write out the series expanation of the integral you will
 see that  each term doesn't require you to calculate the whole integral again,
 but simply add a  small term on. If you don't believe me, I have included
 something that looks more reasonable  below, but commented out.
 Check to see if they produce the same values! */
       
        int n;
        int winLength;
        double topIntegral;
        double bottomIntegral;
        
        const double scaleFactor = exp(-1/ *inWindow);
        
        //topIntegral = inVector[0] * exp( -1 / *inWindow);
        topIntegral = 0;
        //bottomIntegral = exp( -1 / *inWindow);
        bottomIntegral = 0; 
        
        //mexPrintf("%f\t%f\n", topIntegral, bottomIntegral);
        for (n = 0; n < vectorRows; n++) {

            topIntegral = topIntegral * scaleFactor + scaleFactor * inVector[n];
            bottomIntegral = bottomIntegral + exp( -(n+1) / *inWindow);
            //mexPrintf("%f\t%f\n", topIntegral, bottomIntegral);
            
            outVector[n] = topIntegral/bottomIntegral;
        }
    
    /*
        int n;
        int t;
        int winLength;
        double topIntergral;
        double bottomIntergral;
        double om;
        winLength = (int) *inWindow;
        for (n = 0; n < vectorRows; n++) {
            topIntergral = 0;
            bottomIntergral = 0;
            for (t = 0; t <= n; t++) {
                om = exp((double) -t/winLength);
                topIntergral = topIntergral + (inVector[n-t] * om);                
                bottomIntergral = bottomIntergral + om;
                mexPrintf("%f\n", topIntergral);                
                
            }
            mexPrintf("\n");

            outVector[n] = topIntergral/bottomIntergral;
        }
     */

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
    exp_smooth_c(outVector, inVector, inWindow, vectorRows);
}
