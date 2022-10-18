
macro "extract_fluo_3channel" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir=getDirectory("choose output directory for Fluo");
excludedir=getDirectory("choose output directory for excluded experiments");
stimdir=getDirectory("choose stimulus directory");
roi1 = getString("enter name of first ROI","gamma4");
roi2 = getString("enter name of second ROI", "gamma5");	


for (j = 0; j < list.length; j++){
	
	open(inputdir+list[j]);
    selectWindow(list[j]);
	filename=getTitle;
	filename_img=replace(filename,".tif",".tif #1");
	filename_stim=replace(filename,".tif",".tif #2");
	filename_ch3=replace(filename,".tif",".tif #3");
	stimfilename = replace(filename,".tif","_stim.csv");
	ch3filename = replace(filename,".tif","_ch3.csv");
	run("Deinterleave", "how=3 keep");
	
	roi1_filename=replace(filename,".tif",roi1+".csv");
	roi2_filename=replace(filename,".tif",roi2+".csv");
	roiManager("reset");
	run("Clear Results");
	selectWindow(filename_img);
	filesize=nSlices;
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
	
    run("Select All");
    roiManager("add");
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
	


extract_fluo(filename_stim, 2, stimdir, stimfilename);
extract_fluo(filename_ch3, 2, stimdir, ch3filename);
roiManager("reset");
run("Close All");
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
