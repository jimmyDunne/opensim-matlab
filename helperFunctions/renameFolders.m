function renameFolders(path2folder)


% path2folder='E:\experiments\loadedWalking\loadedWalking_gait2392_thelen\subject05\loaded\trial04'
% renameFolders('E:\experiments\loadedWalking\loadedWalking_gait2392_thelen\subject05\loaded\trial01')
% renameFolders('E:\experiments\loadedWalking\loadedWalking_gait2392_thelen\subject05\loaded\trial02')
% renameFolders('E:\experiments\loadedWalking\loadedWalking_gait2392_thelen\subject05\loaded\trial03')
% renameFolders('E:\experiments\loadedWalking\loadedWalking_gait2392_thelen\subject05\loaded\trial04')
% renameFolders('E:\experiments\loadedWalking\loadedWalking_gait2392_thelen\subject05\loaded\trial06')



g = dir(path2folder);

for i = 3:length(g)
    
   if g(i).isdir &&  length(g(i).name) > 4
    
       subFolder = fullfile(path2folder,g(i).name);
       
       
       g2 = dir(subFolder);
       
       for ii = 3:length(g2)
           
          if  g2(ii).isdir &&  length(g2(ii).name) > 4
           
              refNumber = strfind(g2(ii).name,'_');
              
              
              if length(g2(ii).name) - refNumber(end)  == 2
              
                 tempNumHold = g2(ii).name(end-1:end);
                 
                 newName = [g2(ii).name(1:end-2) '0' tempNumHold];
                  
              end
              
              if length(g2(ii).name) - refNumber(end)  == 1
              
                 tempNumHold = g2(ii).name(end);
                 
                 newName = [g2(ii).name(1:end-1) '00' tempNumHold];
                  
              end
              
              if length(g2(ii).name) - refNumber(end) == 3
                  continue
              end
              
              foldername    = fullfile(subFolder,g2(ii).name);
              newFoldername = fullfile(subFolder,newName);
              
              movefile(foldername, newFoldername);
              
              
          end
       end
       
       
       
   end
    
end








end 