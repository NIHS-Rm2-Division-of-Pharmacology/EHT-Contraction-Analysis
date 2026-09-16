input = getDirectory("Input directory");
// create dialogue to get file suffix
Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.show();
suffix = Dialog.getString();

processFolder(input); // perform 'processFolder' function to input folder

function processFolder(input) {
	list = getFileList(input); // get file list in input directory
	for (i = 0; i < list.length; i++) {
		// perform 'processFolder' function to subdirectory in the input directory
		if(File.isDirectory(list[i]))
			processFolder("" + input + list[i]);
		// perform 'processFile' function to the files in the input directory
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
	showMessage("Macro is finished");
}

function processFile(input, file) {
	
	open(input+file);
 	title = File.nameWithoutExtension; // obtain input file name to arrange output file names
 	selectWindow(file);
 	run("8-bit");
 	getDimensions(width, height, channels, slices, frames);// get dimensions of the input file.
 	roiwidth=round(width/3);
 	roiheight=height-50;
 	makeRectangle(25, 25, roiwidth, roiheight);
 	run("Align slices in stack...", "method=5 windowsizex="+roiwidth+" windowsizey="+roiheight+" x0=25 y0=25 swindow=0 subpixel=false itpmethod=0 ref.slice=1 show=true");
 	//run("Close");
 	makeRectangle(width-roiwidth-25, 25, roiwidth, roiheight);
 	run("Align slices in stack...", "method=5 windowsizex="+roiwidth+" windowsizey="+roiheight+" x0="+(width-roiwidth-25)+" y0=25 swindow=0 subpixel=false itpmethod=0 ref.slice=1 show=true");
 	saveAs("Results", input+title+"_Results.csv");
 	run("Close");
 	selectWindow(file);
 	close();
}
