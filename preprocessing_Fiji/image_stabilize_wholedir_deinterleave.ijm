
//macro for 2-P image analysis
//for batch processing of all files in specified input directory
//stabilizes image in xy
// @ Annika Rings May 2017
macro "image_stabilize_deinterleave" {
inputdir=getDirectory("choose input directory");
list = getFileList(inputdir);
outputdir=getDirectory("choose output directory");

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
	run("Deinterleave", "how=2 keep");
	selectWindow(filename_img);
	newfilename1=replace(filename,".tif","_img.tif");
	saveAs("Tiff", inputdir+newfilename1);
	selectWindow(filename_stim);
	filesize=nSlices;
	newfilename_Stim=replace(filename,".tif","_stim.tif");
	saveAs("Tiff", inputdir+newfilename_Stim);
	selectWindow(newfilename1);
	filesize=nSlices;
	roiManager("reset");
	run("Clear Results");
	selectWindow(newfilename1);
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