
//macro for 2-P image analysis
//for batch processing of all files in specified input directory
//stabilizes image in xy
// @ Annika Rings May 2017
macro "image_stabilize_Annika" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir=getDirectory("choose output directory");

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
	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
	
	
	selectWindow(title);
	newfilename=replace(filename,".tif","-stabilized.tif");
	saveAs("Tiff", outputdir+newfilename);
	run("Close All");
}
}