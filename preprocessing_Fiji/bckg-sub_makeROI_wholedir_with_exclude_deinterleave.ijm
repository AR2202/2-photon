
//macro for 2-P image analysis
//for batch processing of all files in specified input directory
//subtracts background fluorescence, and sets all values outside a user-specified ROI to 0
// @ Annika Rings May 2017
macro "bckg-sub_ROI_deinterleave" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir2=getDirectory("Choose__ output directory for ROI");
excludedir=getDirectory("choose_ output directory for excluded experiments");
for (j = 0; j < list.length; j++){
for (j = 0; j < list.length; j++){
	
	open(inputdir+list[j]);
    selectWindow(list[j]);
	filename=getTitle;
	print (filename);
	filename_img=replace(filename,".tif",".tif #1");
	print (filename_img);
	filename_stim=replace(filename,".tif",".tif #2");
	print (filename_img);
	print (filename_stim);
	
	roiManager("reset");
	run("Clear Results");
	selectWindow(filename);
	run("Deinterleave", "how=2 keep");
	selectWindow(filename_img);
	newfilename1=replace(filename,".tif","_img.tif");
	saveAs("Tiff", inputdir+newfilename1);
	selectWindow(filename_stim);
	filesize=nSlices;
	newfilename_Stim=replace(filename,".tif","_stim.tif");
	saveAs("Tiff", inputdir+newfilename_Stim);
	selectWindow(newfilename1);
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