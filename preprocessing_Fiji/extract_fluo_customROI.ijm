
//macro for 2-P image analysis
//for batch processing of all files in specified input directory
//subtracts background fluorescence, and sets all values outside a user-specified ROI to 0
// @ Annika Rings May 2017
macro "extract_fluo_customROI" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir=getDirectory("choose output directory for ROI");
excludedir=getDirectory("choose output directory for excluded experiments");
roi1 = getString("enter name of first ROI","gamma4");
roi2 = getString("enter name of second ROI", "gamma5");	

for (j = 0; j < list.length; j++){
for (j = 0; j < list.length; j++){
	
	open(inputdir+list[j]);
    selectWindow(list[j]);
	filename=getTitle;
	filesize=nSlices;
	roi1_filename=replace(filename,".tif",roi1+".csv");
	roi2_filename=replace(filename,".tif",roi2+".csv");
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
    run("Duplicate...", "title="+roi2+".tif duplicate");

	
	
	
	Dialog.create("exclude");
		Dialog.addCheckbox("exclude", false);
		 Dialog.show();
	
	exclude = Dialog.getCheckbox();
  if (exclude) {
  	print ("excluded");
  	extract_fluo(title, 0, excludedir, roi1_filename);
  	
  	extract_fluo(roi2+".tif", 1, excludedir, roi2_filename);
  }
  else {
	extract_fluo(title, 0, outputdir, roi1_filename);
  	
  	extract_fluo(roi2+".tif", 1, outputdir, roi2_filename);
  	
	}
	run("Close All");
}
}
roiManager("reset");
}
function extract_fluo(windowname, roinumber, dir, outputname) {
	run("Set Measurements...", "mean redirect=None decimal=9");

      selectWindow(windowname);
	
	for (i=0; i<nSlices; i++) {
		
		setSlice(i+1);
		
		roiManager("Select", roinumber);
		run("Measure");
		
	}
	saveAs("Results", dir+outputname);
  	    run("Clear Results");
   }
