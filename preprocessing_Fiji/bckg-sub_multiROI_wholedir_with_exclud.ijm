
//macro for 2-P image analysis
//for batch processing of all files in specified input directory
//subtracts background fluorescence, and sets all values outside a user-specified ROI to 0
// @ Annika Rings May 2017
macro "bckg-sub_ROI" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir2=getDirectory("choose output directory for ROI");
excludedir=getDirectory("choose output directory for excluded experiments");

for (j = 0; j < list.length; j++){
	
	open(inputdir+list[j]);
    selectWindow(list[j]);
	filename=getTitle;
	filesize=nSlices;
	roiManager("reset");
	run("Clear Results");
	selectWindow(filename);
	run("Make Substack...", " slices=1-"+filesize);
	run("Fire");
	title = getTitle();
		run("Z Project...", "projection=[Max Intensity]");
		
	waitForUser("select background and press t");
	selectWindow(title);
	for (i=0; i<nSlices; i++) {
		roiManager("Select", 0);
		setSlice(i+1);
		run("Measure");
		bckg=getResult("Mean");
		run("Select All");
		run("Subtract...", "value="+bckg+" slice");
	}
	run("Clear Results");
	roiManager("Select", 0);
	roiManager("Delete");
	waitForUser("select ROI 1 and press t");
	waitForUser("select ROI 2 and press t");
	waitForUser("select ROI 3 and press t");
	selectWindow(title);
	run("Select None");
	
	
    run("Duplicate...", "title=ROI2.tif duplicate");
    run("Duplicate...", "title=ROI3.tif duplicate");	
	selectWindow(title);
	roiManager("Select", 0);
	run("Make Inverse");
	run("Set...", "value=0 stack");
	newfilename2=replace(filename,".tif","ROI1.tif");
	selectWindow("ROI2.tif");
	roiManager("Select", 1);
	run("Make Inverse");
	run("Set...", "value=0 stack");
	newfilename3=replace(filename,".tif","ROI2.tif");
	selectWindow("ROI3.tif");
	roiManager("Select", 2);
	run("Make Inverse");
	run("Set...", "value=0 stack");
	newfilename4=replace(filename,".tif","ROI3.tif");
	Dialog.create("exclude");
		Dialog.addCheckbox("exclude", false);
		 Dialog.show();
	
	ramp = Dialog.getCheckbox();
  if (ramp==true) {
  	print ("excluded");
  	selectWindow(title);
  	saveAs("Tiff", excludedir+newfilename2);
  	selectWindow("ROI2.tif");
  	saveAs("Tiff", excludedir+newfilename3);
  	selectWindow("ROI3.tif");
  	saveAs("Tiff", excludedir+newfilename4);
  }
  else {
	selectWindow(title);
	saveAs("Tiff", outputdir2+newfilename2);
	selectWindow("ROI2.tif");
  	saveAs("Tiff", outputdir2+newfilename3);
  	selectWindow("ROI3.tif");
  	saveAs("Tiff", outputdir2+newfilename4);
	}
	run("Close All");
}
}