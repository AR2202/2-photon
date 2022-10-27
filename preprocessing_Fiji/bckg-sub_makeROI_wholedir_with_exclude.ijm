
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
	waitForUser("select ROI and press t");
	selectWindow(title);
	roiManager("Select", 0);
	run("Make Inverse");
	run("Set...", "value=0 stack");
	newfilename2=replace(filename,".tif","ROI.tif");
	Dialog.create("exclude");
		Dialog.addCheckbox("exclude", false);
		 Dialog.show();
	
	ramp = Dialog.getCheckbox();
  if (ramp==true) {
  	print ("excluded");
  	saveAs("Tiff", excludedir+newfilename2);
  }
  else {
	saveAs("Tiff", outputdir2+newfilename2);
	}
	run("Close All");
}
}