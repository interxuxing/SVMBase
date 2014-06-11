%%%%% Global configuration file %%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DIRECTORIES - please change if copying the code to a new location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DEVICE = 1; % 1, laptop 2, desktop (windows)

if 1 == DEVICE
    % Path for laptop
    IMAGE_SOURCE_DIR = 'C:\workspace\program\image-annotation\others\Annotation_Demo\ESP-ImageSet\images';
    IMAGE_ANNOTATION_DIR = 'C:\workspace\program\image-annotation\others\Annotation_Demo\corel5k.20091111';
    RUN_DIR = 'C:\workspace\program\image-annotation\icme2014\tag-completion\completion\svm-vt';
    MODEL_DIR = 'C:\workspace\program\image-annotation\icme2014\tag-completion\completion\svm-vt\mat_corel5k';
    LOGFILE_DIR = 'C:\workspace\program\image-annotation\icme2014\tag-completion\completion\svm-vt\mat_corel5k';
elseif 2 == DEVICE
    % Path for desktop
    IMAGE_SOURCE_DIR = 'D:\workspace-limu\image-annotation\Annotation_Demo\Corel5k';
    IMAGE_ANNOTATION_DIR = 'D:\workspace-limu\image-annotation\Annotation_Demo\corel5k.20091111';
    RUN_DIR = 'D:\workspace-limu\image-annotation\icme2014\svm-vt';
    LABEL_PAIRS_DIR = 'D:\workspace-limu\image annotation\iciap2013\labelknn\run_espgame\label_pairs';
    MODEL_DIR = 'D:\workspace-limu\image-annotation\icme2014\svm-vt\model\corel5k';
    LOGFILE_DIR = 'D:\workspace-limu\cloud disk\Dropbox\Public';
else
    error('Error value for DEVICE, should be either 1 or 2!');
end


