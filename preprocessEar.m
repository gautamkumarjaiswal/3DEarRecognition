%Change path wherever required
    workspace_add = 'C:\Users\Gautams\Desktop\meduim\';
    data_folder = strcat(workspace_add,'mat3_ear\data_selected');
    filePattern = fullfile(data_folder, '*.abs');
    absFiles = dir(filePattern);
    numberofFiles = length(absFiles);
 

    count = 0;
    for k = 1: numberofFiles
                baseFileName = absFiles(k).name;
                flName = strtok(baseFileName,'.');
                [sub_id, im_id] = strtok(flName,'d');
                
                if length(im_id) > 4 
                    continue

                end

                fullFileName = fullfile(data_folder, baseFileName);
                [X,Y,Z,FL] = absload(fullFileName);
                Z= abs(Z);
                X= X(:);
                Y = Y(:);
                Z = Z(:);

                X1 = X(X~=-999999);
                Y1 = Y(Y~=-999999);
                Z1 = Z(Z~=999999);
                ptCloud = pointCloud2mesh([X1 Y1 Z1]);
                 makePly(ptCloud, 'rawEar.ply');
                 ptCloud = pcread('rawEar.ply');
                 pcshow(ptCloud);
                
                
                [nose_z, nose_ind] = min(ptCloud.Location(:,1));
                [ear_tip_z, ear_tip_ind] = min(ptCloud.Location(:,3));
                nose_pt = ptCloud.Location(nose_ind,:);
                ear_tip = ptCloud.Location(ear_tip_ind,:);

                cropped_points = zeros(1,3);
                for ind = 1:length(ptCloud.Location)
                    if inxrange(ptCloud.Location(ind,1),nose_pt) && inyrange(ptCloud.Location(ind,2), nose_pt)
                        cropped_points = [cropped_points; ptCloud.Location(ind,:)];
                    end
                end


                cropped_points = cropped_points((2:end),:);

                xx = double(cropped_points(:,1));
                yy = double(cropped_points(:,2));
                zz = double(cropped_points(:,3));
                %zz = -zz;
                %uncomment if you want to see cropped image
                mm = pointCloud2mesh([xx yy zz]);
                makePly(mm, 'croppedEar.ply');
                mm = pcread('croppedEar.ply');
                pcshow(mm);
                try
                zz_despiked = medfilt3(zz);
                %%%zz_despiked = medfilt3([xx,yy,zz]);

                %Multidimensional data interpolation (table lookup)
                ZI = interpn([xx,yy,zz_despiked],.9,'cubic');
                %%%ZI = interpn(zz_despiked,.9,'cubic');

                zz_denoised = imgaussfilt3(ZI(:,3));

                %uncomment if want to save raw mesh file
                %ear_deskiped_fillhole_denoised = pointCloud2rawMesh([xx,yy,zz_denoised],0.6,1);
                %makePly(ear_deskiped_fillhole_denoised, 'ear_deskiped_fillhole_denoised.ply');
                %read_ear_deskiped_fillhole_denoised = pcread('ear_deskiped_fillhole_denoised.ply');
                %pcshow(read_ear_deskiped_fillhole_denoised);


                mesh = pointCloud2mesh([xx,yy,zz_denoised]);
                % standard deviation feature

                count = count+1;   
                catch MExc
                end
              
    end

function inRng = inxrange(val, nose_pt)
        x_llmt = 90 + nose_pt(:,1);
        x_ulmt = 160 + nose_pt(:,1);
        if val >= x_llmt && val <= x_ulmt
            inRng = 1;
        else
            inRng = 0;
        end
end

function inRng = inyrange(val, nose_pt)
    y_llmt = -25 + nose_pt(:,2);
    y_ulmt =  50 + nose_pt(:,2);
    if val >= y_llmt && val <= y_ulmt
        inRng = 1;
    else
        inRng = 0;
    end
end

function inRng = inzrange(val, nose_pt)
    z_llmt = nose_pt(:,3);
    z_ulmt =  25 + nose_pt(:,3);
    if val >= z_llmt && val <= z_ulmt
        inRng = 1;
    else
        inRng = 0;
    end
end

