%%% Script to Process Images with a PET-only approach %%%
%%% Leonardo.Iaccarino@ucsf.edu - December 2020 %%%

%%% The correct execution of this script depends on the availability of the AFNI Neuroimaging suite software on the machine on which it is running
%%% (https://afni.nimh.nih.gov/) and the availability of SPM12 (https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)

% The AFNI function used to estimate smoothness if 3dFWHMx https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dFWHMx_sphx.html
% Additional flags used here are: 
% -automask: letting the function generate the mask itself to then estimate FWHM
% -out: to output the txt file
% -2difMAD: handles at least partially spatial structure in the image

%%% The current version of the script runs using 9 Templates (3 per Radiotracer) generated using publicly available data:

% Florbetapir: 100 random subjects from ADNI, 50 positive and 50 negative (http://adni.loni.usc.edu/)
% Florbetaben: 100 random subjects from ADNI, 50 positive and 50 negative (http://adni.loni.usc.edu/)
% Flutemetamol: 74 subjects from GAAIN dataset, 50 positive and 24 negative (http://www.gaain.org/centiloid-project).

% For each radiotracer dataset, three templates were generated, i.e. "all" with all the images, "pos" with the positive scans and "neg" with
% negative scans (based on centiloids quantification). 

% The script in this form needs a 3D nifti file as the only input. After warping, the script takes the image to an estimated FWHM 10mm3, based on
% a subset of IDEAS amyloid-PET data where 10mm3 was the 80th percentile of the FWHM estimation across the scans out-of-the-scanners. 

% Avoid missing the AFNI installation on the machine, to be modified if needed
setenv('PATH', [getenv('PATH') ':/usr/local/bin']);

% Select 3D nifti volumes to be processed
vols_mod1 = spm_select(Inf,'image', 'Select images to warp');  
vols_mod1_spm=cellstr(vols_mod1); 

% Select output directory
mdir=spm_select(1,'dir', 'Select output directory (tables/logs will be saved here)');

% Select directory in which the templates are stored and prepare them
tdir=spm_select(1,'dir', 'Select directory storing templates');

tic % Start counting the time after last user action

tfbball=cellstr(strcat(tdir,'/','Template_FBB_all.nii'));
tfbbpos=cellstr(strcat(tdir,'/','Template_FBB_pos.nii'));
tfbbneg=cellstr(strcat(tdir,'/','Template_FBB_neg.nii'));

tfbpall=cellstr(strcat(tdir,'/','Template_FBP_all.nii'));
tfbppos=cellstr(strcat(tdir,'/','Template_FBP_pos.nii'));
tfbpneg=cellstr(strcat(tdir,'/','Template_FBP_neg.nii'));

tfluteall=cellstr(strcat(tdir,'/','Template_FLUTE_all.nii'));
tflutepos=cellstr(strcat(tdir,'/','Template_FLUTE_pos.nii'));
tfluteneg=cellstr(strcat(tdir,'/','Template_FLUTE_neg.nii'));

warptempl=vertcat(tfbball,tfbbpos,tfbbneg,tfbpall,tfbppos,tfbpneg,tfluteall,tflutepos,tfluteneg);                                                                     

% Create empty objects to store FWHM estimations and warnings/errors, if any
dbests={};
dbwarn={};

% ask the user whether they want to set the origin manually for each image,
% do nothing or automatically resetting to the center of the image

orchc={'Do not reset origin','Set origin to center of image'};
         [oropt,~] = listdlg('PromptString',[{'Please select an option:'} {''}],...
        'SelectionMode','single',...
        'ListString',orchc);

% "For loop" going through the scans

for i=1:size(vols_mod1_spm,1)

    if oropt==2
    
   % Reset origin to center of the image, copied from from http://www.nemotos.net/scripts/acpc_coreg.m
      file = deblank(vols_mod1(i,:));
      st.vol = spm_vol(file);
      vs = st.vol.mat\eye(4);
      vs(1:3,4) = (st.vol.dim+1)/2;
      spm_get_space(st.vol.fname,inv(vs));
      
    end

   % Warp the image through the Old Normalization tool in SPM12
    tempimg=vols_mod1_spm(i,1);
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
    fwhmest_cmd=char(strcat('/Users/liaccarino/abin/3dFWHMx -automask -out',{' '},txtfwhm,{' '},'-2difMAD',{' '}, '-input',{' '}, strcat(wtempimg,'.nii')));
    system(fwhmest_cmd);

    % Read outputted txt file with the estimated FWHM in each
    % plane, preparing the calculation of the differential
    % smoothing
    tempest=importdata(txtfwhm);      
    tempfwhmx=tempest(1);
    tempfwhmy=tempest(2);
    tempfwhmz=tempest(3);

    % Very rarely, it has happened that some images get a very high
    % estimated FWHM, this if condition re-runs the estimation in
    % that case without the -2difMAD (that seemed to remove the
    % issue). This is saved in the "errors" database outputted at
    % the end. In this case, the re-run estimation is read into
    % matlab as starting point for that specific scan

    % The differential smoothing to get any plane to 10 is then
    % calculated with the formula:

    % filter=sqrt((FWHMtarget*FWHMtarget)-(FWHMestimated*FWHMestimated))

    if tempfwhmx>25 || tempfwhmy>25 || tempfwhmz>25 

    fprintf(2,'******\nWarning! FWHM estimation was very high for %s, i.e. x=%s, y=%s, z=%s.\n3dFWHMx was re-run without the -2difMAD flag\n******\n',f,num2str(tempfwhmx),num2str(tempfwhmy),num2str(tempfwhmz));
    warn=strcat('Warning! FWHM estimation was very high for',{' '},f,{' '},'i.e. x=',num2str(tempfwhmx),{' '},'y=',num2str(tempfwhmy),{' '},'z=',num2str(tempfwhmz));
    dbwarn=vertcat(dbwarn,warn);

    txtfwhm_mod=strcat(wtempimg,'_automask_mod.txt');
    fwhmest_cmd_mod=char(strcat('/Users/liaccarino/abin/3dFWHMx -automask -out',{' '},txtfwhm_mod,{' '}, '-input',{' '}, strcat(wtempimg,'.nii')));
    system(fwhmest_cmd_mod);
    tempest_mod=importdata(txtfwhm_mod);

    tempfwhmx_mod=tempest_mod(1);
    tempfwhmy_mod=tempest_mod(2);
    tempfwhmz_mod=tempest_mod(3);

             if tempfwhmx_mod>10   
                filtx=0;     
            else
                filtx=sqrt((10*10)+(0*0)-(tempfwhmx_mod*tempfwhmx_mod));
            end
            if tempfwhmy_mod>10   
                filty=0;     
            else
                filty=sqrt((10*10)+(0*0)-(tempfwhmy_mod*tempfwhmy_mod));
            end
            if tempfwhmz_mod>10   
                filtz=0;     
            else       
                filtz=sqrt((10*10)+(0*0)-(tempfwhmz_mod*tempfwhmz_mod));
            end

            flagre='1';


    else

            if tempfwhmx>10   
                filtx=0;     
            else
                filtx=sqrt((10*10)+(0*0)-(tempfwhmx*tempfwhmx));
            end
            if tempfwhmy>10   
                filty=0;     
            else
                filty=sqrt((10*10)+(0*0)-(tempfwhmy*tempfwhmy));
            end
            if tempfwhmz>10   
                filtz=0;     
            else       
                filtz=sqrt((10*10)+(0*0)-(tempfwhmz*tempfwhmz));
            end

            flagre='0';

    end

    % Image is smoothed based on the calculated filters

    spm('defaults','PET');
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(strcat(wtempimg,'.nii'));
    matlabbatch{1}.spm.spatial.smooth.fwhm = [filtx filty filtz];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    spm_jobman('run',matlabbatch); clear matlabbatch;

    % Some info is saved to be used later possibly

    finest=[cellstr(strcat(wtempimg,'.nii')) tempfwhmx tempfwhmy tempfwhmz filtx filty filtz flagre];
    finestT=cell2table(finest);
    dbests=vertcat(dbests, finestT);

end
        
% Database cleaning/renaming of variables
dbests.Properties.VariableNames([1]) = cellstr(strcat('Filename'));
dbests.Properties.VariableNames([2]) = cellstr(strcat('EstimatedFWHMx'));
dbests.Properties.VariableNames([3]) = cellstr(strcat('EstimatedFWHMy'));
dbests.Properties.VariableNames([4]) = cellstr(strcat('EstimatedFWHMz'));
dbests.Properties.VariableNames([5]) = cellstr(strcat('FWHMfilterappliedx'));
dbests.Properties.VariableNames([6]) = cellstr(strcat('FWHMfilterappliedy'));
dbests.Properties.VariableNames([7]) = cellstr(strcat('FWHMfilterappliedz'));
dbests.Properties.VariableNames([8]) = cellstr(strcat('AFNIEstimationRerunMod'));

% print database with timestamp
filename = strcat(mdir,sprintf('/rPOP_%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
writetable(dbests,filename,'WriteRowNames',false);

% In case there was at least one error/warning, print the error database
if size(dbwarn,1)>0

    fprintf(2,'*****\nThere was at least 1 warning. A log was saved, check that out!\n*****\n');
    dbwarnT.Properties.VariableNames([1]) = cellstr(strcat('Warning'));

filename2 = strcat(mdir,sprintf('/rPOPWarnings_%s.csv', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
writetable(dbwarnT,filename2,'WriteRowNames',false);

end

disp('Done!');
toc % Print total time needed
clear