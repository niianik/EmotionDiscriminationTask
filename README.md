# EmotionDiscriminationTask

README

Thank you for your interst in completing the task!

We aim to investigate how people discriminate between happy and angry facial expressions. 

Who is eligible? 
- Adults with normal or corrected-to-normal vision


What does the task consist of?
On each trial, a face will briefly appear on the screen. Then, you'll be asked to decide
whether the face was ANGRY or HAPPY, using the left and right arrow keys on the keyboard to respond (1AFC).
You will have 2 seconds to do this. You will then we asked to indicate how CONFIDENT you were in
your judgement, using the 1 (Unsure), 2 (Sure), and 3 (Very sure) number keys (RT = 3 sec). 

The run consists of 280 trials, spread over 6 blocks. You will have a short break every 3-4 minutes, 
and the run will take about 25 min in total. 


Want to participate? 

1. Send me an e-mail (niianikolova [at] gmail [dot] com), and I will reply with a subjectd ID code, which you will enter when completing the task. 
2. Make sure you have a working installation of Matlab and Psychtoolbox (+ GStreamer).
3. Download & save 'EmotionDiscriminationTask' to a directory.
      The directory should contain the following:
         experimentLauncher.m
         main.m
         loadParams.m
         helpers (folder)
4. Use a ruler to measure the height and width of your screen (in cm), and note the distance at which you are sitting from the display.

5. To begin the experiment, add the 'EmotionDiscriminationTask' directory to the MATLAB path and 
run 'experimentLauncher.m' (located in ./code/task).
   You will be asked to enter basic demographic information, your subject ID, and display dimension and viewing distance. Then, the run will begin. IPress Esc to quit (partial results will be saved).
   
6. When you have completed a run, the data will be saved in ./data/ with your subject ID. Please e-mail this file back to me. 


*** This is a work in progress, and I appreciate any feedback and bug reports. 
Contact: niianikolova [at] gmail [dot] com ***
