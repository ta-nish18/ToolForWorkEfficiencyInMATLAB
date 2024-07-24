# Tool For Work Efficiency In MATLAB
This repository is a collection of MATLAB functions that I've found to be helpful in my day-to-day work as an engineer. 

I hope these functions come in handy for other engineers too!

## Install
To clone to your own MATLAB Drive, click on the following icon

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=ta-nish18/ToolForWorkEfficiencyInMATLAB)



## Function List
- GUI : `UI.Bookmark`
  
  Supports managing bookmarks in folders and move to saved folders with 1-click.
  ```matlab
  >> UI.Bookmark;
  ```
  
- GUI : `UI.figCapture`

  Supports 1-click saving of the currently displayed figure with the specified path, folder name, and extension.
  ```matlab
  >> UI.figCapture;
  ```
  
- Function : `font`

  Shortcut function to change font and text size on MATLAB desktop.
  ```matlab
  >> font 10
  >> font m
  ```
  
- Function : `win`

  Shortcut functions to change the style on the MATLABdesktop. (This function requires an external source.)
  ```matlab
  >> win k
  >> win w
  ```
  
- Function : `uiclose`

  Function to delete all uifigures being displayed.
  ```
  >> uiclose
  ```
  
- Class : `figProcessor`

  Class that stores the figure class in its properties and provides built-in methods to assist in saving image files and creating GIFs.
  ```matlab
  >> tool = figProcessor();
  >> tool.save
  >> tool.getframe
  ```

  
