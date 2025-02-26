# swift_code
In this app we want to build an app capable of reading and streaming a live video and applies an upscaler.
The pipile is: decoding the frame -> upscaling the frame -> displaying the frame.
We don't laverage a specific framework ( you can use anyframework you see fit), we just need to optimise to process to have real time video streaming.
After reading the video, we want to apply the 4x upscaler and display our image.
The input video is E1.mp4.
The upscaler we want to laverage is the 4x upscaler.
Note: we need to calculate the runtime of each sub process of the code as well as the whole pipeline runtime.