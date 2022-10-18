
macro "extract_fluo_wholedir" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir=getDirectory("choose output directory for ROI");
excludedir=getDirectory("choose output directory for excluded experiments");


for (j = 0; j < list.length; j++){
	
	open(inputdir+list[j]);
    selectWindow(list[j]);
	filename=getTitle;
	filesize=nSlices;
	roi_filename=replace(filename,".tif","ROI.csv");
	
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
	run("Select None");	
    
	
	Dialog.create("exclude");
		Dialog.addCheckbox("exclude", false);
		 Dialog.show();
	
	exclude = Dialog.getCheckbox();
  if (exclude) {
  	print ("excluded");
  	extract_fluo(title, 0, excludedir, roi_filename);
  	
  	
  }
  else {
	extract_fluo(title, 0, outputdir, roi_filename);
  	
  	
  	
	}
	run("Close All");


roiManager("reset");
}
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
