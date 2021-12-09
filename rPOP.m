%%% Welcome to rPOP! %%%
%%% See documentation on Github at https://github.com/LeoIacca/rPOP %%%
%%% Please cite https://www.sciencedirect.com/science/article/pii/S1053811921010478 and all additional software references if you use rPOP! %%%
%%% Please send comments or questions to Leonardo.Iaccarino@ucsf.edu %%%
%%% rPOP v1.0 - August 2021 %%%

fprintf(1,'\n\n********** Welcome to rPOP v1.0 (August 2021) **********\n');
fprintf(1,'rPOP is dependent on:\n*1. Statistical Parametric Mapping toolbox (SPM, https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)\n*2. AFNI Neuroimaging Suite (https://afni.nimh.nih.gov/)\n*3. MATLAB (https://www.mathworks.com/products/matlab.html)\n');
fprintf(1,'The origin reset code employed in rPOP is from F. Yamashita and is part of an ac/pc co-registration script \n(parent function available at: http://www.nemotos.net/scripts/acpc_coreg.m)\n');
fprintf(2,'*** rPOP is only distributed for academic/research purposes, with NO WARRANTY. ***\n*** rPOP is not intended for any clinical or diagnostic purposes. ***\n');
fprintf(2,'Press a key to acknowledge and continue with rPOP:\n');
pause;

% Select 3D nifti volumes to be processed
vols = spm_select(Inf,'image', 'Select AC PET to process');  

% Select output directory
mdir=spm_select(1,'dir', 'Select output directory (tables/logs will be saved here)');

% Locate 3dFWHMx function in the user's system
afnifx = spm_select(1,'any', 'Select 3dFWHMx executable');  

% Looking for the templates distributed with rPOP

rpopath=which('rPOP');
[popdir,~,~]=spm_fileparts(rpopath);
tdir=[popdir, '/templates/'];

tfbpall=cellstr([tdir,'Template_FBP_all.nii']);
tfbppos=cellstr([tdir,'Template_FBP_pos.nii']);
tfbpneg=cellstr([tdir,'Template_FBP_neg.nii']);

tfbball=cellstr([tdir,'Template_FBB_all.nii']);
tfbbpos=cellstr([tdir,'Template_FBB_pos.nii']);
tfbbneg=cellstr([tdir,'Template_FBB_neg.nii']);

tfluteall=cellstr([tdir,'Template_FLUTE_all.nii']);
tflutepos=cellstr([tdir,'Template_FLUTE_pos.nii']);
tfluteneg=cellstr([tdir,'Template_FLUTE_neg.nii']);

warptempl_fbp=vertcat(tfbpall,tfbppos,tfbpneg);                                                                     
warptempl_fbb=vertcat(tfbball,tfbbpos,tfbbneg);                                                                     
warptempl_flute=vertcat(tfluteall,tflutepos,tfluteneg);                                                                     

warptempl_all=vertcat(tfbpall,tfbppos,tfbpneg,tfbball,tfbbpos,tfbbneg,tfluteall,tflutepos,tfluteneg);                                                                     

% Create empty arrays to store FWHM estimations and warnings/errors, if any
dbests={};
dbwarn={};

% Input option for origin resetting
oropt = input(['\nPlease select an option. Will be applied to all images.' ,...
        '\n     [1] Set origin to center of image',...
        '\n     [2] Do not reset origin',...
        '\n     --> ']);
    
    if oropt~=1 && oropt~=2
       clear;
       error('Origin option selection was invalid. Must be 1 or 2. Please re-run rPOP.'); 
    end % end if condition QC user input for origin reset
    
