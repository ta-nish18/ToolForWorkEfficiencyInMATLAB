# Tool For Work Efficiency In MATLAB
This repository is a collection of MATLAB functions that I've found to be helpful in my day-to-day work as an engineer. 

I hope these functions come in handy for other engineers too!

## Install
To clone to your own MATLAB Drive, click on the following icon

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=ta-nish18/ToolForWorkEfficiencyInMATLAB)



## Function List
- GUI : `Bookmark`

  Supports managing bookmarks in folders and move to saved folders with 1-click.
  ```matlab
  >> Bookmark;
  ```
  
- GUI : `WorkspaceStash`

  Support for one-time save of a set of workspace variables and working paths.
  ```matlab
  >> WorkspaceStash;
  ```
  
- GUI : `figCapture`

  Supports 1-click saving of the currently displayed figure with the specified path, folder name, and extension.
  ```matlab
  >> figCapture;
  ```
  
- Function : `font`

  Shortcut function to change font and text size on MATLAB desktop. (refer to csv for correspondence between shortcut keys and formatting)
  ```matlab
  >> font 10  % Font size changed to 10pt
  >> font m   % Change Font format 
  ```
  
- Function : `win`

  Shortcut functions to change the style on the MATLABdesktop. (This function requires an external source.)
  ```matlab
  >> win k  % change to dark mode
  >> win w  % change to light mode
  ```
  
- Function : `uiclose`

  Function to delete all uifigures being displayed.
  ```
  >> uiclose
  >> uiclose [figname]
  ```
  
- Class : `figProcessor`

  Class that stores the figure class in its properties and provides built-in methods to assist in saving image files and creating GIFs.
  ```matlab
  >> tool = figProcessor();
  >> tool.save
  >> tool.getframe
  ```

  
