function OUT = roughness(DEM,type,ks)

%ROUGHNESS Terrain ruggedness, position and roughness indices of DEMs
%
% Syntax
%
%     R = roughness(DEM,type,ks)
%
% Description
%
%     roughness calculates various metrics for locally quantifying terrain
%     roughness. Currently the function supports three different roughness
%     indices. See description below.
%
% Input
%
%     DEM   digital elevation model (GRIDobj)
%     type  roughness metrics type 
%           'tri' topographic ruggedness index (Riley et. al. 1999)
%                 (corresponds to 2d standard deviation filter
%           'tpi' topographic position index
%                 (the difference between elevation in a pixel and mean
%                 elevation of its surrounding pixels)
%           'roughness' roughness is the the largest inter-cell difference 
%                 of a central pixel and its surrounding cells (=default)
%           'srf' surface roughness factor (Hobson 1972 in Olaya 2009, 
%                 p. 159). Includes the components of the unit vector
%                 normal to the land surface (see surfnorm).
%     ks    kernel size (default = [3 3])
% 
% Output
%     
%     R     roughness index (GRIDobj)
%
% Example
%
%     DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%     R   = roughness(DEM,'ruggedness');
%     imageschs(DEM,R)
%
% References
% 
%     Riley, S. J., DeGloria, S. D., Elliot, R. 1999:  A terrain ruggedness 
%     index that quantifies topographic heterogeneity. Intermountain
%     Journal of Sciences, 5, 23-27.
%
%     Olaya, V. 2009: Basic land-surface parameters. In: Geomorphometry. 
%     Concepts, Software, Applications, Hengl, T. & Reuter, H. I. (Eds.),
%     Elsevier, 33, 141-169.
%
% See also: stdfilt, FLOWobj/meltonruggedness
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 2. November, 2024

arguments
    DEM   GRIDobj
    type  {mustBeMember(type,{'tpi','tri','roughness','srf'})}= 'roughness'
    ks    (1,2) = [3 3]
end

% Check kernel size
% if isscalar(ks)
%     ks = [ks ks];
% end
validateattributes(ks,{'numeric'},{'odd','positive'},'GRIDobj/rougnhess','ks',3)


% get matrix
dem = DEM.Z;

% pad for some roughness indices
switch lower(type)
    case {'tpi'}       
        
        padrc = floor(ks/2);
        dem = padarray(dem,padrc,'symmetric');
        depad = true;
    otherwise
        depad = false;
          
end

I   = isnan(dem);
[~,L] = bwdist(~I);
dem     = dem(L);

switch lower(type)
    case 'tri'
        % terrain ruggedness index
        % root mean squared difference between center pixel and surrounding
        % pixels
        % excerpt from ArcGIS-Help
        % The topographic ruggedness index (TRI) is a measurement developed
        % by Riley, et al. (1999) to express the amount of elevation 
        % difference between adjacent cells of a digital elevation grid. 
        % The process essentially calculates the difference in elevation 
        % values from a center cell and the eight cells immediately 
        % surrounding it. Then it squares each of the eight elevation 
        % difference values to make them all positive and averages the 
        % squares. The topographic ruggedness index is then derived by 
        % taking the square root of this average, and corresponds to 
        % average elevation change between any point on a grid and it�s 
        % surrounding area.
        %
        % I don't have access to the article, but it seems to me that this
        % index is nothing but a moving standard deviation
        
        kernel = ones(ks);
        R      = stdfilt(dem,kernel);
        
    case 'tpi'
        % Topographic Position Index
        % difference between a central pixel and the mean of its
        % surrounding cells
        kernel = ones(ks);
        kernel(ceil(ks(1)/2),ceil(ks(2)/2)) = 0;
        % normalize kernel
        kernel = kernel/sum(kernel(:));
        
        % convolute
        R = conv2(dem,kernel,'valid');
        R = dem(padrc(1)+1:end-padrc(1),padrc(2)+1:end-padrc(2))-R;      
        
    case 'roughness'
        % Roughness
        % Roughness is the the largest inter-cell difference of a central
        % pixel and its surrounding cell
        kernel = ones(ks);        
        R = max(imdilate(dem,kernel)-dem,dem-imerode(dem,kernel));
        
     case 'srf'
        % surface roughness factor according to Hobson (1972) (in Olaya
        % 2009)
        [Nx,Ny,Nz] = surfnorm(dem);
        kernel = ones(ks);
        % Unitize vectors
        N = sqrt(Nx.^2 + Ny.^2 + Nz.^2);
        Nx = Nx./N;
        Ny = Ny./N;
        Ny = Ny./N;
        
        % convolute
        Nx = conv2(Nx,kernel,'same').^2; % --> uses zero padding on edges
        Ny = conv2(Ny,kernel,'same').^2;
        Nz = conv2(Nz,kernel,'same').^2;
    
        R  = sqrt(Nx + Ny + Nz)/numel(kernel);
        
end
        
if depad
    R(I(padrc(1)+1:end-padrc(1),padrc(2)+1:end-padrc(2))) = nan;
else
    R(I) = nan;
end

% prepare output
OUT = DEM;
OUT.Z = R;
OUT.name = type;

