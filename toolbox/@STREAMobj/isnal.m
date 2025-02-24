function tf = isnal(S,nal)

%ISNAL Test whether a vector is a node attribute list of a STREAMobj
%
% Syntax
%
%     tf = isnal(S,nal)
%
% Description
%
%     Node attribute lists are attribute values for each node in the stream
%     network STREAMobj. This function tests whether a vector nal is a
%     valid node attribute list of the network S.
%
% Input arguments
%
%     S      STREAMobj
%     nal    node attribute list
%
% Output arguments
%
%     tf     true or false
%
%
% See also: STREAMobj, STREAMobj/getnal
% 
% Author: Wolfgang Schwanghart (schwangh[at]uni-potsdam.de)
% Date: 2. July, 2024

tf = isequal(numel(S.IXgrid),numel(nal)); 
tf = tf && iscolumn(nal);