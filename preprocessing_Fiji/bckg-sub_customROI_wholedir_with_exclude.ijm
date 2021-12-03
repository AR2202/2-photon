
//macro for 2-P image analysis
//for batch processing of all files in specified input directory
//subtracts background fluorescence, and sets all values outside a user-specified ROI to 0
// @ Annika Rings May 2017
macro "bckg-sub_ROI" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir2=getDirectory("choose output directory for ROI");
excludedir=getDirectory("choose output directory for excluded experiments");
roi1 = getString("enter name of first ROI","gamma4");
roi2 = getString("enter name of second ROI", "gamma5");	
for (j = 0; j < list.length; j++){
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
	waitForUser("select "+roi1+" and press t");
	waitForUser("select "+roi2+" and press t");
	
	selectWindow(title);
	run("Select None");
	
	
    run("Duplicate...", "title=ROI2.tif duplicate");
    
	selectWindow(title);
	roiManager("Select", 0);
	run("Make Inverse");
	run("Set...", "value=0 stack");
	newfilename2=replace(filename,".tif",roi1+".tif");
	selectWindow("ROI2.tif");
	roiManager("Select", 1);
	run("Make Inverse");
	run("Set...", "value=0 stack");
	newfilename3=replace(filename,".tif",roi2+".tif");
	
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
  	
  }
  else {
	selectWindow(title);
	saveAs("Tiff", outputdir2+newfilename2);
	selectWindow("ROI2.tif");
  	saveAs("Tiff", outputdir2+newfilename3);
  	
	}
	run("Close All");
}
}