% Input template choice option
tpopt = input(['\nPlease select a Warping Template Option:' ,...
        '\n     [1] Tracer-independent, use all Templates (Validated Approach)',...
        '\n     [2] Tracer-specific, use 18F-florbetapir Templates',...
        '\n     [3] Tracer-specific, use 18F-florbetaben Templates',...
        '\n     [4] Tracer-specific, use 18F-flutemetamol Templates',...
        '\n     --> ']);
    
    if tpopt~=1 && tpopt~=2 && tpopt~=3 && tpopt~=4
       clear;
       error('Template option selection was invalid. Must be 1, 2, 3 or 4. Please re-run rPOP.'); 
    end % end if condition QC user input for template approach
    
    if tpopt==1 
        warptempl=warptempl_all;
    elseif tpopt==2
        warptempl=warptempl_fbp;
    elseif tpopt==3
        warptempl=warptempl_fbb;
    elseif tpopt==4
        warptempl=warptempl_flute;
    end % end if condition selection of templates based on user input
    
% Process the PET scans serially

for i=1:size(vols,1)

    if oropt==1 % Resetting of the origin is required, code by F.Yamashita
      file = deblank(vols(i,:));
      st.vol = spm_vol(file);
      vs = st.vol.mat\eye(4);
      vs(1:3,4) = (st.vol.dim+1)/2;
      spm_get_space(st.vol.fname,inv(vs));
    end % end if condition origin of the image has to be reset automatically

   % Warp the image through the Old Normalization tool in SPM12
   % Bounding box size increased
    
    tempimg=cellstr(vols(i,:));
    
    spm('defaults','PET');
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source = tempimg;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = tempimg;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = warptempl;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 8;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'mni';
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb = [-100 -130 -80
                                                             100 100 110];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox = [2 2 2];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp = 1;
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix = 'w';
    spm_jobman('run',matlabbatch); clear matlabbatch;

    % Estimate FWHM in the warped image, output a txt file with the results

    [p,f,~]=spm_fileparts(char(tempimg));
    wtempimg=strcat(p,'/w',f);
    txtfwhm=strcat(wtempimg,'_automask.txt');
    fwhmest_cmd=char(strcat(afnifx ,{' '},'-automask -2difMAD',{' '},'-input',{' '}, strcat(wtempimg,'.nii'),{' '},'-out',{' '},txtfwhm,{' '}));
    system(fwhmest_cmd);

    % Read output txt file with the estimated FWHM in each
    % plane, preparing the calculation of the differential
    % smoothing
    tempest=importdata(txtfwhm);      
    tempfwhmx=tempest(1);
    tempfwhmy=tempest(2);
    tempfwhmz=tempest(3);

    % Very rarely, it has happened that some images get a very high
    % estimated FWHM. This if condition re-runs the estimation in
    % that case without the -2difMAD (that seemed to remove the
    % issue). This is logged in the "Warnings" database outputted at
    % the end. In this case, the re-run estimation is read into
    % MATLAB as starting point for that specific scan. 

    if tempfwhmx>25 || tempfwhmy>25 || tempfwhmz>25 

    fprintf(2,'******\nWarning! FWHM estimation was very high for %s, i.e. x=%s, y=%s, z=%s.\n3dFWHMx was re-run without the -2difMAD flag\n******\n',f,num2str(tempfwhmx),num2str(tempfwhmy),num2str(tempfwhmz));
    warn=strcat('Warning! FWHM estimation was very high for',{' '},f,{' '},'i.e. x=',num2str(tempfwhmx),{' '},'y=',num2str(tempfwhmy),{' '},'z=',num2str(tempfwhmz));
    warn=cell2table(warn);
    dbwarn=vertcat(dbwarn,warn);

    txtfwhm_mod=strcat(wtempimg,'_automask_mod.txt');
    fwhmest_cmd_mod=char(strcat(afnifx ,{' '},'-automask',{' '},'-input',{' '}, strcat(wtempimg,'.nii'),{' '},'-out',{' '},txtfwhm_mod,{' '}));
    system(fwhmest_cmd_mod);
    tempest_mod=importdata(txtfwhm_mod);

    tempfwhmx_mod=tempest_mod(1);
    tempfwhmy_mod=tempest_mod(2);
    tempfwhmz_mod=tempest_mod(3);

             if tempfwhmx_mod>10   
                filtx=0;     
            else
                filtx=sqrt((10*10)+(0*0)-(tempfwhmx_mod*tempfwhmx_mod));
             end % end if condition FWHM estimation on the x plane is >10
            
            if tempfwhmy_mod>10   
                filty=0;     
            else
                filty=sqrt((10*10)+(0*0)-(tempfwhmy_mod*tempfwhmy_mod));
            end % end if condition FWHM estimation on the y plane is >10
            
            if tempfwhmz_mod>10   
                filtz=0;     
            else       
                filtz=sqrt((10*10)+(0*0)-(tempfwhmz_mod*tempfwhmz_mod));
            end % end if condition FWHM estimation on the z plane is >10

            flagre='1';
            
            % store the newly estimated FWHMs for the main output csv
            
            tempfwhmx=tempfwhmx_mod;
            tempfwhmy=tempfwhmy_mod;
            tempfwhmz=tempfwhmz_mod;
            
    else

            if tempfwhmx>10   
                filtx=0;     
            else
                filtx=sqrt((10*10)+(0*0)-(tempfwhmx*tempfwhmx));
            end % end if condition FWHM estimation on the x plane is >10
            
            if tempfwhmy>10   
                filty=0;     
            else
                filty=sqrt((10*10)+(0*0)-(tempfwhmy*tempfwhmy));
            end % end if condition FWHM estimation on the y plane is >10
            
            if tempfwhmz>10   
                filtz=0;     
            else       
                filtz=sqrt((10*10)+(0*0)-(tempfwhmz*tempfwhmz));
            end % end if condition FWHM estimation on the z plane is >10

            flagre='0';

    end % end if condition FWHM estimation was very high on any plane

    % Image is smoothed based on the calculated filters

    spm('defaults','PET');
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(strcat(wtempimg,'.nii'));
    matlabbatch{1}.spm.spatial.smooth.fwhm = [filtx filty filtz];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    spm_jobman('run',matlabbatch); clear matlabbatch;

    % Save some info

    finest=[cellstr(strcat(wtempimg,'.nii')) tempfwhmx tempfwhmy tempfwhmz filtx filty filtz flagre];
    finestT=cell2table(finest);
    dbests=vertcat(dbests, finestT);
    
    clear p f file tempimg wtempimg tempest tempfwhmx tempfwhmy tempfwhmz tempest_mod tempfwhmx_mod tempfwhmy_mod tempfwhmz_mod filtx filty filtz flagre fwhmest_cmd fwhmest_cmd_mod txtfwhm txtfwhm_mod warn finest finestT

