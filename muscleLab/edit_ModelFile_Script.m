inpath = 'C:\Users\silder\Dropbox\DARPA_shared\DARPA05\Files_W_HJCs\';
% inpath = 'C:\Users\Amy Silder\Documents\My Dropbox\DARPA_shared\DARPA05\Files_W_HJCs\';
infile = 'DARPA05.osim';
musc_volume = 11434.06; % total muscle volume estimated with spreadsheet
% DARPA05 = 11434.06; 
% DARPA06 = 8683.099415

import org.opensim.modeling.*

% Original model parameters
scaledModel = Model([inpath infile]);
orig_volume = 7315.429945; % muscle volume from Geoff, estimated with spreadsheet
% generic height = 170 cm, generic mass = 81.1947 kg

% ToScale={'edl' 'glmed1' 'piri' 'tibant' 'bfsh' 'gaslat' 'gasmed' 'glmin1' 'glmin2' 'iliacus' 'psoas' 'sart' 'tfl'}; % 10%
% ToScale={'edl' 'glmed' 'piri' 'tibant' 'bfsh' 'gaslat' 'gasmed' 'glmin' 'iliacus' 'psoas' 'sart' 'tfl'}; % 20%

% ToScale={};
% Get maximum isometric forces and scale them
scalefactor = musc_volume/orig_volume + 0.25; % force scales with muscle volume
% scalefactor = 1.25;
for i=0:scaledModel.getMuscles().getSize()-1
    temp = scaledModel.getMuscles().get(i);
%     for j=1:length(ToScale) % Uncomment this section if you only want to scale certain muscles
%         if strmatch(ToScale(j),temp)==1
%             temp
%             temp.setMaxIsometricForce(temp.getMaxIsometricForce()*scalefactor);
%         end
%     end
	temp.setMaxIsometricForce(temp.getMaxIsometricForce()*scalefactor);
end

% Save resulting model
temp = cell(scaledModel.getInputFileName());
temp = strrep(temp,'.osim','_Strong.osim');
scaledModel.print(temp)
