Calcium Transient Detection and Analyser script.
By Dr William Connely and Dr Sarah Hulme.
Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 
CC BY-NC-SA 2014

1. Extract all filles and directories to their own directory, leaving
   directory structure as is.

2. Compile C files.
    2a. Check if you have a C compiler with the command
        >> mex -setup
        Allow matlab to search for compilers. It should find something
        similar to Microsoft Visual C++ 2010.
        If not, go to the following address:
        http://www.mathworks.com/support/compilers/current_release/
        And follow the instructions to install Microsoft Windows SDK 7.1
        -Note, often the direct download fails. If so, search for the
        SDK 7.1 ISO. Currently available here:
        http://www.microsoft.com/en-gb/download/details.aspx?id=8442
        You want:
        GRMSDK_EN_DVD.iso (for 32 bit OS)
        GRMSDKX_EN_DVD.iso (for 64 bit OS)
        Which you will then need to mount with powerISO or similar
    2b. Repeat steap 2a, then run BUILD.m, which should compile C code
    2c. If steps 2a or 2b fail, you have to run the non-C version. Simply
        >> edit detect_ca.m
        and change line 4 to:
        using_c = false;

3. Execute Program
    3a. Program is executed by running
    >> output = detect_ca( epoch_vector, is_stim_vector);
        epoch_vector is a vector containing the START of each sampling epoch
        Each epoch must have identical lengths.
        Example code for generating epoch_vector is:
        >> epoch_vector = [0:20:660];

        is_stim_vector is a boolean vector containing data whether each epoch
        contains a valid stimuli. length(epoch_vector) must equal
        length(is_stim_vector)
        Example code for generating is_stim_vector is:
        >> is_stim_vector = true(1, 34);
        >> is_stim_vector(1:8) = false;

        output is a data structure containing analysized data.
            output.smoothed_deltaf is the smoothed deltaf/f values for each
            cell, columnwise , in the same order as original file

            output.deltaf is the non smoothed deltaf/f values

            output.fitscore shows the fitscore for all cells, again in a
            columnwise fashion, in the same order as the the original file

            output.event_data is the analyzed data for each detected event.
            Each row is for one event. Each column is a specific datapoint
            for that event. By column: #1, Cell number that generated event
            #2, Epoch that the event occured in. #3, Boolean representing
            whether the epoch is a stimulus epoch. #4, Event onset time from
            epoch start. #5, Peak amplitude. #6, Time of peak. #7, half
            width of event. #8, Number of samples under background F signal
            that the generated cell had. #9, Index of event start from start
            of sampling.

    3b. Input data must be a .csv file, organized as each cell being a column
        except for the first column which is background. The time step
        between each sample must be fixed

    3c. After selecting the input data, you will be presented with a window
        showing at most 9 different recordings. These recordings are the
        programs best geuss at the most active cells. Eather drag the
        horizontal line, or enter a value, to set the threshold for event
        detections. The program then believes that all areas where the
        fit_score crosses this threshold contain an event, and the event
        starts when the fit score is maximum. If you close this window
        rather than press Okay, the program will hang, and must be closed
        with ctrl-c.

    3d. At this point you will be shown various other diagnostic windows.
        All data shown in these windows can be generated from the returned
        data.

Program Notes.
• Despite best efforts, C code does not generate 100% identical values to
matlab code, though it is very very close. One version should not be seen
as correct, simply they are different. However, the user should pick one
version and stick with it. We STRONGLY recommend the C version, as it runs
approximately 1000x faster than the pure matlab code.

• make_template.m currently uses an alpha function to generate an
appropriate waveform. The commented out code contains a function for a
sum of two exponentials (which will require a second input argument) as
well as a Gaussian, where tau is the standard deviation. The C function
for the template fit requires the template to be shorter than 100 samples.
If you require longer, please edit ../Source/template_fitter.c and change
line 6 to #define TEMP_LENG XXX, where XXX is the number of samples you
require, then recompile by running BUILD.m

• deltaf.m contains 3 constants used for filtering. They are chosen
arbitrarily for the data. If you data appears over filtered (that is,
the events in output.smoothed_deltaf are of lower amplitude, and longer
duration than those in output.deltaf), reduce tau0. If minimum deltaf values
are often below zero, try reducing tau1 and tau2

• tightfig.m was taken from
http://www.mathworks.co.uk/matlabcentral/fileexchange/34055-tightfig