end % end for loop for each input image
        
% Database cleaning/renaming of variables
dbests.Properties.VariableNames(1) = cellstr('Filename');
dbests.Properties.VariableNames(2) = cellstr('EstimatedFWHMx');
dbests.Properties.VariableNames(3) = cellstr('EstimatedFWHMy');
dbests.Properties.VariableNames(4) = cellstr('EstimatedFWHMz');
dbests.Properties.VariableNames(5) = cellstr('FWHMfilterappliedx');
dbests.Properties.VariableNames(6) = cellstr('FWHMfilterappliedy');
dbests.Properties.VariableNames(7) = cellstr('FWHMfilterappliedz');
dbests.Properties.VariableNames(8) = cellstr('AFNIEstimationRerunMod');

% print database with timestamp
filename = strcat(mdir,sprintf('/rPOP_%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
writetable(dbests,filename,'WriteRowNames',false);

% In case there was at least one error/warning, print the error database

if size(dbwarn,1)>0

    fprintf(2,'*****\nThere was at least 1 warning. A log was saved, check that out!\n*****\n');
    dbwarn.Properties.VariableNames(1) = cellstr(strcat('Warning'));

filename2 = strcat(mdir,sprintf('/rPOPWarnings_%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
writetable(dbwarn,filename2,'WriteRowNames',false);

end % end if condition at least one scan had a warning due to FWHM over-estimation


fprintf(1,'\nrPOP just finished! Warped and differentially smoothed AC PET images were generated.\nLookup the .csv database to assess FWHM estimations and filters applied.\n\n');
clear

