function folder_name = export_dicom_DCM(app,dcmdir,directory,image,parameters)


% Phase orientation
if isfield(app.seqpar, 'PHASE_ORIENTATION')
    if app.seqpar.PHASE_ORIENTATION == 1
        app.TextMessage('INFO: phase orientation = 1');
        image = permute(rot90(permute(image,[2 1 3 4 5 6]),1),[2 1 3 4 5 6]);
    end
end


% size of the data
dimx = size(image,1);
dimy = size(image,2);
dimz = size(image,3);
NR = size(image,4);
NFA = size(image,5);
NE = size(image,6);


% reading in the DICOM header information
listing = dir(fullfile(dcmdir, '*.dcm'));
dcmfilename = [listing(1).folder,filesep,listing(1).name];
base_header = dicominfo(dcmfilename);
TextMessage(app,strcat('Reading DICOM info from',{' '},dcmfilename));


% create folder if not exist, and delete folder content
dir1 = base_header.PatientID;
dir2 = 'DICOM';
dir3 = strcat(num2str(base_header.SeriesNumber),'P');
dir4 = '1';
folder_name = strcat(directory,filesep,dir1,filesep,dir2,filesep,dir3,filesep,dir4);
if (~exist(folder_name, 'dir')); mkdir(fullfile(directory, dir1,dir2,dir3,dir4)); end
delete([folder_name,filesep,'*']);


% export the dicom images
filecounter = 0;
app.ExportProgressGauge.Value = 0;
totalnumberofimages = NR*NFA*NE*dimz;                    

for i=1:NR % loop over all repetitions
    
    for j=1:NFA      % loop over all flip angles
        
        for k=1:NE      % loop over all echo times
            
            for z=1:dimz        % loop over all slices
                
                % Counter
                filecounter = filecounter + 1;
                
                % File name
                fn = ['000000',num2str(filecounter)];
                fn = fn(size(fn,2)-5:size(fn,2));
                fname = [folder_name,filesep,fn,'.dcm'];
                
                % Dicom header
                dcm_header = generate_dicomheader_DCM(app,base_header,parameters,fname,filecounter,i,j,k,z,dimx,dimy,dimz,NR);
                
                % The image
                im = rot90(squeeze(cast(round(image(:,:,z,i,j,k)),'uint16')));
                
                % Write the dicom file
                dicomwrite(im, fname, dcm_header);
                
                % Update progress bar
                app.ExportProgressGauge.Value = round(100*filecounter/totalnumberofimages);
                drawnow;
                
            end
            
        end
        
    end
    
end

end